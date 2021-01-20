local iresty_test = require "resty.iresty_test"
local tb = iresty_test.new({unit_name="myauth.script-based-integration-test"})
local prettyjson = require "resty.prettycjson"

local http = require('socket.http')	

local user1_rbac_header = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJNeUF1dGguT0F1dGhQb2ludCIsInN1YiI6IjBjZWMwNjdmOGRhYzRkMTg5NTUxMjAyNDA2ZTQxNDdjIiwiZXhwIjo3NTY4NDcyMDI0LjAyNjUwMiwiYXVkIjoidGVzdC5ob3N0LnJ1Iiwicm9sZXMiOlsiVXNlcjEiXSwibXlhdXRoOmNsaW1lIjoiQ2xpbWVWYWwifQ.l4XBPKoVe40NvyHIK5vZkYFo1wZrr4ZZyJaVwQmapVM"
local user2_rbac_header = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJNeUF1dGguT0F1dGhQb2ludCIsInN1YiI6IjBjZWMwNjdmOGRhYzRkMTg5NTUxMjAyNDA2ZTQxNDdjIiwiZXhwIjo3NTY4NDcyMDI0LjAyNjUwMiwiYXVkIjoidGVzdC5ob3N0LnJ1Iiwicm9sZXMiOlsiVXNlcjIiXSwibXlhdXRoOmNsaW1lIjoiQ2xpbWVWYWwifQ.lsDQCGiKFUKyyJu3sdtVXAvGwgk7tMQDWPVF5Bt0WE0"

local host = "test.host.ru"

local debug_mode = false

function check_code(actual_code, expected_code)
	if(actual_code ~= expected_code) then
		error('Met unexpected response status code: "' ..  actual_code .. '". But expected is "' .. expected_code .. '"')
	end
end

function check_url(path, expected_code, auth_header, method)

	local resp = {}
	local body, code, headers, status = http.request {

		method = method,
		url = "http://myauth-lua-test-server/" .. path,
		headers = {
			Authorization = auth_header
		},
		sink = ltn12.sink.table(resp) 
	}

	local l_status = status or '[empty]'

	if (debug_mode) then
		print('')
		print('Response: ' .. l_status)
		print('')
		print(prettyjson(headers))
		print('')
		print(prettyjson(resp))
	end

	check_code(code, expected_code)
end

function tb:init(  )
end

function tb:test_should_allow_for_non_auth_path()
	check_url("blocked", 200)
end

function tb:test_should_allow()
	check_url("rbac-access-123", 200, user1_rbac_header)
end

function tb:test_should_deny_if_rbac_rule_not_found()
	check_url("rbac-access-123", 403, user2_rbac_header)
end

-- units test
tb:run()