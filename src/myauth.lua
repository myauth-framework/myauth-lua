-- myauth.lua

local _M = {}

_M.strategy = require "myauth.nginx"

local base64 = require "base64"
local cjson = require "cjson"
local mjwt = require "myauth.jwt"
local auth_schema = nil

local config = nil

local function check_url(url, pattern)

  local norm_pattern, _ = string.gsub(pattern, "-", "%%-")
  norm_pattern, _ = string.gsub(norm_pattern, "%%%%%-", "%%-")
  return string.match(url, norm_pattern)

end

local function check_dont_apply_for(url)
  if config.dont_apply_for ~= nil then

    for i, url_pattern in ipairs(config.dont_apply_for) do
        if check_url(url, url_pattern) then
            return true
        end
    end

  end
  return false
end

local function check_only_apply_for(url)
  if config.only_apply_for ~= nil then

    for i, url_pattern in ipairs(config.only_apply_for) do
        if check_url(url, url_pattern) then
            return true
        end
    end

  end
  return false
end

local function check_black_list(url)
  if config.black_list ~= nil then

    for i, url_pattern in ipairs(config.black_list) do
        if check_url(url, url_pattern) then
            return true
        end
    end

  end
  return false
end

local function has_value (tab, val)
  
  if tab == nil then
    return false
  end  
  for index, value in ipairs(tab) do
      if value == val then
          return true
      end
  end

  return false
end

local function get_basic_user(value)

  local decoded = base64.decode(value)
  local sep_index = decoded:find(":")
  return decoded:sub(1, sep_index-1), decoded:sub(sep_index+1)

end

local function check_anon(url)
  
  if(config == nil or config.anon == nil) then
    _M.strategy.exit_forbidden("There is no anon access in configuration")
  end
  
  for i, url_pattern in ipairs(config.anon) do
    if(check_url(url, url_pattern)) then
      return
    end
  end

  _M.strategy.exit_forbidden("No allowing rules were found for anon")
end

local function check_basic(url, cred)

  if(config == null or config.basic == nil) then
    _M.strategy.exit_forbidden("There's no basic access in configuration")
  end

  local user_id, user_pass = get_basic_user(cred)

  for i, user in ipairs(config.basic) do
    if user.id == user_id then

      if user.pass ~= user_pass then
        _M.strategy.exit_forbidden("Wrong user password")
      end  

      for i, url_pattern in ipairs(user.urls) do

        if check_url(url, url_pattern) then

          auth_schema.apply_basic(user_id, _M.strategy)

          return

        end
      end

    end
  end

  _M.strategy.exit_forbidden("No allowing rules were found for basic")
end

local function check_rbac_token(token, host)
  return mjwt.authorize(token, host)
end

local function check_rbac_roles(url, http_method, token_roles)

  if(config == null or config.rbac == nil or config.rbac.rules == nil) then
    _M.strategy.exit_forbidden("There's no bearer access in configuration")
  end

  local calc_rules = {}
  local rules_factors = {}

  for _, rule in ipairs(config.rbac.rules) do
    if(check_url(url, rule.url)) then

      local calc_rule = { 
        pattern = rule.url,
        total_factor = nil
      }

      local factors = {}

      if rule.allow_for_all then
        calc_rule.allow_for_all = true
        table.insert(factors, true)
      else
        for _, rl in ipairs(token_roles) do
          if has_value(rule.allow, rl) then
            calc_rule.allow = rl
            table.insert(factors, true)
            break
          end
        end
        for _, rl in ipairs(token_roles) do
          if has_value(rule.deny, rl) then
            calc_rule.deny = rl
            table.insert(factors, false)
            break
          end
        end
        for _, rl in ipairs(token_roles) do
          local method_allow_list_name = "allow_" .. string.lower(http_method)
          local method_allow_list = rule[method_allow_list_name]
          if method_allow_list ~= nil and has_value(method_allow_list, rl) then
            calc_rule[method_allow_list_name] = rl
            table.insert(factors, true)
          end
        end
        for _, rl in ipairs(token_roles) do
          local method_deny_list_name = "deny_" .. string.lower(http_method)
          local method_deny_list = rule[method_deny_list_name]
          if method_deny_list ~= nil and has_value(method_deny_list, rl) then
            calc_rule[method_deny_list_name] = rl
            table.insert(factors, false)
          end
        end
      end

      if has_value(factors, false) then
        calc_rule.total_factor = false
        table.insert(rules_factors, false)
      elseif has_value(factors, true) then
        calc_rule.total_factor = true
        table.insert(rules_factors, true)
      else
        calc_rule.total_factor = false
        table.insert(rules_factors, false)
      end

      table.insert(calc_rules, calc_rule)
    end
  end

  local hasDenies = has_value(rules_factors, false);
  local hasAllows = has_value(rules_factors, true);

  return not hasDenies and hasAllows, { rules = calc_rules, roles = token_roles, method = http_method, url = url }
end

local function check_rbac(url, http_method, token, host)

  local token_obj = check_rbac_token(token, host)

  --print(cjson.encode(token_obj))

  local token_roles = mjwt.get_token_roles(token_obj)
  local check_result, debug_info = check_rbac_roles(url, http_method, token_roles)

  if config.debug_mode then
    local debug_info_str = cjson.encode(debug_info)
    _M.strategy.set_debug_rbac_header(debug_info_str)
  end

  if not check_result then
      _M.strategy.exit_forbidden("No allowing rules were found for bearer")
    else
      local claims = mjwt.get_token_biz_claims(token_obj)
      auth_schema.apply_rbac(claims, _M.strategy)
    end 
end

function _M.initialize(init_config, init_secrets)

  config = init_config
  mjwt.secret = init_secrets.jwt_secret

  if init_config.rbac ~= nil then
    mjwt.ignore_audience = init_config.rbac.ignore_audience
  end

  mjwt.strategy = _M.strategy

  if init_config.debug_mode == true then
    _M.strategy.debug_mode = true
  end

end

function _M.authorize()

  local auth_header = ngx.var.http_Authorization
	local host_header = ngx.var.http_Host
  local http_method = ngx.var.request_method;
  local url = ngx.var.request_uri
  
  _M.authorize_core(url, http_method, auth_header, host_header)

  ngx.exit(ngx.OK)
end

function _M.authorize_core(url, http_method, auth_header, host_header)

  if config == nil then
    error("MyAuth config was not loaded")
  end

  if config.output_schema == "myauth2" or config.output_schema == nil then

    auth_schema = require "myauth.scheme-v2"

  elseif config.output_schema == "myauth1" then

    auth_schema = require "myauth.scheme-v1"

  else

    error("Output schema not supported")

  end

  if check_dont_apply_for(url) then
    return
  end

  if config.only_apply_for ~= nil and not check_only_apply_for(url) then
    return
  end

  if check_black_list(url) then
    _M.strategy.exit_forbidden("Specified url was found in black list")
  end

  if auth_header == nil then
    check_anon(url)
    return
	end

	local _, _, token = string.find(auth_header, "Bearer%s+(.+)")
	if token ~= nil then
  	check_rbac(url, http_method, token, host_header)
  	return
	end

	local _, _, basic = string.find(auth_header, "Basic%s+(.+)")
	if basic ~= nil then
  	check_basic(url, basic)
  	return
	end

  print("Auth header: " .. auth_header)
  _M.strategy.exit_forbidden("Unsupported authorization type")
end

return _M;