-- myauth-jwt-test-nginx.lua
-- nginx wrapper for tests

local _M = {}

_M.debug_mode = true
_M.debug_rbac_info = "nil"

function _M.set_debug_rbac_header(info)
  _M.debug_rbac_info = info
  if debug_mode then
    print(info)
  end
end

function _M.set_auth_header(value)
  if debug_mode then
    print("Set Authorization header: " .. value)
  end
end

function _M.set_claim_header(name, value)
  if debug_mode then
    print("Set claim header 'X-Claim-" .. name .. "': " .. value)
  end
end

function _M.exit_unauthorized(msg)
  	error("Set UNAUTHORIZED: " .. msg);
end

function _M.exit_forbidden(msg)
	if msg ~=nil then
  		error("Set FORBIDDEN: " .. msg);
  	else
  		error("Set FORBIDDEN: Access denied");
  	end
end

function _M.exit_internal_error(code)
  	error("Set HTTP_INTERNAL_SERVER_ERROR: " .. code);
end

return _M;