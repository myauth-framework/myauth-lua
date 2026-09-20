-- myauth.basic

local url_tools = require "myauth.url-tools"

local _M = {}

local function get_user(value)
  local decoded = require "base64".decode(value)
  local sep_index = decoded:find(":")
  return decoded:sub(1, sep_index-1), decoded:sub(sep_index+1)
end

function _M.check(self, url, cred)
  if(self._auth_config == null or self._auth_config.basic == nil) then
    self._event_listener:on_deny_dueto_no_basic_config(url)
    self._ngx_strategy.exit_forbidden("There's no basic access in _auth_configuration")
  end

  local user_id, user_pass = get_user(cred)

  for _, user in ipairs(self._auth_config.basic) do
    if user.id == user_id then

      if user.pass ~= user_pass then
        self._event_listener:on_deny_dueto_wrong_basic_pass(url, user_id)
        self._ngx_strategy.exit_forbidden("Wrong user password")
      end

      for _, url_pattern in ipairs(user.urls) do
        if url_tools.check_url(url, url_pattern) then
          self._auth_schema.apply_basic(user_id, self._ngx_strategy)
          self._event_listener:on_allow_basic(url, user_id)
          return
        end
      end

    end
  end

  self._event_listener:on_deny_dueto_no_basic_rules_found(url, user_id)
  self._ngx_strategy.exit_forbidden("No allowing rules were found for basic")
end

return _M
