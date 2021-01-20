-- myauth.jwt

local _M = {}

local cjson = require "cjson"

_M.strategy = require "myauth.nginx"
_M.secret = nil
_M.ignore_audience = false

function _M.authorize(token, host)

  if token == nil then
    _M.strategy.exit_unauthorized("Missing token")
  end

  local jwt = require "resty.jwt"

  if _M.secret == nil then
    error("Secret not specified")
  end

  local jwt_obj = jwt:verify(_M.secret, token)

  if not jwt_obj.verified then
    _M.strategy.exit_forbidden("Invalid token: " .. jwt_obj.reason)
  end

  if not _M.ignore_audience then
    if jwt_obj.payload.aud ~= null then
      if host ~= nil then
        if(jwt_obj.payload.aud ~= host) then
            _M.strategy.exit_forbidden("Invalid audience. Expected '" .. jwt_obj.payload.aud .. "' but got '" .. host .. "'")
        end
      else
        _M.strategy.exit_forbidden("Cant detect a host to check audience")
      end
    end
  end 
  
  return jwt_obj

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