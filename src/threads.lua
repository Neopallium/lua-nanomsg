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

--
-- nanomsg.thread wraps the low-level threads object.
--

local nanomsg = require"nanomsg"
local llthreads = require"llthreads"

local setmetatable = setmetatable
local tonumber = tonumber
local assert = assert

local thread_mt = {}
thread_mt.__index = thread_mt

function thread_mt:start(detached)
	return self.thread:start(detached)
end

function thread_mt:join()
	return self.thread:join()
end

local bootstrap_pre = [[
local action, action_arg = ...
local func
]]

local bootstrap_post = [[

-- create global 'arg'
arg = { select(3, ...) }

-- load Lua code.
if action == 'runfile' then
	func = assert(loadfile(action_arg))
	-- script name
	arg[0] = action_arg
elseif action == 'runstring' then
	func = assert(loadstring(action_arg))
	-- fake script name
	arg[0] = '=(loadstring)'
end

-- run loaded code.
return func(select(3, ...))
]]

local bootstrap_code = bootstrap_pre..bootstrap_post

local function new_thread(action, action_arg, ...)
	local thread = llthreads.new(bootstrap_code, action, action_arg, ...)
	return setmetatable({
		thread = thread,
	}, thread_mt)
end

local M = {}

function M.set_bootstrap_prelude(code)
   bootstrap_code = bootstrap_pre .. code .. bootstrap_post
end

function M.runfile(file, ...)
	return new_thread('runfile', file, ...)
end

function M.runstring(code, ...)
	return new_thread('runstring', code, ...)
end

nanomsg.threads = M
return M
