-- myauth.jwt

local _M = {}

local cjson = require "cjson"

_M.secret = nil
_M.ignore_audience = false

function _M.authorize(token, host) -- token, error_code, error_reason 

  if token == nil then
    return nil, 'missing_token', nil;
  end

  local jwt = require "resty.jwt"

  if _M.secret == nil then
    error("Secret not specified")
  end

  local jwt_obj = jwt:verify(_M.secret, token)

  if not jwt_obj.verified then
    return nil, 'invalid_token', jwt_obj.reason;
  end

  if not _M.ignore_audience then
    if jwt_obj.payload.aud ~= null then
      if host ~= nil then
        if(jwt_obj.payload.aud ~= host) then
            return nil, 'invalid_audience', "Expected '" .. jwt_obj.payload.aud .. "' but actual '" .. host .. "'";
        end
      else
        return nil, 'no_host', "Cant detect a host to check audience";
      end
    end
  end 
  
  return jwt_obj, nil,nil

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