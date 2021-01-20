debug_mode = false

output_scheme = "blabla"

dont_apply_for = {
	"/free_for_access_new"
}

only_apply_for = {
	"/new"
}

black_list = {
	"/blocked_new"
}

anon = {
	"/pub_new"
}

basic = {
	{
		id = "user-3",
		pass = "user-3-pass",
		urls = {
			"/basic-access-[%d]+",
			"/basic-access-a"
		}
	}
}

rbac = {
	ignore_audience = false,
	rules = {
		{
			url = "/rbac-access-new",
            allow_for_all = true
		}
	}
}

