local iresty_test = require "resty.iresty_test"
local tb = iresty_test.new({unit_name="myauth.claim-str-test"})

local claim_str = require "myauth.claim-str"

function tb:test_should_deserialize_user_id()
	  	
	local str = claim_str.v1_from_user_id("user-id")
	assert(str == "sub=\"user-id\"", "Actual: '".. str .. "'")

end

function tb:test_should_serialize_user_id_from_claims()
	  	
	local claims = {
		sub="user-id"
	} 

	local str = claim_str.v1_from_claims(claims)
	assert(str == "sub=\"user-id\"", "Actual: '".. str .. "'")

end

function tb:test_should_normclaim_value()
	  	
	local claims = {
		sub="user\"id\""
	} 

	local str = claim_str.v1_from_claims(claims)
	assert(str == "sub=\"user\\\"id\\\"\"", "Actual: '".. str .. "'")

end

function tb:test_should_serialize_mutiple_claims_from_claims()
	  	
	local claims = {
		sub="user-id",
		aud="host.ru"
	} 

	local str = claim_str.v1_from_claims(claims)
	assert(str == "aud=\"host.ru\", sub=\"user-id\"" or str == "sub=\"user-id\", aud=\"host.ru\"", "Actual: '".. str .. "'")

end

function tb:test_should_serialize_array()
	  	
	local claims = {
		sub="user-id",
		roles= { "admin", "user" }
	} 

	local str = claim_str.v1_from_claims(claims)
	assert(str == "roles=\"admin,user\", sub=\"user-id\"" or str == "sub=\"user-id\", roles=\"admin,user\"", "Actual: '".. str .. "'")

end

function tb:test_should_convert_upper_camel_case_claim_type_asis()
	  	
	local res = claim_str.claim_type_to_header_name("UpperCamelCaseClaim")
	assert(res == "UpperCamelCaseClaim", "Actual: " .. res)

end

function tb:test_should_convert_lower_camel_case_to_upper_camel_case()
	  	
	local res = claim_str.claim_type_to_header_name("lowerCamelCaseClaim")
	assert(res == "LowerCamelCaseClaim", "Actual: " .. res)

end

function tb:test_should_convert_dash_separated_to_upper_case_with_dash()
	  	
	local res = claim_str.claim_type_to_header_name("claim-with-dashes")
	assert(res == "Claim-With-Dashes", "Actual: " .. res)

end

function tb:test_should_convert_colon_separated_to_upper_case_with_dash()
	  	
	local res = claim_str.claim_type_to_header_name("claim:with:dashes")
	assert(res == "Claim-With-Dashes", "Actual: " .. res)

end

function tb:test_should_convert_string_to_header_val_asis()
	  	
	local res = claim_str.claim_value_to_header_value("foo")
	assert(res == "foo", "Actual: " .. res)

end

function tb:test_should_convert_array_to_header_val()
	  	
	local res = claim_str.claim_value_to_header_value({ "foo", "bar"})
	assert(res == "foo,bar", "Actual: " .. res)

end

-- units test
tb:run()