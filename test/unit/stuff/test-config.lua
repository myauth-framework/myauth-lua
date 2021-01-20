debug_mode = true

output_scheme = "myauth2"

dont_apply_for = {
	"/free_for_access"
}

only_apply_for = {
	"/"
}

black_list = {
	"/blocked"
}

anon = {
	"/pub"
}

basic = {
	{
		id = "user-1",
		pass = "user-1-pass",
		urls = {
			"/basic-access-[%d]+",
			"/basic-access-a"
		}
	},
	{
		id = "user-2",
		pass = "user-2-pass",
		urls = {
			"/basic-access-[%d]+"			
		}
	},
	{
		id = "user-2",
		pass = "user-2-pass",
		urls = {
			"/basic-access-2"			
		}
	}
}

rbac = {
	ignore_audience = true,
	rules = {
		{
			url = "/rbac-access-[%d]+",
			allow = { "role-1", "role-2" },
            deny = { "role-3", "role-4" },
            allow_get = { "role-5"  },
            deny_post = { "role-1"  }
		},
		{
			url = "/rbac-access-2",
            allow_for_all = true
		}
	}
}

