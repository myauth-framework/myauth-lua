local iresty_test = require "resty.iresty_test"
local tb = iresty_test.new({unit_name="myauth.secrets-test"})
local cjson = require "cjson"

local test_secrets;

function tb:init(  )
    test_secrets = require "myauth.secrets".load("stuff/test-secrets.lua")
end

function tb:test_should_load_jwt_secret()
   if(test_secrets.jwt_secret ~= "some-secret") then
      error("Jwt secret not found")
   end
end

-- units test
tb:run()