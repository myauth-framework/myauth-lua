-- myauth.anon

local url_tools = require "myauth.url-tools"

local _M = {}

function _M.check(self, url)
  if(self._auth_config == nil or self._auth_config.anon == nil) then
    self._event_listener:on_deny_dueto_no_anon_config(url)
    self._ngx_strategy.exit_forbidden("There is no anon access in _auth_configuration")
  end

  for _, url_pattern in ipairs(self._auth_config.anon) do
    if(url_tools.check_url(url, url_pattern)) then
      self._event_listener:on_allow_anon(url)
      return
    end
  end

  self._event_listener:on_deny_dueto_no_anon_rules_found(url)
  self._ngx_strategy.exit_forbidden("No allowing rules were found for anon")
end

return _M
