-- myauth.nginx
-- nginx wrapper

local _M = {}

_M.debug_mode = false

function _M.set_debug_rbac_header(info)
  
  if _M.debug_mode then
    ngx.header["X-Debug-Rbac"] = info
  end

end

function _M.set_auth_header(value)
  
  ngx.req.set_header("Authorization", value)
  if _M.debug_mode then
    ngx.header["X-Debug-Authorization-Header"] = value 
  end

end

function _M.set_claim_header(name, value)
  
  ngx.req.set_header("X-Claim-" .. name, value)
  if _M.debug_mode then
    ngx.header["X-Debug-Claim-" .. name] = value 
  end

end

function _M.exit_unauthorized(msg)
  
  if _M.debug_mode and msg ~=nil then
    ngx.header["X-Debug-Msg"] = msg 
  end
  ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

function _M.exit_forbidden(msg)  
  
  if _M.debug_mode and msg ~=nil then
    ngx.header["X-Debug-Msg"] = msg 
  end
  
  ngx.exit(ngx.HTTP_FORBIDDEN)
end

function _M.exit_internal_error(code)
  
  if _M.debug_mode and code ~=nil then
    ngx.header["X-Debug-Msg"] = code 
  end
  
  ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

return _M