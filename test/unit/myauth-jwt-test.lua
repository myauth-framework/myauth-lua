local iresty_test = require "resty.iresty_test"
local tb = iresty_test.new({unit_name="myauth.jwt-test"})

local token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJNeUF1dGguT0F1dGhQb2ludCIsInN1YiI6IjBjZWMwNjdmOGRhYzRkMTg5NTUxMjAyNDA2ZTQxNDdjIiwiZXhwIjo3NTY4NDcyMDI0LjAyNjUwMiwicm9sZXMiOlsicm9vdCIsIkFkbWluIl0sIm15YXV0aDpjbGltZSI6IkNsaW1lVmFsIn0.u2d7kkDW6MrZLZP48GMeyiOusrp0wNr-1AMC4LBTl6g"
local foo_aud_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJNeUF1dGguT0F1dGhQb2ludCIsInN1YiI6IjBjZWMwNjdmOGRhYzRkMTg5NTUxMjAyNDA2ZTQxNDdjIiwiZXhwIjo3NTY4NDcyMDI0LjAyNjUwMiwicm9sZXMiOlsicm9vdCIsIkFkbWluIl0sImF1ZCI6ImZvbyIsIm15YXV0aDpjbGltZSI6IkNsaW1lVmFsIn0.g0Xbbt_2-INzp4JigXXaHXTGlXgKhlj9Ar_X31gtkHc"
local foobar_aud_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJNeUF1dGguT0F1dGhQb2ludCIsInN1YiI6IjBjZWMwNjdmOGRhYzRkMTg5NTUxMjAyNDA2ZTQxNDdjIiwiZXhwIjo3NTY4NDcyMDI0LjAyNjUwMiwicm9sZXMiOlsicm9vdCIsIkFkbWluIl0sImF1ZCI6WyJmb28iLCJiYXIiXSwibXlhdXRoOmNsaW1lIjoiQ2xpbWVWYWwifQ.fUpsMl4ctj2Ab-M2Ey89RCOxeH2WI92JaV75jci6r2E"
local wrong_token = "babla"
local regex_foo_aud_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJNeUF1dGguT0F1dGhQb2ludCIsInN1YiI6IjBjZWMwNjdmOGRhYzRkMTg5NTUxMjAyNDA2ZTQxNDdjIiwiZXhwIjo3NTY4NDcyMDI0LjAyNjUwMiwicm9sZXMiOlsicm9vdCIsIkFkbWluIl0sImF1ZCI6ImYlbCVsIiwibXlhdXRoOmNsaW1lIjoiQ2xpbWVWYWwifQ.5wYHDitqkoK9eWqiR2ahaI8lQinvcfkIFZDJ2IZpoS4"
local regex_foobar_aud_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJNeUF1dGguT0F1dGhQb2ludCIsInN1YiI6IjBjZWMwNjdmOGRhYzRkMTg5NTUxMjAyNDA2ZTQxNDdjIiwiZXhwIjo3NTY4NDcyMDI0LjAyNjUwMiwicm9sZXMiOlsicm9vdCIsIkFkbWluIl0sImF1ZCI6WyJmJWwlbCIsImIlbHIiXSwibXlhdXRoOmNsaW1lIjoiQ2xpbWVWYWwifQ.HO6a3AeTJAdG8N8iZkd94T9ql2bqANsk2CBvSpznBh4"

local debug_mode = false

-- local cjson = require "cjson"

local function create_m()
   local m = require "myauth.jwt"
   m.secret = "qwerty"
   return m;
end

function tb:init(  )
   
end

function tb:test_should_not_authorize_wrong_token()

   local m = create_m()
   local t, error_code, error_reason = m.authorize(wrong_token)
   
   if (error_code ~= 'invalid_token_format') then
      error("No expected error. Actual: " .. (error_code or "[nil]"))
   else
      if debug_mode then
         print("Actual error: " .. error_code ..  "; " .. error_reason)
      end
   end
end

function tb:test_should_not_authorize_wrong_secret()

   local m = create_m()
   m.secret = "wrong_secret"

   local  t, error_code, error_reason = m.authorize(token)
   
   if (error_code ~= 'invalid_token_sign') then
      error("No expected error Actual: " .. (error_code or "[nil]"))
   else
      if debug_mode then
         print("Actual error: " .. error_code ..  "; " .. error_reason)
      end
   end
end

function tb:test_should_provide_roles()

   local m = create_m()
   local token_obj, error_code, error_reason = m.authorize(token, nil)

   if (error_code ~= nil) then
      error("Unexpected error. Actual: " .. (error_code or "[nil]") .. "; " .. error_reason)
   end

   local roles = m.get_token_roles(token_obj)

   for _, v in ipairs(roles) do
     if (v == "Admin") then
         return
     end
   end
   error("Role Admin not found")
end

function tb:test_shoud_pass_when_noaud_in_token()

   local m = create_m()
   local token_obj, error_code, error_reason = m.authorize(token, nil)

   if (error_code ~= nil) then
      error("Unexpected error. Actual: " .. (error_code or "[nil]") .. "; " .. error_reason)
   end

end

function tb:test_shoud_pass_when_aud_match()

   local m = create_m()
   local token_obj, error_code, error_reason = m.authorize(foo_aud_token, "foo")

   if (error_code ~= nil) then
      error("Unexpected error. Actual: " .. (error_code or "[nil]") .. "; " .. error_reason)
   end
   
end

function tb:test_shoud_pass_when_aud_match_regex()

   local m = create_m()
   local token_obj, error_code, error_reason = m.authorize(regex_foo_aud_token, "foo")

   if (error_code ~= nil) then
      error("Unexpected error. Actual: " .. (error_code or "[nil]") .. "; " .. error_reason)
   end
   
end

function tb:test_shoud_pass_when_aud_contains_regex1()

   local m = create_m()
   local token_obj, error_code, error_reason = m.authorize(regex_foobar_aud_token, "foo")

   if (error_code ~= nil) then
      error("Unexpected error. Actual: " .. (error_code or "[nil]") .. "; " .. error_reason)
   end
   
end

function tb:test_shoud_pass_when_aud_contains_regex2()

   local m = create_m()
   local token_obj, error_code, error_reason = m.authorize(regex_foobar_aud_token, "bar")

   if (error_code ~= nil) then
      error("Unexpected error. Actual: " .. (error_code or "[nil]") .. "; " .. error_reason)
   end
   
end

function tb:test_shoud_pass_when_aud_contains1()

   local m = create_m()
   local token_obj, error_code, error_reason = m.authorize(foobar_aud_token, "foo")

   if (error_code ~= nil) then
      error("Unexpected error. Actual: " .. (error_code or "[nil]") .. "; " .. error_reason)
   end
   
end

function tb:test_shoud_pass_when_aud_contains2()

   local m = create_m()
   local token_obj, error_code, error_reason = m.authorize(foobar_aud_token, "bar")

   if (error_code ~= nil) then
      error("Unexpected error. Actual: " .. (error_code or "[nil]") .. "; " .. error_reason)
   end
   
end

function tb:test_shoud_fail_when_aud_not_match()

   local m = create_m()
   local token_obj, error_code, error_reason = m.authorize(foo_aud_token, "baz")

   if (error_code ~= 'invalid_audience') then
      error("No expected error. Actual: " .. (error_code or "[nil]"))
   else
      if debug_mode then
         print("Actual error: " .. error_code ..  "; " .. error_reason)
      end
   end
   
end

function tb:test_shoud_fail_when_aud_not_contains()

   local m = create_m()
   local token_obj, error_code, error_reason = m.authorize(foobar_aud_token, "baz")

   if (error_code ~= 'invalid_audience') then
      error("No expected error. Actual: " .. (error_code or "[nil]"))
   else
      if debug_mode then
         print("Actual error: " .. error_code ..  "; " .. error_reason)
      end
   end
   
end

-- units test
tb:run()