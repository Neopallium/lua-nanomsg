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

-- E* error values.
meta_object "NErrors" {
	export_definitions {
	-- Native NanoMSG error codes.
	"EFSM",
	"ENOCOMPATPROTO",
	"ETERM",
	"EMTHREAD",

	"EPERM", -- Operation not permitted
	"ENOENT", -- No such file or directory
	"ESRCH", -- No such process
	"EINTR", -- Interrupted system call
	"EIO", -- I/O error
	"ENXIO", -- No such device or address
	"E2BIG", -- Argument list too long
	"ENOEXEC", -- Exec format error
	"EBADF", -- Bad file number
	"ECHILD", -- No child processes
	"EAGAIN", -- Try again
	"ENOMEM", -- Out of memory
	"EACCES", -- Permission denied
	"EFAULT", -- Bad address
	"ENOTBLK", -- Block device required
	"EBUSY", -- Device or resource busy
	"EEXIST", -- File exists
	"EXDEV", -- Cross-device link
	"ENODEV", -- No such device
	"ENOTDIR", -- Not a directory
	"EISDIR", -- Is a directory
	"EINVAL", -- Invalid argument
	"ENFILE", -- File table overflow
	"EMFILE", -- Too many open files
	"ENOTTY", -- Not a typewriter
	"ETXTBSY", -- Text file busy
	"EFBIG", -- File too large
	"ENOSPC", -- No space left on device
	"ESPIPE", -- Illegal seek
	"EROFS", -- Read-only file system
	"EMLINK", -- Too many links
	"EPIPE", -- Broken pipe
	"EDOM", -- Math argument out of domain of func
	"ERANGE", -- Math result not representable

	"EDEADLK", -- Resource deadlock would occur
	"EDEADLOCK", -- EDEADLK
	"ENAMETOOLONG", -- File name too long
	"ENOLCK", -- No record locks available
	"ENOSYS", -- Function not implemented
	"ENOTEMPTY", -- Directory not empty
	"ELOOP", -- Too many symbolic links encountered
	"EWOULDBLOCK", -- Operation would block
	"ENOMSG", -- No message of desired type
	"EIDRM", -- Identifier removed
	"ECHRNG", -- Channel number out of range
	"EL2NSYNC", -- Level 2 not synchronized
	"EL3HLT", -- Level 3 halted
	"EL3RST", -- Level 3 reset
	"ELNRNG", -- Link number out of range
	"EUNATCH", -- Protocol driver not attached
	"ENOCSI", -- No CSI structure available
	"EL2HLT", -- Level 2 halted
	"EBADE", -- Invalid exchange
	"EBADR", -- Invalid request descriptor
	"EXFULL", -- Exchange full
	"ENOANO", -- No anode
	"EBADRQC", -- Invalid request code
	"EBADSLT", -- Invalid slot

	"EBFONT", -- Bad font file format
	"ENOSTR", -- Device not a stream
	"ENODATA", -- No data available
	"ETIME", -- Timer expired
	"ENOSR", -- Out of streams resources
	"ENONET", -- Machine is not on the network
	"ENOPKG", -- Package not installed
	"EREMOTE", -- Object is remote
	"ENOLINK", -- Link has been severed
	"EADV", -- Advertise error
	"ESRMNT", -- Srmount error
	"ECOMM", -- Communication error on send
	"EPROTO", -- Protocol error
	"EMULTIHOP", -- Multihop attempted
	"EDOTDOT", -- RFS specific error
	"EBADMSG", -- Not a data message
	"EOVERFLOW", -- Value too large for defined data type
	"ENOTUNIQ", -- Name not unique on network
	"EBADFD", -- File descriptor in bad state
	"EREMCHG", -- Remote address changed
	"ELIBACC", -- Can not access a needed shared library
	"ELIBBAD", -- Accessing a corrupted shared library
	"ELIBSCN", -- .lib section in a.out corrupted
	"ELIBMAX", -- Attempting to link in too many shared libraries
	"ELIBEXEC", -- Cannot exec a shared library directly
	"EILSEQ", -- Illegal byte sequence
	"ERESTART", -- Interrupted system call should be restarted
	"ESTRPIPE", -- Streams pipe error
	"EUSERS", -- Too many users
	"ENOTSOCK", -- Socket operation on non-socket
	"EDESTADDRREQ", -- Destination address required
	"EMSGSIZE", -- Message too long
	"EPROTOTYPE", -- Protocol wrong type for socket
	"ENOPROTOOPT", -- Protocol not available
	"EPROTONOSUPPORT", -- Protocol not supported
	"ESOCKTNOSUPPORT", -- Socket type not supported
	"EOPNOTSUPP", -- Operation not supported on transport endpoint
	"EPFNOSUPPORT", -- Protocol family not supported
	"EAFNOSUPPORT", -- Address family not supported by protocol
	"EADDRINUSE", -- Address already in use
	"EADDRNOTAVAIL", -- Cannot assign requested address
	"ENETDOWN", -- Network is down
	"ENETUNREACH", -- Network is unreachable
	"ENETRESET", -- Network dropped connection because of reset
	"ECONNABORTED", -- Software caused connection abort
	"ECONNRESET", -- Connection reset by peer
	"ENOBUFS", -- No buffer space available
	"EISCONN", -- Transport endpoint is already connected
	"ENOTCONN", -- Transport endpoint is not connected
	"ESHUTDOWN", -- Cannot send after transport endpoint shutdown
	"ETOOMANYREFS", -- Too many references: cannot splice
	"ETIMEDOUT", -- Connection timed out
	"ECONNREFUSED", -- Connection refused
	"EHOSTDOWN", -- Host is down
	"EHOSTUNREACH", -- No route to host
	"EALREADY", -- Operation already in progress
	"EINPROGRESS", -- Operation now in progress
	"ESTALE", -- Stale NFS file handle
	"EUCLEAN", -- Structure needs cleaning
	"ENOTNAM", -- Not a XENIX named type file
	"ENAVAIL", -- No XENIX semaphores available
	"EISNAM", -- Is a named type file
	"EREMOTEIO", -- Remote I/O error
	"EDQUOT", -- Quota exceeded

	"ENOMEDIUM", -- No medium found
	"EMEDIUMTYPE", -- Wrong medium type
	"ECANCELED", -- Operation Canceled
	"ENOKEY", -- Required key not available
	"EKEYEXPIRED", -- Key has expired
	"EKEYREVOKED", -- Key has been revoked
	"EKEYREJECTED", -- Key was rejected by service

	-- for robust mutexes
	"EOWNERDEAD", -- Owner died
	"ENOTRECOVERABLE", -- State not recoverable

	"ERFKILL", -- Operation not possible due to RF-kill
	},

	method "description" {
		var_in{ "<any>", "err" },
		var_out{ "const char *", "msg" },
		c_source "pre" [[
	int err_type;
	int err_num = -1;
]],
		c_source[[
	err_type = lua_type(L, ${err::idx});
	if(err_type == LUA_TSTRING) {
		lua_pushvalue(L, ${err::idx});
		lua_rawget(L, ${this::idx});
		if(lua_isnumber(L, -1)) {
			err_num = lua_tointeger(L, -1);
		}
		lua_pop(L, 1);
	} else if(err_type == LUA_TNUMBER) {
		err_num = lua_tointeger(L, ${err::idx});
	} else {
		return luaL_argerror(L, ${err::idx}, "expected string/number");
	}
	if(err_num < 0) {
		lua_pushnil(L);
		lua_pushliteral(L, "UNKNOWN ERROR");
		return 2;
	}
	${msg} = strerror(err_num);
]],
	},

	method "__index" {
		var_in{ "int", "err" },
		var_out{ "const char *", "msg" },
		c_source[[
	switch(${err}) {
	case EAGAIN:
		${msg} = "timeout";
		break;
	case EINTR:
		${msg} = "interrupted";
		break;
#if defined(ETERM)
	case ETERM:
		${msg} = "closed";
		break;
#endif
	default:
		${msg} = nn_strerror(${err});
		break;
	}
	lua_pushvalue(L, ${err::idx});
	lua_pushstring(L, ${msg});
	lua_rawset(L, ${this::idx});
]],
	},
}

ffi_cdef[[
int nn_errno (void);
]]

ffi_source "ffi_src" [[
-- get NErrors table to map errno to error name.
local NError_names = _M.NErrors

local function get_nn_strerror()
	return NError_names[C.nn_errno()]
end
]]

c_source "extra_code" [[
static char *nn_NErrors_key = "nn_NErrors_key";
/*
 * This wrapper function is to make the EAGAIN/ETERM error messages more like
 * what is returned by LuaSocket.
 */
static const char *get_nn_strerror() {
	int err = nn_errno();
	switch(err) {
	case EAGAIN:
		return "timeout";
		break;
	case EINTR:
		return "interrupted";
		break;
#if defined(ETERM)
	case ETERM:
		return "closed";
		break;
#endif
	default:
		break;
	}
	return nn_strerror(err);
}

]]

c_source "module_init_src" [[
	/* Cache reference to nanomsg.NErrors table for errno->string convertion. */
	lua_pushlightuserdata(L, nn_NErrors_key);
	lua_getfield(L, -2, "NErrors");
	lua_rawset(L, LUA_REGISTRYINDEX);
]]

-- Convert NN Error codes into strings.
--
-- This is an error code wrapper object, it converts C-style 'int' return error code
-- into Lua-style 'nil, "Error message"' return values.
--
error_code "NN_Error" "int" {
	ffi_type = "int",
	is_error_check = function(rec) return "(-1 == ${" .. rec.name .. "})" end,
	ffi_is_error_check = function(rec) return "(-1 == ${" .. rec.name .. "})" end,
	default = "0",
	c_source [[
	int num;
	if(-1 == err) {
		/* get NErrors table. */
		lua_pushlightuserdata(L, nn_NErrors_key);
		lua_rawget(L, LUA_REGISTRYINDEX);
		/* convert nn_errno to string. */
		num = nn_errno();
		lua_pushinteger(L, num);
		lua_gettable(L, -2);
		/* remove NErrors table. */
		lua_remove(L, -2);
		if(!lua_isnil(L, -1)) {
			/* found error. */
			return;
		}
		/* Unknown error. */
		lua_pop(L, 1);
		lua_pushfstring(L, "UNKNOWN ERROR(%d)", num);
		return;
	}
]],
	ffi_source [[
	if(-1 == err) then
		err_str = NError_names[C.nn_errno()]
	end
]],
}

