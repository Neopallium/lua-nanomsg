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

object "nn_stopwatch" {
	userdata_type = "embed",
	include "nanomsg/utils/stopwatch.h",
	c_source[[
typedef struct nn_stopwatch nn_stopwatch;
]],
	ffi_cdef[[
typedef struct nn_stopwatch {
    uint64_t start;
} nn_stopwatch;
]],
	constructor "init" {
		c_method_call "void" "nn_stopwatch_init" {},
	},
	destructor "term" {
		c_method_call { "unsigned long", "usecs", ffi_wrap = 'tonumber' } "nn_stopwatch_term" {},
	},
}

