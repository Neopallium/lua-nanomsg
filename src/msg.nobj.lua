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

local nn_msg_t = [[
typedef struct nn_msg {
	void *msg;
	size_t _size;
} nn_msg;
]]

c_source "typedefs" (nn_msg_t)

object "nn_msg" {
	userdata_type = "embed",
	implements "Buffer" {
		implement_method "const_data" {
			get_field = "msg"
		},
		implement_method "get_size" {
			get_field = "_size"
		},
	},
	implements "MutableBuffer" {
		implement_method "data" {
			get_field = "msg"
		},
		implement_method "get_size" {
			get_field = "_size"
		},
	},
--
-- Define nn_msg type & function API for FFI
--
	ffi_cdef(nn_msg_t),
	ffi_cdef[[
void *nn_allocmsg (size_t size, int type);
int nn_freemsg (void *msg);

]],
	constructor "init" {
		c_source[[
	${this}->msg = NULL;
	${this}->_size = 0;
]],
		ffi_source[[
	${this}.msg = nil
	${this}._size = 0
]],
	},
	constructor "init_size" {
		var_in{ "size_t", "size" },
		c_source[[
	${this}->msg = nn_allocmsg(${size}, 0);
	${this}->_size = ${size};
]],
		ffi_source[[
	${this}.msg = C.nn_allocmsg(${size}, 0)
	${this}._size = ${size}
]],
	},
	constructor "init_data" {
		var_in{ "const char *", "data" },
		c_source[[
	${this}->msg = nn_allocmsg(${data_len}, 0);
	${this}->_size = ${data_len};
	memcpy(${this}->msg, ${data}, ${data_len});
]],
		ffi_source[[
	${this}.msg = C.nn_allocmsg(${data_len}, 0)
	${this}._size = ${data_len}
	ffi.copy(${this}.msg, ${data}, ${data_len})
]],
	},
	destructor "close" {
		c_source[[
	if(${this}->msg) {
		nn_freemsg(${this}->msg);
		${this}->msg = NULL;
	}
	${this}->_size = 0;
]],
		ffi_source[[
	if ${this}.msg ~= nil then
		C.nn_freemsg(${this}.msg)
		${this}.msg = nil
	end
	${this}._size = 0
]],
	},
	method "move" {
		var_in { "nn_msg *", "src" },
		c_source[[
	/* free old message. */
	if(${this}->msg) {
		nn_freemsg(${this}->msg);
	}
	/* copy src -> this */
	${this}->msg = ${src}->msg;
	${this}->_size = ${src}->_size;
	/* close src */
	${src}->msg = NULL;
	${src}->_size = 0;
]],
		ffi_source[[
	-- free old message.
	if ${this}.msg ~= nil then
		C.nn_freemsg(${this}.msg)
	end
	-- copy src -> this
	${this}.msg = ${src}.msg
	${this}._size = ${src}._size
	-- close src
	${src}.msg = nil
	${src}._size = 0
]],
	},
	method "copy" {
		var_in { "nn_msg *", "src" },
		c_source[[
	/* check message data size. */
	if(${this}->_size != ${src}->_size) {
		/* need to resize message. */
		if(${this}->msg) {
			nn_freemsg(${this}->msg); /* free old message. */
		}
		/* allocate new message. */
		if(${src}->_size > 0) {
			${this}->msg = nn_allocmsg(${src}->_size, 0);
		} else {
			${this}->msg = NULL;
		}
		${this}->_size = ${src}->_size;
	}
	/* copy data into message */
	memcpy(${this}->msg, ${src}->msg, ${src}->_size);
]],
		ffi_source[[
	-- check message data size.
	if (${this}._size ~= ${src}._size) then
		-- need to resize message.
		if ${this}.msg ~= nil then
			C.nn_freemsg(${this}.msg) -- free old message.
		end
		-- allocate new message.
		if ${src}._size > 0 then
			${this}.msg = C.nn_allocmsg(${src}._size, 0)
		else
			${this}.msg = nil
		end
		${this}._size = ${src}._size
	end
	-- copy data into message
	ffi.copy(${this}.msg, ${src}.msg, ${src}._size)
]],
	},
	method "set_data" {
		var_in{ "const char *", "data" },
		c_source[[
	/* check message data size. */
	if(${this}->_size != ${data_len}) {
		/* need to resize message. */
		if(${this}->msg) {
			nn_freemsg(${this}->msg); /* free old message. */
		}
		/* allocate new message. */
		if(${data_len} > 0) {
			${this}->msg = nn_allocmsg(${data_len}, 0);
		} else {
			${this}->msg = NULL;
		}
		${this}->_size = ${data_len};
	}
	/* copy data into message */
	memcpy(${this}->msg, ${data}, ${data_len});
]],
		ffi_source[[
	-- check message data size.
	if (${this}._size ~= ${data_len}) then
		-- need to resize message.
		if ${this}.msg ~= nil then
			C.nn_freemsg(${this}.msg) -- free old message.
		end
		-- allocate new message.
		if ${data_len} > 0 then
			${this}.msg = C.nn_allocmsg(${data_len}, 0)
		else
			${this}.msg = nil
		end
		${this}._size = ${data_len}
	end
	-- copy data into message
	ffi.copy(${this}.msg, ${data}, ${data_len})
]],
	},
	method "data" {
		var_out { "void *", "data" },
		c_source[[
	${data} = ${this}->msg;
]],
		ffi_source[[
	${data} = ${this}.msg;
]],
	},
	method "set_size" {
		var_in{ "size_t", "size" },
		c_source[[
	/* check message data size. */
	if(${this}->_size != ${size}) {
		/* need to resize message. */
		if(${this}->msg) {
			nn_freemsg(${this}->msg); /* free old message. */
		}
		/* allocate new message. */
		if(${size} > 0) {
			${this}->msg = nn_allocmsg(${size}, 0);
		} else {
			${this}->msg = NULL;
		}
		${this}->_size = ${size};
	}
]],
		ffi_source[[
	-- check message data size.
	if (${this}._size ~= ${size}) then
		-- need to resize message.
		if ${this}.msg ~= nil then
			C.nn_freemsg(${this}.msg) -- free old message.
		end
		-- allocate new message.
		if ${size} > 0 then
			${this}.msg = C.nn_allocmsg(${size}, 0)
		else
			${this}.msg = nil
		end
		${this}._size = ${size}
	end
]],
	},
	method "size" {
		var_out { "size_t", "size", ffi_wrap = "tonumber" },
		c_source[[
	${size} = ${this}->_size;
]],
		ffi_source[[
	${size} = ${this}._size
]],
	},
	method "__tostring" {
		var_out{ "const char *", "data", has_length = true },
		c_source[[
	${data} = ${this}->msg;
	${data_len} = ${this}->_size;
	if(${data} == NULL) ${data} = "";
]],
		ffi_source[[
	${data} = ${this}.msg
	${data_len} = ${this}._size
	if ${data} == nil then ${data} = "" end
]],
	},
}

