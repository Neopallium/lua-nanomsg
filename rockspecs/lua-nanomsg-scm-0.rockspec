package = "lua-nanomsg"
version = "scm-0"
source = {
	url = "git://github.com/Neopallium/lua-nanomsg.git",
}
description = {
	summary = "Lua bindings to NanoMsg.",
	homepage = "http://github.com/Neopallium/lua-nanomsg",
	license = "MIT/X11",
}
dependencies = {
	"lua >= 5.1",
}
external_dependencies = {
	platforms = {
		windows = {
			NANOMSG = {
				library = "libnanomsg",
			}
		},
	},
	NANOMSG = {
		header = "nanomsg/nn.h",
		library = "nanomsg",
	}
}
build = {
	platforms = {
		windows = {
			modules = {
				nanomsg = {
					libraries = {"libnanomsg"},
				}
			}
		},
	},
	type = "builtin",
	modules = {
		nanomsg = {
			sources = {"src/pre_generated-nanomsg.nobj.c"},
			incdirs = "$(NANOMSG_INCDIR)",
			libdirs = "$(NANOMSG_LIBDIR)",
			libraries = {"nanomsg"},
		},
	},
}
