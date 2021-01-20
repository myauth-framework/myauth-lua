debug_mode = true

output_scheme = "myauth2"

black_list = {
	"/blocked"
}

rbac = {
	ignore_audience = true,
	rules = {
		{
			url = "/rbac-access-[%d]+",
			allow = { "User1" }
		}
	}
}

