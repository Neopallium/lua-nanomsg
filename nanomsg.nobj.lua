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

-- make generated variable nicer.
set_variable_format "%s%d"

c_module "nanomsg" {
-- module settings.
use_globals = false,
hide_meta_info = true,
luajit_ffi = true,
-- needed for functions exported from module.
luajit_ffi_load_cmodule = true,

ffi_load {
"nanomsg", -- default lib name.
Windows = "libnanomsg", -- lib name for on windows.
},

sys_include "string.h",
include "nanomsg/nn.h",
include "nanomsg/inproc.h",
include "nanomsg/ipc.h",
include "nanomsg/tcp.h",
include "nanomsg/pair.h",
include "nanomsg/pubsub.h",
include "nanomsg/reqrep.h",
include "nanomsg/fanin.h",
include "nanomsg/fanout.h",
include "nanomsg/survey.h",
include "nanomsg/bus.h",

c_source "typedefs" [[
/* detect nanomsg version */
#define VERSION_0_0 1

]],

--
-- Module constants
--
export_definitions {
	-- SP address families.
SP                = "AF_SP",
SP_RAW            = "AF_SP_RAW",
  -- transport types
INPROC            = "NN_INPROC",
IPC               = "NN_IPC",
TCP               = "NN_TCP",

  -- pair
PAIR              = "NN_PAIR",

  -- bus
BUS               = "NN_BUS",

  -- pub/sub
PUB               = "NN_PUB",
SUB               = "NN_SUB",
SUBSCRIBE         = "NN_SUBSCRIBE",
UNSUBSCRIBE       = "NN_UNSUBSCRIBE",

  -- req/resp
REQ               = "NN_REQ",
REP               = "NN_REP",
RESEND            = "NN_RESEND",

  -- survey
SURVEY            = "NN_SURVEY",
RESPONDENT        = "NN_RESPONDENT",
DEADLINE          = "NN_DEADLINE",

  -- fanout
PUSH              = "NN_PUSH",
PULL              = "NN_PULL",

  -- fanout
SOURCE            = "NN_SOURCE",
SINK              = "NN_SINK",

-- socket options levels
SOL_SOCKET        = "NN_SOL_SOCKET",

	-- Generic socket options (NN_SOL_SOCKET level)
LINGER            = "NN_LINGER",
SNDBUF            = "NN_SNDBUF",
RCVBUF            = "NN_RCVBUF",
RCVTIMEO          = "NN_RCVTIMEO",
SNDTIMEO          = "NN_SNDTIMEO",
RECONNECT_IVL     = "NN_RECONNECT_IVL",
RECONNECT_IVL_MAX = "NN_RECONNECT_IVL_MAX",
SNDPRIO           = "NN_SNDPRIO",
SNDFD             = "NN_SNDFD",
RCVFD             = "NN_RCVFD",
DOMAIN            = "NN_DOMAIN",
PROTOCOL          = "NN_PROTOCOL",

-- send/recv flags
DONTWAIT          = "NN_DONTWAIT",

},


subfiles {
"src/error.nobj.lua",
"src/msg.nobj.lua",
"src/socket.nobj.lua",
"src/stopwatch.nobj.lua",
},

--
-- Module static functions
--
c_function "version" {
	var_out{ "<any>", "ver" },
	c_source[[
	int major, minor, patch;
	nn_version(&(major), &(minor), &(patch));

	/* return version as a table: { major, minor, patch } */
	lua_createtable(L, 3, 0);
	lua_pushinteger(L, major);
	lua_rawseti(L, -2, 1);
	lua_pushinteger(L, minor);
	lua_rawseti(L, -2, 2);
	lua_pushinteger(L, patch);
	lua_rawseti(L, -2, 3);
]],
},

c_function "term" {
	c_call "void" "nn_term" {},
},

-- Create NanoMsg socket.
c_function "socket" {
	c_call "!NN_Socket"  "nn_socket" { "int", "domain", "int", "protocol" }
},

include "nanomsg/utils/sleep.h",
c_function "sleep" {
	var_in{ "double", "seconds_" },
	c_source[[
	nn_sleep(${seconds_} * 1000);
]],
},
}

