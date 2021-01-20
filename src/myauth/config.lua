-- myauth.config

local _M = {}

_M.dirsep = package.config:sub(1,1)

rawset(_G, 'lfs', false) 
require "lfs"

local function merge_arrays(base, cfg)

	if(base == nil) then
		return cfg
	else

		local new_list = {}

		for _,v in ipairs(base) do 
	      table.insert(new_list, v)
	    end

	    if(cfg ~= nil) then
		    for _,v in ipairs(cfg) do 
		      table.insert(new_list, v)
		    end
		end

	    return new_list
	end

end

local function merge_rbac(base_rbac, cfg_rbac)

	local res = {}

	if(base_rbac == nil) then
		res = cfg_rbac
	else

		res.rules = merge_arrays(base_rbac.rules, cfg_rbac.rules)

		if (base_rbac.ignore_audience == nil) then
		   	if (cfg_rbac.ignore_audience == nil) then
		   		res.ignore_audience = false
		   	else
		   		res.ignore_audience = cfg_rbac.ignore_audience
		   	end
		end

	end

	return res;
end

local function listfiles(dir)
    local list = {}
    
    for entry in lfs.dir(dir) do
      if entry ~= "." and entry ~= ".." then
        local ne = dir .. _M.dirsep .. entry
        if lfs.attributes(ne).mode ~= 'directory' then
          table.insert(list,ne)
        end
      end
    end
      
    return list
  end

function _M.load(filepath, baseConfig)
	local configEnv = {}

	local resConfig

	if(baseConfig == nil) then
		resConfig = {}
	else
		resConfig = baseConfig
	end


	local f,err = loadfile(filepath, "t", configEnv)

	if f then
		f()

	   	if(resConfig.debug_mode == nil) then
	   		resConfig.debug_mode = configEnv.debug_mode
		end
		if(resConfig.output_scheme == nil) then
	   		resConfig.output_scheme = configEnv.output_scheme
	   	end

	   	resConfig.rbac = merge_rbac(resConfig.rbac, configEnv.rbac)
	   	resConfig.dont_apply_for = merge_arrays(resConfig.dont_apply_for, configEnv.dont_apply_for)
	   	resConfig.only_apply_for = merge_arrays(resConfig.only_apply_for, configEnv.only_apply_for)
	   	resConfig.anon = merge_arrays(resConfig.anon, configEnv.anon)
	   	resConfig.black_list = merge_arrays(resConfig.black_list, configEnv.black_list)
	   	resConfig.basic = merge_arrays(resConfig.basic, configEnv.basic)

	else
	   error(err)
	end

	return resConfig
end

function _M.load_dir(dirpath)
	
	local config = nil

	for _,n in ipairs(listfiles(dirpath)) do
	    
		config = _M.load(n, config)

  	end

  	return config

end

return _M