local iresty_test = require "resty.iresty_test"
local tb = iresty_test.new({unit_name="myauth-test"})
local cjson = require "cjson"

local user1_basic_header = "Basic dXNlci0xOnBhc3N3b3Jk"
local user2_basic_header = "Basic dXNlci0yOnBhc3N3b3Jk"

local admin_rbac_header = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJNeUF1dGguT0F1dGhQb2ludCIsInN1YiI6IjBjZWMwNjdmOGRhYzRkMTg5NTUxMjAyNDA2ZTQxNDdjIiwiZXhwIjo3NTY4NDcyMDI0LjAyNjUwMiwiYXVkIjoidGVzdC5ob3N0LnJ1Iiwicm9sZXMiOlsiQWRtaW4iXSwibXlhdXRoOmNsaW1lIjoiQ2xpbWVWYWwifQ.KUM0RXlvphoDHQPvLZD3E1HwVVZoejSm5kfrOSsIrEg"
local admin_rbac_header_wrong_sign = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJNeUF1dGguT0F1dGhQb2ludCIsInN1YiI6IjBjZWMwNjdmOGRhYzRkMTg5NTUxMjAyNDA2ZTQxNDdjIiwiZXhwIjo3NTY4NDcyMDI0LjAyNjUwMiwiYXVkIjoidGVzdC5ob3N0LnJ1Iiwicm9sZXMiOlsiQWRtaW4iXSwibXlhdXRoOmNsaW1lIjoiQ2xpbWVWYWwifQ.sYgnefh7qS0BxfrLNvOeEyzyL9SqumXKywXjwm60ecY"
local notadmin_rbac_header = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJNeUF1dGguT0F1dGhQb2ludCIsInN1YiI6IjBjZWMwNjdmOGRhYzRkMTg5NTUxMjAyNDA2ZTQxNDdjIiwiZXhwIjo3NTY4NDcyMDI0LjAyNjUwMiwiYXVkIjoidGVzdC5ob3N0LnJ1Iiwicm9sZXMiOlsiVXNlciJdLCJteWF1dGg6Y2xpbWUiOiJDbGltZVZhbCJ9.flQg_Vwbk2cemeKyiI-L7vodfLWln1fWpjxat6w_c6A"

local host = "test.host.ru"
local wrong_host = "test.wrong-host.ru"

local debug_mode = false

local function create_m(config)
  local m = require "myauth"
  m.strategy = require "stuff.myauth-test-nginx" 
  m.strategy.debug_mode = debug_mode

  if(debug_mode) then
    m.event_listener = require "stuff.test-event-listener"
  end

  local secrets = { jwt_secret="qwerty" }

  m.initialize(config, secrets)
  return m
end

local function should_error(m, ...)
  local v, err = pcall(m.authorize_core, ...)
  if v then
      error("No expected error")
   else
      if debug_mode then
        print("Actual error: " .. err)
      end
   end
end

local function should_pass_rbac(m, ...)
  local v, err = pcall(m.authorize_core, ...);
  if not v then
    error("Error: " .. err .. ". Debug: " .. m.strategy.debug_rbac_info)
  end
end

function tb:init(  )
end

function tb:test_should_pass_anon()
  local config = {
    debug_mode=debug_mode,
    anon = { "/foo" }
  }
  local m = create_m(config)
  m.authorize_core("/foo")
end

function tb:test_should_fail_anon_if_url_not_defined()
  local config = {
    debug_mode=debug_mode,
    anon = { "/foo" }
  }
  local m = create_m(config)
  should_error(m, "/bar")
end

function tb:test_should_pass_basic()
  local config = {
    debug_mode=debug_mode,
    basic = {
      {
        id="user-1",
        pass="password",
        urls = {"/basic-access-[%d]+"}
      }
    },
  }
  local m = create_m(config)
  m.authorize_core("/basic-access-1", "GET", user1_basic_header)
end

function tb:test_should_fail_basic_if_url_not_defined()
  local config = {
    debug_mode=debug_mode,
    basic = {
      {
        id="user-1",
        pass="password",
        urls = {"/basic-access-[%d]+"}
      }
    },
  }
  local m = create_m(config)
  should_error(m, "/basic-access-notdigit", "GET", user1_basic_header)
end

function tb:test_should_fail_basic_if_wrong_user_defined()
  local config = {
    debug_mode=debug_mode,
    basic = {
      {
        id="user-1",
        pass="password",
        urls = {"/basic-access-[%d]+"}
      }
    },
  }
  local m = create_m(config)
  should_error(m, "/basic-access-notdigit", "GET", user2_basic_header)
end

function tb:test_should_pass_rbac()
  local config = {
    debug_mode=debug_mode,
    rbac = {
      rules = {
        {
          url = "/bearer-access-[%d]+",
          allow = { "Admin" } 
        }
      }
    }
  }
  local m = create_m(config)
  should_pass_rbac(m, "/bearer-access-1", "GET", admin_rbac_header, host)
end

function tb:test_should_pass_rbac_for_spetial_method()
  local config = {
    debug_mode=debug_mode,
    rbac = {
      rules = {
        {
          url = "/bearer-access-[%d]+",
          allow_post = { "Admin" } 
        }
      }
    }
  }
  local m = create_m(config)
  should_pass_rbac(m, "/bearer-access-1", "POST", admin_rbac_header, host)
end

function tb:test_should_fail_rbac_if_url_not_defined()
  local config = {
    debug_mode=debug_mode,
    rbac = {
      rules = {
        {
          url = "/bearer-access-[%d]+",
          allow = { "Admin" } 
        }
      }
    }
  }
  local m = create_m(config)
  should_error(m, "/bearer-access-notdigit", "GET", admin_rbac_header, host)
end

function tb:test_should_fail_rbac_if_role_absent()
  local config = {
    debug_mode=debug_mode,
    rbac = {
      rules = {
        {
          url = "/bearer-access-[%d]+",
          allow = { "Admin" } 
        }
      }
    }
  }
  local m = create_m(config)
  should_error(m, "/bearer-access-1", "GET", notadmin_rbac_header, host)
end

function tb:test_should_fail_rbac_if_wrong_host()
  local config = {
    debug_mode=debug_mode,
    rbac = {
      rules = {
        {
          url = "/bearer-access-[%d]+",
          allow = { "Admin" } 
        }
      }
    }
  }
  local m = create_m(config)
  should_error(m, "/bearer-access-1", "GET", admin_rbac_header, wrong_host)
end

function tb:test_should_fail_rbac_if_wrong_sign()

  local config = {
    debug_mode=debug_mode,
    rbac = {
      rules = {
        {
          url = "/bearer-access-[%d]+",
          allow = { "Admin" } 
        }
      }
    }
  }
  local m = create_m(config)
  should_error(m, "/bearer-access-1", "GET", admin_rbac_header_wrong_sign, host)
end

function tb:test_should_fail_rbac_if_in_black_list()

  local config = {
    debug_mode=debug_mode,
    black_list = {
      "/"
    },
    rbac = {
      rules = {
        {
          url = "/bearer-access-[%d]+",
          allow = { "Admin" } 
        }
      }
    }
  }
  local m = create_m(config)
  should_error(m, "/bearer-access-1", "GET", admin_rbac_header, host)
end

function tb:test_should_dont_authorize_when_in_dont_apply_for()
  local config = {
    debug_mode=debug_mode,
    dont_apply_for = {
      "/"
    },
    only_apply_for = {
      "/"
    },
    rbac = {
      rules = {
        {
          url = "/bearer-access-[%d]+",
          allow = { "Admin" } 
        }
      }
    }
  }
  local m = create_m(config)
  should_pass_rbac(m, "/bearer-access-nodigit", "GET", admin_rbac_header, host)
end

function tb:test_should_dont_authorize_when_not_in_only_apply_for()
  local config = {
    debug_mode=debug_mode,
    only_apply_for = {
      "/apply-for-this"
    },
    rbac = {
      rules = {
        {
          url = "/bearer-access-[%d]+",
          allow = { "Admin" } 
        }
      }
    }
  }
  local m = create_m(config)
  should_pass_rbac(m, "/bearer-access-nodigit", "GET", admin_rbac_header, host)
end

function tb:test_should_pass_when_allow_for_all()
  local config = {
    debug_mode=debug_mode,
    rbac = {
      rules = {
        {
          url = "/bearer-access-[%d]+",
          allow_for_all=true
        }
      }
    }
  }
  local m = create_m(config)
  should_pass_rbac(m, "/bearer-access-1", "GET", admin_rbac_header, host)
end

-- units test
tb:run()