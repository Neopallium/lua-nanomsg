About
=====

Lua bindings to NanoMsg.

Installation
============

It is recommended to either compile Lua with the "-pthread" flag or preload libpthread.so on Linux when using this module ([see this glibc bug report](http://sourceware.org/bugzilla/show_bug.cgi?id=10652)):

	$ LD_PRELOAD=/lib/libpthread.so lua


Latest Git revision
-------------------

With LuaRocks:

	$ sudo luarocks install https://raw.github.com/Neopallium/lua-nanomsg/master/rockspecs/lua-nanomsg-scm-1.rockspec

For threads support:

	$ sudo luarocks install https://raw.github.com/Neopallium/lua-llthreads/master/rockspecs/lua-llthreads-scm-0.rockspec
	$ sudo luarocks install https://raw.github.com/Neopallium/lua-nanomsg/master/rockspecs/lua-nanomsg-threads-scm-0.rockspec

With CMake:

	$ git clone git://github.com/Neopallium/lua-nanomsg.git
	$ cd lua-nanomsg ; mkdir build ; cd build
	$ cmake ..
	$ make
	$ sudo make install

Running benchmarks
==================

When running the benchmarks you will need run two different scripts (one 'local' and one 'remote').  Both scripts can be run on the same computer or on different computers.  Make sure to start the 'local' script first.

Throughput benchmark:

	# first start local script
	$ luajit-2 perf/local_thr.lua "tcp://lo:5555" 30 1000000
	
	# then in another window start remote script
	$ luajit-2 perf/remote_thr.lua "tcp://localhost:5555" 30 1000000

Latency benchmark:

	# first start local script
	$ luajit-2 perf/local_lat.lua "tcp://lo:5555" 1 100000
	
	# then in another window start remote script
	$ luajit-2 perf/remote_lat.lua "tcp://localhost:5555" 1 100000


