local iresty_test = require "resty.iresty_test"
local tb = iresty_test.new({unit_name="myauth.jwt-test"})

local token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJNeUF1dGguT0F1dGhQb2ludCIsInN1YiI6IjBjZWMwNjdmOGRhYzRkMTg5NTUxMjAyNDA2ZTQxNDdjIiwiZXhwIjo3NTY4NDcyMDI0LjAyNjUwMiwicm9sZXMiOlsicm9vdCIsIkFkbWluIl0sIm15YXV0aDpjbGltZSI6IkNsaW1lVmFsIn0.u2d7kkDW6MrZLZP48GMeyiOusrp0wNr-1AMC4LBTl6g"
local wrong_token = "babla"
local host = "test.host.ru"

local debug_mode = false

local function create_m()
   local m = require "myauth.jwt"

   m.strategy = require "stuff.myauth-test-nginx"
   m.secret = "qwerty"
   m.strategy.debug_mode = debug_mode

   return m;
end

function tb:init(  )
   
end

function tb:test_should_not_authorize_wrong_token()

   local m = create_m()
   local v, err = pcall(m.authorize, wrong_token)
   
   if v then
      error("No expected error")
   else
      if debug_mode then
         print("Actual error: " .. err)
      end
   end
end

function tb:test_should_not_authorize_wrong_secret()

   local m = create_m()
   m.secret = "wrong_secret"

   local v, err = pcall(m.authorize, token);

   if v then
      error("No expected error")
   else
      if debug_mode then
         print("Actual error: " .. err)
      end
   end
end

function tb:test_should_provide_roles()

   local m = create_m()
   local token_obj = m.authorize(token, host)
   local roles = m.get_token_roles(token_obj)

   for _, v in ipairs(roles) do
     if v == "Admin" then
         return
     end
   end
   error("Role Admin not found")
end

-- units test
tb:run()