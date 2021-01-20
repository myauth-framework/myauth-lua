-- myauth.secrets

local _M = {}

function _M.load(filepath)
	
	local secrets = {}
	local configEnv = {}

	local f,err = loadfile(filepath, "t", configEnv)

	if f then
	   f()
	   secrets.jwt_secret = configEnv.jwt_secret
	else
	   error(err)
	end

	return secrets
end

return _M