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
    print("usage: lua " .. arg[0] .. " [message-size] [message-count] [bind-to] [connect-to]")
end

local message_size = tonumber(arg[1] or 1)
local message_count = tonumber(arg[2] or 100000)
local bind_to = arg[3] or 'inproc://thread_thr_test'
local connect_to = arg[4] or 'inproc://thread_thr_test'

local nanomsg = require"nanomsg"
local nthreads = require"nanomsg.threads"

local child_code = [[
	local connect_to, message_size, message_count = ...

	local nanomsg = require"nanomsg"

	local s = assert(nanomsg.socket(nanomsg.SP, nanomsg.PAIR))
	assert(s:connect(connect_to))

	local data = ("0"):rep(message_size)

	assert(s:send("")) -- Signal start

	local timer = nanomsg.nn_stopwatch()

	for i = 1, message_count do
		assert(s:send(data))
	end

	local elapsed = timer:term()

	s:close()

	if elapsed == 0 then elapsed = 1 end

	local throughput = message_count / (elapsed / 1000000)
	local megabits = throughput * message_size * 8 / 1000000

	print(string.format("Sender mean throughput: %i [msg/s]", throughput))
	print(string.format("Sender mean throughput: %.3f [Mb/s]", megabits))

	print("sending thread finished.")
]]

local s = assert(nanomsg.socket(nanomsg.SP, nanomsg.PAIR))
assert(s:bind(bind_to))

print(string.format("message size: %i [B]", message_size))
print(string.format("message count: %i", message_count))

local child_thread = nthreads.runstring(child_code, connect_to, message_size, message_count)
child_thread:start()

local msg
msg = nanomsg.nn_msg()
assert(s:recv_msg(msg))

local timer = nanomsg.nn_stopwatch()

for i = 1, message_count do
	assert(s:recv_msg(msg))
	assert(msg:size() == message_size, "Invalid message size")
end

local elapsed = timer:term()

s:close()
child_thread:join()
nanomsg.term()

if elapsed == 0 then elapsed = 1 end

local throughput = message_count / (elapsed / 1000000)
local megabits = throughput * message_size * 8 / 1000000

print(string.format("mean throughput: %i [msg/s]", throughput))
print(string.format("mean throughput: %.3f [Mb/s]", megabits))

