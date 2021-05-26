-- url-tools.config

local _M = {}

function _M.check_url(url, pattern)

  local norm_pattern, _ = string.gsub(pattern, "-", "%%-")
  norm_pattern, _ = string.gsub(norm_pattern, "%%%%%-", "%%-")
  return string.match(url, norm_pattern)

end

function _M.check_url_rate(url, pattern)

  local norm_pattern, _ = string.gsub(pattern, "-", "%%-")
  norm_pattern, _ = string.gsub(norm_pattern, "%%%%%-", "%%-")
  return string.match(url, norm_pattern), string.len(pattern)

end

return _M