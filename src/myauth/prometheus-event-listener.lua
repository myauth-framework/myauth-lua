
local PriometheusEventListener = {}
local mt = { __index = PriometheusEventListener }

function PriometheusEventListener.new(prometheus)

	local new_obj = setmetatable({}, mt)

  	new_obj.metric_allowed = prometheus:counter("myauth_allow_total", "Number of allowed requests", {"url", "reason"})
	new_obj.metric_denied = prometheus:counter("myauth_deny_total", "Number of denied requests", {"url", "reason"})

  	return new_obj;

end

function PriometheusEventListener:on_allow_dueto_dont_apply_for(url)
	self.metric_allowed:inc(1, {url, 'dont_apply_for'})
end

function PriometheusEventListener:on_allow_dueto_only_apply_for(url)
	self.metric_allowed:inc(1, {url, 'only_apply_for'})
end

function PriometheusEventListener:on_deny_dueto_black_list(url)
	self.metric_denied:inc(1, {url, 'black_list'})
end

function PriometheusEventListener:on_deny_dueto_unsupported_auth_type(url, auth_header)
	self.metric_denied:inc(1, {url, 'unsupported_auth_type'})
end

function PriometheusEventListener:on_deny_dueto_no_anon_rules_found(url)
	self.metric_denied:inc(1, {url, 'no_anon_rules_found'})
end

function PriometheusEventListener:on_deny_dueto_no_anon_config(url)
	self.metric_denied:inc(1, {url, 'no_anon_config'})
end

function PriometheusEventListener:on_allow_anon(url)
	self.metric_allowed:inc(1, {url, 'anon'})
end

function PriometheusEventListener:on_deny_dueto_no_basic_config(url)
	self.metric_denied:inc(1, {url, 'no_basic_config'})
end

function PriometheusEventListener:on_deny_dueto_wrong_basic_pass(url, user_id)
	self.metric_denied:inc(1, {url, 'wrong_basic_pass'})
end

function PriometheusEventListener:on_allow_basic(url, user_id)
	self.metric_allowed:inc(1, {url, 'basic'})
end

function PriometheusEventListener:on_deny_dueto_no_basic_rules_found(url, user_id)
	self.metric_denied:inc(1, {url, 'no_basic_rules_found'})
end

function PriometheusEventListener:on_deny_dueto_no_rbac_config(url)
	self.metric_denied:inc(1, {url, 'no_rbac_config'})
end

function PriometheusEventListener:on_deny_no_rbac_rules_found(url, http_method, sub)
	self.metric_denied:inc(1, {url, 'no_rbac_rules_found'})
end

function PriometheusEventListener:on_allow_rbac(url, http_method, sub)
	self.metric_allowed:inc(1, {url, 'rbac'})
end

function PriometheusEventListener:on_deny_rbac_token(url, host, error_code, error_reason)
	self.metric_denied:inc(1, {url, 'rbac_token_' .. error_code})
end

return PriometheusEventListener;