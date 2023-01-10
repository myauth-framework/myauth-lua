-- norm-wrapper-event-listener.lua

local url_tools = require "myauth.url-tools"

local NormWrapperEventListener = {}
local mt = { __index = NormWrapperEventListener }

local _inner

function NormWrapperEventListener.new(inner)

	local new_obj = setmetatable({}, mt)
	new_obj._inner = inner

  	return new_obj

end

function NormWrapperEventListener:on_allow_dueto_dont_apply_for(url)
	self._inner:on_allow_dueto_dont_apply_for(url_tools.to_url_pattern(url))
end

function NormWrapperEventListener:on_allow_dueto_only_apply_for(url)
	self._inner:on_allow_dueto_only_apply_for(url_tools.to_url_pattern(url))
end

function NormWrapperEventListener:on_deny_dueto_black_list(url)
	self._inner:on_deny_dueto_black_list(url_tools.to_url_pattern(url))
end

function NormWrapperEventListener:on_deny_dueto_unsupported_auth_type(url, auth_header)
	self._inner:on_deny_dueto_unsupported_auth_type(url_tools.to_url_pattern(url), auth_header)
end

function NormWrapperEventListener:on_deny_dueto_no_anon_rules_found(url)
	self._inner:on_deny_dueto_no_anon_rules_found(url_tools.to_url_pattern(url))
end

function NormWrapperEventListener:on_deny_dueto_no_anon_config(url)
	self._inner:on_deny_dueto_no_anon_config(url_tools.to_url_pattern(url))
end

function NormWrapperEventListener:on_allow_anon(url)
	self._inner:on_allow_anon(url_tools.to_url_pattern(url))
end

function NormWrapperEventListener:on_deny_dueto_no_basic_config(url)
	self._inner:on_deny_dueto_no_basic_config(url_tools.to_url_pattern(url))
end

function NormWrapperEventListener:on_deny_dueto_wrong_basic_pass(url, user_id)
	self._inner:on_deny_dueto_wrong_basic_pass(url_tools.to_url_pattern(url), user_id)
end

function NormWrapperEventListener:on_allow_basic(url, user_id)
	self._inner:on_allow_basic(url_tools.to_url_pattern(url), user_id)
end

function NormWrapperEventListener:on_deny_dueto_no_basic_rules_found(url, user_id)
	self._inner:on_deny_dueto_no_basic_rules_found(url_tools.to_url_pattern(url), user_id)
end

function NormWrapperEventListener:on_deny_dueto_no_rbac_config(url)
	self._inner:on_deny_dueto_no_rbac_config(url_tools.to_url_pattern(url))
end

function NormWrapperEventListener:on_deny_no_rbac_rules_found(url, http_method, sub)
	self._inner:on_deny_no_rbac_rules_found(url_tools.to_url_pattern(url), http_method, sub)
end

function NormWrapperEventListener:on_allow_rbac(url, http_method, sub)
	self._inner:on_allow_rbac(url_tools.to_url_pattern(url), http_method, sub)
end

function NormWrapperEventListener:on_deny_rbac_token(url, host, error_code, error_reason)
	self._inner:on_deny_rbac_token(url_tools.to_url_pattern(url), host, error_code, error_reason)
end

return NormWrapperEventListener;