local iresty_test = require "resty.iresty_test"
local tb = iresty_test.new({unit_name="myauth.config-test"})
local cjson = require "cjson"

local m
local m_merge

local config_module = require "myauth.config"

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function tb:init(  )
    m = config_module.load("stuff/test-config.lua")

    m_merge = config_module.load("stuff/test-config.lua")
    m_merge = config_module.load("stuff/test-config-2.lua", m_merge)
end

function tb:test_should_not_merge_debug_mode()
   if(m_merge.anon == false) then
      error("Debug mode was overriden (false)")
   end
   if(m_merge.anon == nil) then
      error("Debug mode was overriden (nil)")
   end
end

function tb:test_should_not_merge_output_scheme()
   if(m_merge.output_scheme == 'blabla') then
      error("Output scheme was overriden")
   end
end

function tb:test_should_not_merge_ignore_audience()
   if(m_merge.rbac.ignore_audience == false) then
      error("Rbac ignore_audience was overriden (false)")
   end
end

function tb:test_should_merge_dont_apply_for_list()

  if(not has_value(m_merge.dont_apply_for, '/free_for_access_new') or not has_value(m_merge.dont_apply_for, '/free_for_access')) then
    error("Wrong dont_apply_for merge")
  end

end

function tb:test_should_merge_only_apply_for_list()
  
  if(not has_value(m_merge.only_apply_for, '/new') or not has_value(m_merge.only_apply_for, '/')) then
    error("Wrong only_apply_for merge")
  end

end

function tb:test_should_merge_black_list()
  
  if(not has_value(m_merge.black_list, '/blocked_new') or not has_value(m_merge.black_list, '/blocked')) then
    error("Wrong blocked_new merge")
  end

end

function tb:test_should_merge_anon_list()
  
  if(not has_value(m_merge.anon, '/pub_new') or not has_value(m_merge.anon, '/pub')) then
    error("Wrong anon merge")
  end

end

function tb:test_should_merge_basic()
  
  local has_old  = false
  local has_new  = false

  for _, v in ipairs(m_merge.basic) do
      if (v.id == 'user-1') then
          has_old = true
      end
  end

  for _, v in ipairs(m_merge.basic) do
      if (v.id == 'user-3') then
          has_new = true
      end
  end

  if(not has_old or not has_new) then
    error("Wrong basic merge")
  end

end

function tb:test_should_merge_rbac_rules()
  
  local has_old  = false
  local has_new  = false

  for _, v in ipairs(m_merge.rbac.rules) do
      if (v.url == '/rbac-access-2') then
          has_old = true
      end
  end

  for _, v in ipairs(m_merge.rbac.rules) do
      if (v.url == '/rbac-access-new') then
          has_new = true
      end
  end

  if(not has_old or not has_new) then
    error("Wrong rbac.rules merge")
  end

end

function tb:test_should_load_anon()
   if(m.anon == nil) then
      error("Anon settings not found")
   end

   -- print("Anon object: " .. cjson.encode(m.anon))

   if(not has_value(m.anon, "/pub"))then
      error("Anon item not found")
   end
end

function tb:test_should_load_basic()
   if(m.basic == nil) then
      error("Basic auth settings not found")
   end

   --print("Basic object: " .. cjson.encode(m.basic))

   local first = m.basic[1]
   if(first == nil) then
      error("Basic users not found")
   end
   if(first.id ~= "user-1") then
      error("Basic users's id not loaded")
   end
   if(first.pass ~= "user-1-pass") then
      error("Basic users's password not loaded")
   end
   if(first.urls == nil or first.urls[1] == nil) then
      error("Basic user's urls not loaded")
   end
   if(first.urls[1] ~= "/basic-access-[%d]+" or first.urls[2] ~= "/basic-access-a") then
      error("Basic usesr's urls loaded incorrectly")
   end
end

function tb:test_should_load_rbac()
   if(m.rbac == nil) then
      error("RBAC settings not found")
   end

   if(m.rbac.rules == nil) then
      error("RBAC rules settings not loaded")
   end

   if(m.rbac.ignore_audience ~= true) then
      error("Wrong RBAC ignore_audience")
   end

   -- print("Rbac object: " .. cjson.encode(m.rbac))

   local first = m.rbac.rules[1]

   if(first == nil) then
      error("RBAC rules not found")
   end
   if(first.url ~= "/rbac-access-[%d]+") then
      error("RBAC rule's URL not loaded")
   end
   if(first.allow == nil or first.allow[1] == nil) then
      error("RBAC rule's 'allow' not loaded")
   end
   if(first.deny == nil or first.deny[1] == nil) then
      error("RBAC rule's 'deny' not loaded")
   end
   if(first.allow_get == nil or first.allow_get[1] == nil) then
      error("RBAC rule's 'allow_get' not loaded")
   end
   if(first.deny_post == nil or first.deny_post[1] == nil) then
      error("RBAC rule's 'deny_post' not loaded")
   end
   if(first.allow[1] ~= "role-1" or first.allow[2] ~= "role-2") then
      error("RBAC rule's 'allow' loaded incorrectly")
   end
   if(first.deny[1] ~= "role-3" or first.deny[2] ~= "role-4") then
      error("RBAC rule's 'deny' loaded incorrectly")
   end
   if(first.allow_get[1] ~= "role-5") then
      error("RBAC rule's 'allow_get' loaded incorrectly")
   end
   if(first.deny_post[1] ~= "role-1") then
      error("RBAC rule's 'deny_post' loaded incorrectly")
   end

   local second = m.rbac.rules[2]

   if(second == nil) then
      error("RBAC rules not found")
   end
   if(second.url ~= "/rbac-access-2") then
      error("RBAC rule's URL not loaded")
   end

   if(second.allow_for_all ~= true) then
      error("RBAC rule's 'allow_for_all' not loaded")
   end
end

function tb:test_should_load_only_apply_for()

  if(m.only_apply_for == nil) then
      error("'Only apply for' not loaded")
   end
   if(m.only_apply_for[1] ~= "/") then
      error("'Obly apply for' items loaded incorrectly")
   end

end

function tb:test_should_load_dont_apply_for()

  if(m.dont_apply_for == nil) then
      error("'Don't apply for' not loaded")
   end
   if(m.dont_apply_for[1] ~= "/free_for_access") then
      error("'Don't apply for' items loaded incorrectly")
   end

end

function tb:test_should_load_black_list()

  if(m.black_list == nil) then
      error("Black list not loaded")
   end
   if(m.black_list[1] ~= "/blocked") then
      error("Black list items loaded incorrectly")
   end

end

function tb:test_should_load_debug_mode()

  if(m.debug_mode == false) then
      error("DebugMode flag not loaded. Actiual value is 'false'")
  end
  if(m.debug_mode == nil) then
      error("DebugMode flag not loaded. Actiual value  is 'nil'")
  end

end

function tb:test_should_load_output_scheme()

  if(m.output_scheme ~= "myauth2") then
      error("Output scheme not loaded")
   end

end

function tb:test_should_load_from_dir()

  local dir_cfg = config_module.load_dir("." .. config_module.dirsep .. "stuff" .. config_module.dirsep .. "config-dir")

  if(not has_value(dir_cfg.anon, '/pub') or not has_value(dir_cfg.anon, '/pub-2')) then
    error("Wrong dir loading")
  end

end

-- units test
tb:run()