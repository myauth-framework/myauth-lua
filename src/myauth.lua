-- myauth.lua

local url_filters = require "myauth.url-filters"
local anon = require "myauth.anon"
local basic = require "myauth.basic"
local rbac = require "myauth.rbac"

local MyAuth = {}
local mt = { __index = MyAuth }

function MyAuth:authorize()

  local auth_header = ngx.var.http_Authorization
	local host_header = ngx.var.http_Host
  local http_method = ngx.var.request_method;
  local url = ngx.var.request_uri

  self:authorize_core(url, http_method, auth_header, host_header)

  ngx.exit(ngx.OK)
end

function MyAuth:authorize_core(url, http_method, auth_header, host_header)

  if self._auth_config == nil then
    error("MyAuth auth_config was not loaded")
  end

  if self._auth_config.output_schema == "myauth2" or self._auth_config.output_schema == nil then

    self._auth_schema = require "myauth.scheme-v2"

  elseif _auth_config.output_schema == "myauth1" then

    self._auth_schema = require "myauth.scheme-v1"

  else

    error("Output schema not supported")

  end

  if url_filters.check_dont_apply_for(self, url) then
    self._event_listener:on_allow_dueto_dont_apply_for(url)
    return
  end

  if self._auth_config.only_apply_for ~= nil and not url_filters.check_only_apply_for(self, url) then
    self._event_listener:on_allow_dueto_only_apply_for(url)
    return
  end

  if url_filters.check_black_list(self, url) then
    self._event_listener:on_deny_dueto_black_list(url)
    self._ngx_strategy.exit_forbidden("Specified url was found in black list")
  end

  if auth_header == nil then
    anon.check(self, url)
    return
	end

	local _, _, token = string.find(auth_header, "Bearer%s+(.+)")
	if token ~= nil then
  	rbac.check(self, url, http_method, token, host_header)
  	return
	end

	local _, _, basic_cred = string.find(auth_header, "Basic%s+(.+)")
	if basic_cred ~= nil then
  	basic.check(self, url, basic_cred)
  	return
	end

  self._event_listener:on_deny_dueto_unsupported_auth_type(url, auth_header)
  print("Auth header: " .. auth_header)
  self._ngx_strategy.exit_unauthorized("Unsupported authorization type")
end

function MyAuth.new(config, secrets, event_listener, nginx_strategy)

  local new_obj = setmetatable({}, mt)

  new_obj._auth_config = config
  new_obj._ngx_strategy = nginx_strategy or require "myauth.nginx"

  local inner_event_listener = event_listener or require "myauth.empty-event-listener".new()

  new_obj._event_listener = require "myauth.norm-wrapper-event-listener".new(inner_event_listener)

  new_obj._mjwt = require "myauth.jwt"

  new_obj._mjwt.secret = secrets.jwt_secret

  if config.rbac ~= nil then
    new_obj._mjwt.ignore_audience = config.rbac.ignore_audience
  end

  new_obj._ngx_strategy.debug_mode = config.debug_mode

  return new_obj;
end


return MyAuth;
