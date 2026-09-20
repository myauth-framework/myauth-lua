-- myauth.rbac

local url_tools = require "myauth.url-tools"

local _M = {}

local function has_value(tab, val)
  if tab == nil then
    return false
  end
  for _, value in ipairs(tab) do
      if value == val then
          return true
      end
  end

  return false
end

local function check_token(self, url, token, host)
  local token, error_code, error_reason = self._mjwt.authorize(token, host)

    if(error_code ~= nil) then
      self._event_listener:on_deny_rbac_token(url, host, error_code, error_reason)
    end

    if(error_code == 'missing_token') then
      self._ngx_strategy.exit_unauthorized("Missing token")
    end

    if(error_code and string.find(error_code, "invalid_token")) then
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

local function check_roles(self, url, http_method, token_roles)
  local calc_rules = {}

  local rules_factor = nil;
  local rules_factor_rate = 0;

  for _, rule in ipairs(self._auth_config.rbac.rules) do

    local url_hit, url_rate = url_tools.check_url_rate(url, rule.url)

    if url_hit then

      local calc_rule = {
        pattern = rule.url,
        rate = url_rate,
        total_factor = nil
      }

      local factors = {}

      if rule.allow_for_all then
        calc_rule.allow_for_all = true
        table.insert(factors, true)
      elseif
        rule.deny_for_all then
        calc_rule.deny_for_all = true
        table.insert(factors, false)
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

      local hasRuleDenies = has_value(factors, false)
      local hasRuleAllows = has_value(factors, true)
      local resultRuleFactor = nil

      if hasRuleDenies then
        resultRuleFactor = false
      elseif hasRuleAllows then
        resultRuleFactor = true
      end

      if resultRuleFactor ~= nil then

        calc_rule.total_factor = resultRuleFactor

        if url_rate >= rules_factor_rate then
          rules_factor = resultRuleFactor
          rules_factor_rate = url_rate
        end
      else
        calc_rule.total_factor = "undefined"
      end

      table.insert(calc_rules, calc_rule)
    end
  end

  local total_result = rules_factor or false

  return total_result, { rules = calc_rules, roles = token_roles, method = http_method, url = url }
end

function _M.check(self, url, http_method, token, host)
  if(self._auth_config == nil or self._auth_config.rbac == nil or self._auth_config.rbac.rules == nil) then
    self._event_listener:on_deny_dueto_no_rbac_config(url)
    self._ngx_strategy.exit_forbidden("There's no rbac access in configuration")
  end

  local token_obj = check_token(self, url, token, host)
  local token_roles = self._mjwt.get_token_roles(token_obj)
  local check_result, debug_info = check_roles(self, url, http_method, token_roles)

  if self._auth_config.debug_mode then
    local debug_info_str = require "cjson".encode(debug_info)
    self._ngx_strategy.set_debug_rbac_header(debug_info_str)
  end

  if not check_result then
    self._event_listener:on_deny_no_rbac_rules_found(url, http_method, token_obj.payload.sub)
    self._ngx_strategy.exit_forbidden("No allowing rules were found for bearer")
  else
    local claims = self._mjwt.get_token_biz_claims(token_obj)
    self._auth_schema.apply_rbac(claims, self._ngx_strategy)
  end

  self._event_listener:on_allow_rbac(url, http_method, token_obj.payload.sub)
end

return _M
