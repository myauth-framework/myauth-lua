local iresty_test = require "resty.iresty_test"
local tb = iresty_test.new({unit_name="myauth.url-tools-test"})
local cjson = require "cjson"

local url_tools = require "myauth.url-tools"

function tb:init(  )
    
end

function tb:test_should_detect_exact_url()
   if not url_tools.check_url("/some/url/", "/some/url/") then
      error("Url mistmatch")
   end
end

function tb:test_should_not_detect_exact_url_when_mistmatch()
   if url_tools.check_url("/some/wrong_url/", "/some/url/") then
      error("Comparison error")
   end
end

function tb:test_should_detect_sub_url()
   if not url_tools.check_url("/some/url/sub", "/some/url/") then
      error("Url mistmatch")
   end
end

function tb:test_should_detect_by_pattern()
   if not url_tools.check_url("/some/url-1/sub", "/some/url-[%d]+/") then
      error("Url mistmatch")
   end
end

function tb:test_should_not_detect_by_pattern_when_mistmatch()
   if url_tools.check_url("/some/wrong_url/", "/some/url-[%d]+/") then
      error("Comparison error")
   end
end

function tb:test_should_calc_rate()

	local test_url = "/some/url/1"
	local _, rate1 = url_tools.check_url_rate(test_url, "/some/url/")
	local _, rate2 = url_tools.check_url_rate(test_url, "/some/url/1")

   if rate2 <= rate1 then
      error("Rate calculation error")
   end
end

-- units test
tb:run()