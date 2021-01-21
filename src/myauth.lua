-- myauth.lua

require "base64"
require "cjson"
require "myauth.jwt"
require "myauth.nginx"
require "myauth.empty-event-listener"

local MyAuth = {}
local mt = { __index = MyAuth }

function MyAuth:check_url(url, pattern)

  local norm_pattern, _ = string.gsub(pattern, "-", "%%-")
  norm_pattern, _ = string.gsub(norm_pattern, "%%%%%-", "%%-")
  return string.match(url, norm_pattern)

end

function MyAuth:check_dont_apply_for(url)
  
  if self._auth_config.dont_apply_for ~= nil then

    for i, url_pattern in ipairs(self._auth_config.dont_apply_for) do
        if self:check_url(url, url_pattern) then
            return true
        end
    end

  end
  return false
end

function MyAuth:check_only_apply_for(url)
  if self._auth_config.only_apply_for ~= nil then

    for i, url_pattern in ipairs(self._auth_config.only_apply_for) do
        if self:check_url(url, url_pattern) then
            return true
        end
    end

  end
  return false
end

function MyAuth:check_black_list(url)
  if self._auth_config.black_list ~= nil then

    for i, url_pattern in ipairs(self._auth_config.black_list) do
        if self:check_url(url, url_pattern) then
            return true
        end
    end

  end
  return false
end

function MyAuth:has_value (tab, val)
  
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

function MyAuth:get_basic_user(value)

  local decoded = require "base64".decode(value)
  local sep_index = decoded:find(":")
  return decoded:sub(1, sep_index-1), decoded:sub(sep_index+1)

end

function MyAuth:check_anon(url)
  
  if(self._auth_config == nil or self._auth_config.anon == nil) then
    self._event_listener.on_deny_dueto_no_anon_auth_config(url)
    self._ngx_strategy.exit_forbidden("There is no anon access in _auth_configuration")
  end
  
  for i, url_pattern in ipairs(self._auth_config.anon) do
    if(self:check_url(url, url_pattern)) then
      self._event_listener.on_allow_anon(url)
      return
    end
  end

  self._event_listener.on_deny_dueto_no_anon_rules_found(url)
  self._ngx_strategy.exit_forbidden("No allowing rules were found for anon")
end

function MyAuth:check_basic(url, cred)

  if(self._auth_config == null or self._auth_config.basic == nil) then
    self._event_listener.on_deny_dueto_no_basic_auth_config(url)
    self._ngx_strategy.exit_forbidden("There's no basic access in _auth_configuration")
  end

  local user_id, user_pass = self:get_basic_user(cred)

  for i, user in ipairs(self._auth_config.basic) do
    if user.id == user_id then

      if user.pass ~= user_pass then
        self._event_listener.on_deny_dueto_wrong_basic_pass(url, user_id)
        self._ngx_strategy.exit_forbidden("Wrong user password")
      end  

      for i, url_pattern in ipairs(user.urls) do

        if self:check_url(url, url_pattern) then

          self._auth_schema.apply_basic(user_id, self._ngx_strategy)
          
          self._event_listener.on_allow_basic(url, user_id)
          return

        end
      end

    end
  end

  self._event_listener.on_deny_dueto_no_basic_rules_found(url, user_id)
  self._ngx_strategy.exit_forbidden("No allowing rules were found for basic")
end

function MyAuth:check_rbac_token(url, token, host)
  local token, error_code, error_reason = self._mjwt.authorize(token, host)

    if(error_code ~= nil) then
      self._event_listener.on_deny_rbac_token(url, host, error_code, error_reason)
    end

    if(error_code == 'missing_token') then
      self._ngx_strategy.exit_unauthorized("Missing token")
    end

    if(error_code == 'invalid_token') then
      self._ngx_strategy.exit_unauthorized("Invalid token: " .. error_reason)
    end

    if(error_code == 'invalid_audience') then
      self._ngx_strategy.exit_unauthorized("Invalid audience: " .. error_reason)
    end

    if(error_code == 'no_host') then
      self._ngx_strategy.exit_unauthorized(error_reason)
    end

    if(error_code ~= nil) then
      error("Unexpected  error code: " .. error_code)
    end

    return token
end

function MyAuth:check_rbac_roles(url, http_method, token_roles)

  local calc_rules = {}
  local rules_factors = {}

  for _, rule in ipairs(self._auth_config.rbac.rules) do
    if(self:check_url(url, rule.url)) then

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
          if self:has_value(rule.allow, rl) then
            calc_rule.allow = rl
            table.insert(factors, true)
            break
          end
        end
        for _, rl in ipairs(token_roles) do
          if self:has_value(rule.deny, rl) then
            calc_rule.deny = rl
            table.insert(factors, false)
            break
          end
        end
        for _, rl in ipairs(token_roles) do
          local method_allow_list_name = "allow_" .. string.lower(http_method)
          local method_allow_list = rule[method_allow_list_name]
          if method_allow_list ~= nil and self:has_value(method_allow_list, rl) then
            calc_rule[method_allow_list_name] = rl
            table.insert(factors, true)
          end
        end
        for _, rl in ipairs(token_roles) do
          local method_deny_list_name = "deny_" .. string.lower(http_method)
          local method_deny_list = rule[method_deny_list_name]
          if method_deny_list ~= nil and self:has_value(method_deny_list, rl) then
            calc_rule[method_deny_list_name] = rl
            table.insert(factors, false)
          end
        end
      end

      if self:has_value(factors, false) then
        calc_rule.total_factor = false
        table.insert(rules_factors, false)
      elseif self:has_value(factors, true) then
        calc_rule.total_factor = true
        table.insert(rules_factors, true)
      else
        calc_rule.total_factor = false
        table.insert(rules_factors, false)
      end

      table.insert(calc_rules, calc_rule)
    end
  end

  local hasDenies = self:has_value(rules_factors, false);
  local hasAllows = self:has_value(rules_factors, true);

  local total_result = not hasDenies and hasAllows

  return total_result, { rules = calc_rules, roles = token_roles, method = http_method, url = url }
end

function MyAuth:check_rbac(url, http_method, token, host)

  if(self._auth_config == null or self._auth_config.rbac == nil or self._auth_config.rbac.rules == nil) then
    self._event_listener.on_deny_dueto_no_rbac_config(url)
    self._ngx_strategy.exit_forbidden("There's no rbac access in configuration")
  end

  local token_obj = self:check_rbac_token(url, token, host)
  local token_roles = self._mjwt.get_token_roles(token_obj)
  local check_result, debug_info = self:check_rbac_roles(url, http_method, token_roles)

  if self._auth_config.debug_mode then
    local debug_info_str = require "cjson".encode(debug_info)
    self._ngx_strategy.set_debug_rbac_header(debug_info_str)
  end

  if not check_result then
    self._event_listener.on_deny_no_rbac_rules_found(url, http_method, token_obj.payload.sub)
    self._ngx_strategy.exit_forbidden("No allowing rules were found for bearer")
  else
    local claims = self._mjwt.get_token_biz_claims(token_obj)
    self._auth_schema.apply_rbac(claims, self._ngx_strategy)
  end 

  self._event_listener.on_allow_rbac(url, http_method, token_obj.payload.sub)
end

function MyAuth:authorize()

  local auth_header = ngx.var.http_Authorization
	local host_header = ngx.var.http_Host
  local http_method = ngx.var.request_method;
  local url = ngx.var.request_uri
  
  self:authorize_core(url, http_method, auth_header, host_header)

  ngx.exit(ngx.OK)
end

function MyAuth:authorize_core(url, http_method, auth_header, host_header)

  if self._auth_config == nil then
    error("MyAuth auth_config was not loaded")
  end

  if self._auth_config.output_schema == "myauth2" or self._auth_config.output_schema == nil then

    self._auth_schema = require "myauth.scheme-v2"

  elseif _auth_config.output_schema == "myauth1" then

    self._auth_schema = require "myauth.scheme-v1"

  else

    error("Output schema not supported")

  end

  if self:check_dont_apply_for(url) then
    self._event_listener.on_allow_dueto_dont_apply_for(url)    
    return
  end

  if self._auth_config.only_apply_for ~= nil and not self:check_only_apply_for(url) then
    self._event_listener.on_allow_dueto_only_apply_for(url)
    return
  end

  if self:check_black_list(url) then
    self._event_listener.on_deny_dueto_black_list(url)
    self._ngx_strategy.exit_forbidden("Specified url was found in black list")
  end

  if auth_header == nil then
    self:check_anon(url)
    return
	end

	local _, _, token = string.find(auth_header, "Bearer%s+(.+)")
	if token ~= nil then
  	self:check_rbac(url, http_method, token, host_header)
  	return
	end

	local _, _, basic = string.find(auth_header, "Basic%s+(.+)")
	if basic ~= nil then
  	self:check_basic(url, basic)
  	return
	end

  self._event_listener.on_deny_dueto_unsupported_auth_type(url, auth_header)
  print("Auth header: " .. auth_header)
  self._ngx_strategy.exit_forbidden("Unsupported authorization type")
end

function MyAuth.new(config, secrets, event_listener, nginx_strategy)

  local new_obj = setmetatable({}, mt)

  new_obj._auth_config = config
  new_obj._ngx_strategy = nginx_strategy or require "myauth.nginx"
  new_obj._event_listener = event_listener or require "myauth.empty-event-listener"
  new_obj._mjwt = require "myauth.jwt"
  
  new_obj._mjwt.secret = secrets.jwt_secret

  if config.rbac ~= nil then
    new_obj._mjwt.ignore_audience = config.rbac.ignore_audience
  end

  if config.debug == true then
    new_obj._ngx_strategy.debug = true
  end

  return new_obj;
end


return MyAuth;