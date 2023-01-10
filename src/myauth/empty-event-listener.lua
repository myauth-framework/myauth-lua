-- empty-event-listener.lua

local EmptyEventListener = {}
local mt = { __index = EmptyEventListener }

function EmptyEventListener.new()

	local new_obj = setmetatable({}, mt)

  	return new_obj

end

function EmptyEventListener:on_allow_dueto_dont_apply_for(url)
	
end

function EmptyEventListener:on_allow_dueto_only_apply_for(url)
	
end

function EmptyEventListener:on_deny_dueto_black_list(url)
	
end

function EmptyEventListener:on_deny_dueto_unsupported_auth_type(url, auth_header)
	
end

function EmptyEventListener:on_deny_dueto_no_anon_rules_found(url)
	
end

function EmptyEventListener:on_deny_dueto_no_anon_config(url)
	
end

function EmptyEventListener:on_allow_anon(url)
	
end

function EmptyEventListener:on_deny_dueto_no_basic_config(url)
	
end

function EmptyEventListener:on_deny_dueto_wrong_basic_pass(url, user_id)
	
end

function EmptyEventListener:on_allow_basic(url, user_id)
	
end

function EmptyEventListener:on_deny_dueto_no_basic_rules_found(url, user_id)
	
end

function EmptyEventListener:on_deny_dueto_no_rbac_config(url)
	
end

function EmptyEventListener:on_deny_no_rbac_rules_found(url, http_method, sub)
	
end

function EmptyEventListener:on_allow_rbac(url, http_method, sub)
	
end

function EmptyEventListener:on_deny_rbac_token(url, host, error_code, error_reason)
	
end

return EmptyEventListener