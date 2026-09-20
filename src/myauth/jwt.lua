-- myauth.jwt

local url_tools = require "myauth.url-tools"
local jwt = require "resty.jwt"

local _M = {}

_M.secret = nil
_M.ignore_audience = false

local function classify_verify_error(reason)
  if string.find(reason, "signature mismatch") then
    return 'invalid_token_sign'
  elseif string.find(reason, "invalid jwt string") then
    return 'invalid_token_format'
  else
    return 'invalid_token'
  end
end

local function verify_token(token)
  if _M.secret == nil then
    error("Secret not specified")
  end

  local jwt_obj = jwt:verify(_M.secret, token)

  if not jwt_obj.verified then
    return nil, classify_verify_error(jwt_obj.reason), jwt_obj.reason
  end

  return jwt_obj, nil, nil
end

local function format_audience(aud)
  if type(aud) == "table" then
    return table.concat(aud, ", ")
  end

  return tostring(aud)
end

local function audience_entry_matches(entry, host)
  if entry == host then
    return true
  end

  if type(entry) ~= "string" then
    return false
  end

  -- local ok, captures = pcall(ngx.re.match, host, entry)
  -- return ok and captures ~= nil

  return url_tools.check_url(host, entry);
end

local function audience_matches(aud, host)
  if type(aud) == "table" then
    for _, entry in ipairs(aud) do
      if audience_entry_matches(entry, host) then
        return true
      end
    end

    return false
  end

  return audience_entry_matches(aud, host)
end

local function check_audience(jwt_obj, host)
  if _M.ignore_audience then
    return nil, nil
  end

  if jwt_obj.payload.aud == nil then
    return nil, nil
  end

  if host == nil then
    return 'no_host', "Cant detect a host to check audience"
  end

  if not audience_matches(jwt_obj.payload.aud, host) then
    return 'invalid_audience', "Expected '" .. format_audience(jwt_obj.payload.aud) .. "' but actual '" .. host .. "'"
  end

  return nil, nil
end

function _M.authorize(token, host) -- token, error_code, error_reason
  if token == nil then
    return nil, 'missing_token', nil
  end

  local jwt_obj, error_code, error_reason = verify_token(token)
  if error_code ~= nil then
    return nil, error_code, error_reason
  end

  error_code, error_reason = check_audience(jwt_obj, host)
  if error_code ~= nil then
    return nil, error_code, error_reason
  end

  return jwt_obj, nil, nil
end

function _M.get_token_roles(jwt_obj)

  local role = jwt_obj.payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']

  if role ~= nil then
    return { role }
  end

  role = jwt_obj.payload['role']

  if role ~= nil then
    return { role }
  end

  return jwt_obj.payload.roles;
end

function _M.get_token_biz_claims(jwt_obj)

  local claims = {}
  for k,v in pairs(jwt_obj.payload) do
    if k ~= "iss" and 
       k ~= "aud" and 
       k ~= "exp" and 
       k ~= "nbf" and 
       k ~= "iat" and 
       k ~= "jti" then
      claims[k] = v
    end
  end

  return claims

end

return _M