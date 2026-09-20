local iresty_test = require "resty.iresty_test"
local tb = iresty_test.new({unit_name="myauth.readonly"})

local admin_rbac_header = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJNeUF1dGguT0F1dGhQb2ludCIsInN1YiI6IjBjZWMwNjdmOGRhYzRkMTg5NTUxMjAyNDA2ZTQxNDdjIiwiZXhwIjo3NTY4NDcyMDI0LjAyNjUwMiwiYXVkIjoidGVzdC5ob3N0LnJ1Iiwicm9sZXMiOlsiQWRtaW4iXSwibXlhdXRoOmNsaW1lIjoiQ2xpbWVWYWwifQ.KUM0RXlvphoDHQPvLZD3E1HwVVZoejSm5kfrOSsIrEg"
local ro_admin_rbac_header = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJNeUF1dGguT0F1dGhQb2ludCIsInN1YiI6IjBjZWMwNjdmOGRhYzRkMTg5NTUxMjAyNDA2ZTQxNDdjIiwiZXhwIjo3NTY4NDcyMDI0LjAyNjUwMiwiYXVkIjoidGVzdC5ob3N0LnJ1Iiwicm9sZXMiOlsiQWRtaW4iLCJteWF1dGg6cm8iXSwibXlhdXRoOmNsaW1lIjoiQ2xpbWVWYWwifQ.jsNei2b0rOldhhRkb-1h-Sm2WhFMNpLe80KpHgFL8TQ"

local host = "test.host.ru"

local debug_mode = false

function tb:init(  )
end

local function create_myauth(config) 

  local ngx_strategy = require "stuff.myauth-test-nginx";
  local secrets = { jwt_secret="qwerty" }
  local event_listener = nil

  if(debug_mode) then
    event_listener = require "stuff.test-event-listener"
  end
  
  return require "myauth".new(config, secrets, event_listener, ngx_strategy)
end

local function should_error(m, ...)
  local v, err = pcall(m.authorize_core, m, ...)
  if v then
      error("No expected error")
   else
      if debug_mode then
        print("Actual error: " .. err)
      end
   end
end

local function should_pass_rbac(m, ...)

  local v, err = pcall(m.authorize_core, m, ...);
  if not v then
    if m._ngx_strategy.debug_rbac_info ~= nil then
      error("Error: " .. err .. ". Debug: " .. m._ngx_strategy.debug_rbac_info)
    else
      error("Error: " .. err)
    end
  end
end

function tb:test_should_pass_when_ro_and_get_resource()

  local config = {
    debug_mode=debug_mode,
    rbac = {
      rules = {
        {
          url = "/bearer-access",
          allow_for_all = true
        }
      }
    }
  }
  local m = create_myauth(config)
  should_pass_rbac(m, "/bearer-access", "GET", ro_admin_rbac_header, host)

end

function tb:test_should_fail_when_ro_and_notget()

  local config = {
    debug_mode=debug_mode,
    rbac = {
      rules = {
        {
          url = "/bearer-access",
          allow_for_all = true
        }
      }                                      
    }
  }
  local m = create_myauth(config)
  should_error(m, "/bearer-access", "POST", ro_admin_rbac_header, host)

end

function tb:test_should_pass_when_ro_and_whitelist_and_post()

  local config = {
    debug_mode=debug_mode,
    rbac = {
      rules = {
        {
          url = "/bearer-access",
          allow_for_all = true
        }
      },
      ro_white_list = {
        "/bearer-access"
      }
    }
  }
  local m = create_myauth(config)
  should_pass_rbac(m, "/bearer-access", "POST", ro_admin_rbac_header, host)

end

function tb:test_should_fail_when_ro_and_whitelist_and_put()

  local config = {
    debug_mode=debug_mode,
    rbac = {
      rules = {
        {
          url = "/bearer-access",
          allow_for_all = true
        }
      }                                      
    }
  }
  local m = create_myauth(config)
  should_error(m, "/bearer-access", "PUT", ro_admin_rbac_header, host)

end

function tb:test_should_fail_when_ro_and_whitelist_and_patch()

  local config = {
    debug_mode=debug_mode,
    rbac = {
      rules = {
        {
          url = "/bearer-access",
          allow_for_all = true
        }
      }                                      
    }
  }
  local m = create_myauth(config)
  should_error(m, "/bearer-access", "PATCH", ro_admin_rbac_header, host)

end

function tb:test_should_fail_when_ro_and_whitelist_and_delete()

  local config = {
    debug_mode=debug_mode,
    rbac = {
      rules = {
        {
          url = "/bearer-access",
          allow_for_all = true
        }
      }                                      
    }
  }
  local m = create_myauth(config)
  should_error(m, "/bearer-access", "DELETE", ro_admin_rbac_header, host)

end

-- units test
tb:run()