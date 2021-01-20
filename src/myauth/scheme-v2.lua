-- myauth.scheme-v2

local claimstr = require "myauth.claim-str"

local _M = {}

function _M.apply_rbac(claims, nginx)
	nginx.set_auth_header("MyAuth2")

	for name, claim in pairs(claims) do

		local header_name = nil

		if name == "sub" then
			header_name = "User-Id"
		elseif name == "roles" then
			header_name = "Roles"
		elseif name == "role" or name == "http://schemas.microsoft.com/ws/2008/06/identity/claims/role" then
			header_name = "Role"
		else
			header_name = claimstr.claim_type_to_header_name(name)
		end

		local header_val = claimstr.claim_value_to_header_value(claim)

		nginx.set_claim_header(header_name, header_val)
	end
end

function _M.apply_basic(user_id, nginx)
  	nginx.set_auth_header("MyAuth2")
  	nginx.set_claim_header("User-Id", user_id)
end

return _M