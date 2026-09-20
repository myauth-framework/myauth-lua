local iresty_test = require "resty.iresty_test"
local tb = iresty_test.new({unit_name="myauth.basic"})

local user1_basic_header = "Basic dXNlci0xOnBhc3N3b3Jk"
local user2_basic_header = "Basic dXNlci0yOnBhc3N3b3Jk"

local debug_mode = false

local function create_myauth(config)

  local ngx_strategy = require "stuff.myauth-test-nginx";
  local event_listener = nil
  
  if(debug_mode) then
    event_listener = require "stuff.test-event-listener"
  end
  
  return require "myauth".new(config, {}, event_listener, ngx_strategy)
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
  local m = create_myauth(config)
  m:authorize_core("/basic-access-1", "GET", user1_basic_header)
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
  local m = create_myauth(config)
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
  local m = create_myauth(config)
  should_error(m, "/basic-access-notdigit", "GET", user2_basic_header)
end

-- units test
tb:run()