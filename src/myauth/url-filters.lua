-- myauth.url-filters

local url_tools = require "myauth.url-tools"

local _M = {}

local function matches_any(url, patterns)
  if patterns == nil then
    return false
  end

  for _, url_pattern in ipairs(patterns) do
    if url_tools.check_url(url, url_pattern) then
      return true
    end
  end

  return false
end

function _M.check_dont_apply_for(self, url)
  return matches_any(url, self._auth_config.dont_apply_for)
end

function _M.check_only_apply_for(self, url)
  return matches_any(url, self._auth_config.only_apply_for)
end

function _M.check_black_list(self, url)
  return matches_any(url, self._auth_config.black_list)
end

return _M
