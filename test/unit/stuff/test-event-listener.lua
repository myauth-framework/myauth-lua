-- test-event-listener.lua

local TestEventListener = {}
local mt = { __index = TestEventListener }

function TestEventListener:new()

	local new_obj = setmetatable({}, mt)

  	return new_obj;

end


function TestEventListener:on_allow_dueto_dont_apply_for(url)
	print('Event listener (on_allow_dueto_dont_apply_for): ' .. url)
end

function TestEventListener:on_allow_dueto_only_apply_for(url)
	print('Event listener (on_allow_dueto_only_apply_for): ' .. url)
end

function TestEventListener:on_deny_dueto_black_list(url)
	print('Event listener (on_deny_dueto_black_list): ' .. url)
end

function TestEventListener:on_deny_dueto_unsupported_auth_type(url, auth_header)
	print('Event listener (on_deny_dueto_unsupported_auth_type): ' .. url .. '; auth_header = ' .. auth_header)
end

function TestEventListener:on_deny_dueto_no_anon_rules_found(url)
	print('Event listener (on_deny_dueto_no_anon_rules_found): ' .. url)
end

function TestEventListener:on_deny_dueto_no_anon_config(url)
	print('Event listener (on_deny_dueto_no_anon_config): ' .. url)
end

function TestEventListener:on_allow_anon(url)
	print('Event listener (on_allow_anon): ' .. url)
end

function TestEventListener:on_deny_dueto_no_basic_config(url)
	print('Event listener (on_deny_dueto_no_basic_config): ' .. url)
end

function TestEventListener:on_deny_dueto_wrong_basic_pass(url, user_id)
	print('Event listener (on_deny_dueto_wrong_basic_pass): ' .. url .. '; user_id = ' .. user_id)
end

function TestEventListener:on_allow_basic(url, user_id)
	print('Event listener (on_allow_basic): ' .. url .. '; user_id = ' .. user_id)
end

function TestEventListener:on_deny_dueto_no_basic_rules_found(url, user_id)
	print('Event listener (on_deny_dueto_no_basic_rules_found): ' .. url .. '; user_id = ' .. user_id)
end

function TestEventListener:on_deny_dueto_no_rbac_config(url)
	print('Event listener (on_deny_dueto_no_rbac_config): ' .. url)
end

function TestEventListener:on_deny_no_rbac_rules_found(url, http_method, sub)
	print('Event listener (on_deny_no_rbac_rules_found): ' .. url .. '; http_method = ' .. http_method .. '; sub = ' .. sub)
end

function TestEventListener:on_allow_rbac(url, http_method, sub)
	print('Event listener (on_allow_rbac): ' .. url .. '; http_method = ' .. http_method .. '; sub = ' .. sub)
end

function TestEventListener:on_deny_rbac_token(url, host, error_code, error_reason)
	print('Event listener (on_deny_rbac_token): ' .. url .. '; host = ' .. host .. '; error_code = ' .. error_code .. '; error_reason = ' .. error_reason)
end

return TestEventListener;