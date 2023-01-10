-- url-tools.config

local _M = {}

local function is_identifier(str)

  local _, count = string.gsub(str, "%d", "")
  
  if count > 1 then
    return true
  else 
    return false
  end

end

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

function _M.to_url_pattern(url)

  local res = "";

  if string.sub(url, 1, 1) == "/" then
    res = "/"
  end

  for token in string.gmatch(url, "[^//]+") do
     
    if res ~= "" and string.sub(res, -1) ~= "/" then
      res = res .. "/"
    end

    if is_identifier(token) then
      res = res .. "xxx"
    else
      res = res .. token
    end

  end
  
  return res

end

return _M