-- myauth.claim-str

local _M = {}

local function norm_value(value)

	local norm, _ = string.gsub(value, "\"", "\\\"")
	norm, _ = string.gsub(norm, "\\\\\"", "\\\"")
	return norm;

end

function string:split(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end

function _M.v1_from_user_id(user_id)
	
	return "sub=\"" .. user_id .. "\""

end

function _M.v1_from_claims(claims)
	
	local res_str = ""
	for name, claim in pairs(claims) do
		if res_str ~= "" then
			res_str = res_str .. ", "
		end

		local claim_type = type(claim)
		local claim_value = ""

		if claim_type == "string" then

			claim_value = norm_value(claim)

		elseif claim_type == "table" then

			for name, claim in pairs(claim) do
				if claim_value ~= "" then
					claim_value = claim_value .. ","
				end

				claim_value = claim_value .. norm_value(claim)
			end

		else
			claim_value = "[wrong-value]";
		end


		res_str = res_str .. name .. "=\"" .. claim_value .. "\""
		

	end

	return res_str

end

function _M.claim_type_to_header_name(claim_type)
	
	local res = ""
	local parts1 = claim_type:split('-');

	for i1,v1 in ipairs(parts1) do

		local parts2 = v1:split(':');

		for i2,v2 in ipairs(parts2) do

			local word = v2:sub(1, 1):upper() .. v2:sub(2) 
			if(res == "") then
				res = word
			else
				res = res .. "-" .. word
			end

		end
	end

	return res;

end

function _M.claim_value_to_header_value(claim)
	
	local claim_type = type(claim)
	local claim_value = ""

	if claim_type == "string" then

		claim_value = norm_value(claim)

	elseif claim_type == "table" then

		for name, claim in pairs(claim) do
			if claim_value ~= "" then
				claim_value = claim_value .. ","
			end

			claim_value = claim_value .. norm_value(claim)
		end

	else
		claim_value = "[wrong-value]";
	end

	return claim_value

end

return _M