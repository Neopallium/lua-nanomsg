-- Copyright (c) 2013 by Robert G. Jakabosky <bobby@sharedrealm.com>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

-------------------------------------------------------------------------------------
--
-- Generate NanoMsg socket option code customized for each version of nanomsg (2.0,2.1,3.x)
--
-------------------------------------------------------------------------------------

local OPT_TYPES = {
NONE   = "NONE",
INT    = "int",
UINT32 = "uint32_t",
UINT64 = "uint64_t",
INT64  = "int64_t",
BLOB   = "const char *",
FD     = "int",
}
local get_set_prefix = {
rw = { c_get = "lnn_socket_", get='', c_set = "lnn_socket_set_", set='set_' },
r = { c_get = "lnn_socket_", get='' },
w = { c_set = "lnn_socket_", set='' },
}

local socket_options = {
	{ ver_def = 'VERSION_0_0', major = 0, minor = 0,
		{ name="linger",            otype="INT",    mode="rw", ltype="int" },
		{ name="sndbuf",            otype="UINT64", mode="rw", ltype="int" },
		{ name="rcvbuf",            otype="UINT64", mode="rw", ltype="int" },
		{ name="rcvtimeo",          otype="INT",    mode="rw", ltype="int" },
		{ name="sndtimeo",          otype="INT",    mode="rw", ltype="int" },
		{ name="reconnect_ivl",     otype="INT",    mode="rw", ltype="int" },
		{ name="reconnect_ivl_max", otype="INT",    mode="rw", ltype="int" },
		{ name="sndprio",           otype="INT",    mode="rw", ltype="int" },
		{ name="sndfd",             otype="FD",     mode="r",  ltype="int" },
		{ name="rcvfd",             otype="FD",     mode="r",  ltype="int" },
		{ name="domain",            otype="INT",    mode="rw", ltype="int" },
		{ name="protocol",          otype="INT",    mode="rw", ltype="int" },

		{ name="subscribe",         otype="BLOB",   mode="w",  ltype="const char *", level = "SUB" },
		{ name="unsubscribe",       otype="BLOB",   mode="w",  ltype="const char *", level = "SUB" },
	},
}

local function foreach_opt(func)
	for i=1,#socket_options do
		local ver_opts = socket_options[i]
		for num,opt in ipairs(ver_opts) do
			func(num, opt, ver_opts)
		end
	end
end
local add=function(t,val) return table.insert(t,val) end
local function template(data, templ)
	return templ:gsub("%${(.-)}", data)
end

local socket_methods = {}
local max_methods = 0
local function get_methods(opt, ver)
	local num = opt.num
	-- check if methods have been created
	local methods = socket_methods[num]

	if not methods then
		-- need to create methods info.
		methods = {
			num=num,
			name=opt.name,
			get=opt.get, set=opt.set, c_get=opt.c_get, c_set=opt.c_set,
			ltype=opt.ltype, otype=opt.otype, mode=opt.mode, level=opt.level,
			versions = {},
		}

		-- initialize all version as not-supported.
		for i=1,#socket_options do
			local ver_opts = socket_options[i]
			methods[ver_opts.ver_def] = false
		end

		if num > max_methods then max_methods = num end

		socket_methods[num] = methods
	end

	-- mark this version as supporting the option.
	methods[ver.ver_def] = true
	add(methods.versions, ver)

	return methods
end

-- do pre-processing of options.
foreach_opt(function(num, opt, ver)
	opt.num = num
	if not opt.name then
		opt.name = 'none'
		opt.otype = 'NONE'
		opt.DEF = 'unused'
		opt.LEVEL_DEF = 'unused'
		return
	end
	opt.DEF = "NN_" .. opt.name:upper()
	opt.LEVEL_DEF = "NN_" .. (opt.level or "SOL_SOCKET"):upper()
	-- ctype & ffi_type
	local ctype = OPT_TYPES[opt.otype]
	opt.ctype = ctype
	if opt.otype == 'BLOB' then
		opt.ffi_type = 'string'
		opt.set_len_param = ', size_t value_len'
		opt.set_val_name = 'value'
		opt.set_len_name = 'value_len'
	elseif ctype ~= 'NONE' then
		opt.ffi_type = ctype .. '[1]'
		opt.set_len_param = ''
		opt.set_val_name = '&value'
		opt.set_len_name = 'sizeof(value)'
	end
	-- getter/setter names
	for meth,prefix in pairs(get_set_prefix[opt.mode]) do
		opt[meth] = prefix .. opt.name
	end
	-- create common list of option get/set methods.
	local methods = get_methods(opt, ver)
end)

local options_c_code = {}

local function if_def(def)
	local code = "#if " .. def .. "\n"
	add(options_c_code, code)
end
local function endif(def)
	local code = "#endif /* #if " .. def .. " */\n"
	add(options_c_code, code)
end

-- build C code for socket options setters/getters
local last_ver
foreach_opt(function(num, opt, ver)
	if ver ~= last_ver then
		if last_ver then
			endif(last_ver.ver_def)
		end
		last_ver = ver
		if_def(ver.ver_def)
	end
	if opt.name == 'none' then return end
	-- generate setter
	local set = ''
	local get = ''
	if opt.c_set then
		if opt.otype == 'BLOB' then
			set = [[
LUA_NOBJ_API NN_Error ${c_set}(NN_Socket sock, const char *value, size_t str_len) {
	return nn_setsockopt(sock, ${LEVEL_DEF}, ${DEF}, value, str_len);
]]
		elseif opt.ctype == opt.ltype then
			set = [[
LUA_NOBJ_API NN_Error ${c_set}(NN_Socket sock, ${ltype} value) {
	return nn_setsockopt(sock, ${LEVEL_DEF}, ${DEF}, &value, sizeof(value));
]]
		else
			set = [[
LUA_NOBJ_API NN_Error ${c_set}(NN_Socket sock, ${ltype} value) {
	${ctype} val = (${ctype})value;
	return nn_setsockopt(sock, ${LEVEL_DEF}, ${DEF}, &val, sizeof(val));
]]
		end
		set = set .. "}\n\n"
	end
	-- generate getter
	if opt.c_get then
		if opt.otype == 'BLOB' then
			get = [[
LUA_NOBJ_API NN_Error ${c_get}(NN_Socket sock, char *value, size_t *len) {
	return nn_getsockopt(sock, ${LEVEL_DEF}, ${DEF}, value, len);
]]
		elseif opt.ctype == opt.ltype then
			get = [[
LUA_NOBJ_API NN_Error ${c_get}(NN_Socket sock, ${ltype} *value) {
	size_t val_len = sizeof(${ltype});
	return nn_getsockopt(sock, ${LEVEL_DEF}, ${DEF}, value, &val_len);
]]
		else
			get = [[
LUA_NOBJ_API NN_Error ${c_get}(NN_Socket sock, ${ltype} *value) {
	${ctype} val;
	size_t val_len = sizeof(val);
	int rc = nn_getsockopt(sock, ${LEVEL_DEF}, ${DEF}, &val, &val_len);
	*value = (${ltype})val;
	return rc;
]]
		end
		get = get .. "}\n\n"
	end
	local templ
	if opt.custom then
		templ = opt.custom
	else
		templ = set .. get
	end
	add(options_c_code, template(opt,templ))
end)
endif(last_ver.ver_def)

options_c_code = table.concat(options_c_code)

local function tunpack(tab, idx, max)
	if idx == max then return tab[idx] end
	return tab[idx], tunpack(tab, idx + 1, max)
end

local function build_meth_if_def(meth)
	local v = {}
	for i=1,#socket_options do
		local ver_opts = socket_options[i]
		if meth[ver_opts.ver_def] then
			v[#v+1] = ver_opts.ver_def
		end
	end
	return v
end

local function build_option_methods()
	local m = {}

	for i=1,max_methods do
		local meth = socket_methods[i]
		if meth then
			local ltype = meth.ltype
			local name
			-- get list of version defs for this method.
			local if_defs = build_meth_if_def(meth)
			-- generate getter method.
			name = meth.get
			if name then
				local args = { ltype, "&value" }
				local val_out = { ltype, "&value" }
				if meth.otype == 'BLOB' then
					val_out = { 'char *', "value", has_length = true }
					args = { 'char *', "value", "size_t", "&#value" }
				end
				m[#m+1] = method (name) { if_defs = if_defs,
					var_out(val_out),
					c_export_method_call "NN_Error" (meth.c_get) (args),
				}
			end
			-- generate setter method.
			name = meth.set
			if name then
				local args = { ltype, "value" }
				if meth.otype == 'BLOB' then
					args = { ltype, "value", "size_t", "#value" }
				end
				m[#m+1] = method (name) { if_defs = if_defs,
					c_export_method_call "NN_Error" (meth.c_set) (args),
				}
			end
		end
	end

	return tunpack(m, 1, #m)
end

-------------------------------------------------------------------------------------
--
-- NanoMsg socket object.
--
-------------------------------------------------------------------------------------

object "NN_Socket" {
	userdata_type = 'simple',
	ffi_type = 'int',

	ffi_cdef[[
int nn_recv (NN_Socket s, void *buf, size_t len, int flags);
]],
	ffi_source[[
local NN_MSG = -1ULL
]],
	c_source ([[

typedef int NN_Socket;

#ifdef _WIN32
#include <winsock2.h>
typedef SOCKET socket_t;
#else
typedef int socket_t;
#endif

]] .. options_c_code),

	destructor "close" {
		c_method_call "NN_Error"  "nn_close" {}
	},
	method "bind" {
		c_method_call "NN_Error"  "nn_bind" { "const char *", "addr" }
	},
	method "connect" {
		c_method_call "NN_Error"  "nn_connect" { "const char *", "addr" }
	},
	method "shutdown" {
		c_method_call "NN_Error"  "nn_shutdown" { "int", "how" }
	},
	--
	-- nn_send
	--
	method "send_msg" {
		var_in{ "nn_msg *", "msg" },
		var_in{"int", "flags?"},
		var_out{"NN_Error", "rc"},
		c_source[[
	${rc} = nn_send(${this}, &(${msg}->msg), NN_MSG, ${flags});
	if(${rc} >= 0) {
		/* close message. */
		${msg}->msg = NULL;
		${msg}->_size = 0;
	}
]],
		ffi_source[[
	${rc} = C.nn_send(${this}, ffi.cast('void *',${msg}), NN_MSG, ${flags})
	if ${rc} >= 0 then
		-- close message.
		${msg}.msg = nil
		${msg}._size = 0
	end
]],
	},
	method "send" {
		c_method_call { "NN_Error", "rc" } "nn_send"
			{ "const char *", "data", "size_t", "#data", "int", "flags?"},
		c_source[[
	/* ${rc} >= 0, then return number of bytes sent. */
	if(${rc} >= 0) {
		lua_pushinteger(L, ${rc});
		return 1;
	}
]],
		ffi_source[[
	-- ${rc} >= 0, then return number of bytes sent.
	if ${rc} >= 0 then return ${rc} end
]],
	},

	--
	-- nn_recv
	--
	method "recv_msg" {
		var_in{ "nn_msg *", "msg" },
		var_in{"int", "flags?"},
		var_out{"NN_Error", "rc"},
		c_source[[
	if(${msg}->msg) {
		nn_freemsg(${msg}->msg);
		${msg}->msg = NULL;
		${msg}->_size = 0;
	}
	${rc} = nn_recv(${this}, &(${msg}->msg), NN_MSG, ${flags});
	${msg}->_size = ${rc};
]],
		ffi_source[[
	if ${msg}.msg ~= nil then
		C.nn_freemsg(${msg}.msg)
		${msg}.msg = nil
		${msg}._size = 0
	end
	${rc} = C.nn_recv(${this}, ${msg}, NN_MSG, ${flags})
	${msg}._size = ${rc}
]],
	},
	ffi_source[[
local tmp_msg = ffi.new("void *[1]")
]],
	method "recv" {
		var_in{"int", "flags?"},
		var_out{"char *", "data", has_length = true},
		var_out{"NN_Error", "rc"},
		c_source[[
	${rc} = nn_recv(${this}, &(${data}), NN_MSG, ${flags});
	${data_len} = ${rc};
]],
		c_source "post" [[
	/* close message */
	nn_freemsg(${data});
]],
		ffi_source[[
	${rc} = C.nn_recv(${this}, tmp_msg, NN_MSG, ${flags})
	${data} = tmp_msg[0];
	${data_len} = ${rc};
]],
		ffi_source "ffi_post" [[
	-- close message
	C.nn_freemsg(tmp_msg[0])
]],
	},

	-- build option set/get methods.  THIS MUST BE LAST.
	build_option_methods(),
}

