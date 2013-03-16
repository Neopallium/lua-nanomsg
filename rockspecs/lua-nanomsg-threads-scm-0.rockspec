package = "lua-nanomsg-threads"
version = "scm-0"
source = {
	url = "git://github.com/Neopallium/lua-nanomsg.git",
}
description = {
	summary = "Lua NanoMsg + llthreads module.",
	homepage = "http://github.com/Neopallium/lua-nanomsg",
	license = "MIT/X11",
}
dependencies = {
	"lua-nanomsg = scm-0",
	"lua-llthreads = scm-0",
}
build = {
	type = "none",
	install = {
		lua = {
			['nanomsg.threads'] = "src/threads.lua",
		},
	},
}
