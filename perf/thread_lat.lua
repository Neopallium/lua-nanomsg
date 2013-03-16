-- Copyright (c) 2011 Robert G. Jakabosky <bobby@sharedrealm.com>
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

if #arg < 1 then
    print("usage: lua " .. arg[0] .. " [message-size] [roundtrip-count] [bind-to] [connect-to]")
end

local message_size = tonumber(arg[1] or 1)
local roundtrip_count = tonumber(arg[2] or 100000)
local bind_to = arg[3] or 'inproc://thread_lat_test'
local connect_to = arg[4] or 'inproc://thread_lat_test'

local nanomsg = require"nanomsg"
local nthreads = require"nanomsg.threads"

local child_code = [[
	local connect_to, message_size, roundtrip_count = ...

	local nanomsg = require"nanomsg"

	local s = assert(nanomsg.socket(nanomsg.SP, nanomsg.REP))
	assert(s:connect(connect_to))

	local msg = nanomsg.nn_msg()

	for i = 1, roundtrip_count do
		assert(s:recv_msg(msg))
		assert(msg:size() == message_size, "Invalid message size")
		assert(s:send_msg(msg))
	end

	s:close()
]]

local s = assert(nanomsg.socket(nanomsg.SP, nanomsg.REQ))
assert(s:bind(bind_to))

local child_thread = nthreads.runstring(child_code, connect_to, message_size, roundtrip_count)
child_thread:start()

local data = ("0"):rep(message_size)
local msg = nanomsg.nn_msg.init_data(data)

print(string.format("message size: %i [B]", message_size))
print(string.format("roundtrip count: %i", roundtrip_count))

nanomsg.sleep(2) -- wait for child thread to connect.

local timer = nanomsg.nn_stopwatch()

for i = 1, roundtrip_count do
	assert(s:send_msg(msg))
	assert(s:recv_msg(msg))
	assert(msg:size() == message_size, "Invalid message size")
end

local elapsed = timer:term()

s:close()
child_thread:join()
nanomsg.term()

local latency = elapsed / roundtrip_count / 2

print(string.format("mean latency: %.3f [us]", latency))
local secs = elapsed / (1000 * 1000)
print(string.format("elapsed = %f", secs))
print(string.format("msg/sec = %f", roundtrip_count / secs))

