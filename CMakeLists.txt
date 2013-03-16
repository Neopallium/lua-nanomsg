#
# Lua bindings for NanoMsg
#
cmake_minimum_required(VERSION 2.8)

project(lua-nanomsg C)

set(BUILD_SHARED_LIBS TRUE)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set(INSTALL_LMOD ${CMAKE_INSTALL_PREFIX}/share/lua/5.1 CACHE PATH
				"Directory to install Lua source modules (configure lua via LUA_PATH)")
set(INSTALL_CMOD ${CMAKE_INSTALL_PREFIX}/lib/lua/5.1 CACHE PATH
				"Directory to install Lua binary modules (configure lua via LUA_CPATH)")
set(NANOMSG_PATH "" CACHE PATH
				"Directory to libnanomsg. (by default use pkg-config to detect path)")

set(COMMON_CFLAGS "${CFLAGS}")
set(COMMON_LDFLAGS)
set(COMMON_LIBS)

## Lua 5.1.x
include(FindLua51)
if(NOT ${LUA51_FOUND})
	message(FATAL_ERROR "The FindLua51 module could not find lua :-(")
endif()
if(WIN32)
	set(COMMON_CFLAGS "${COMMON_CFLAGS} -I${LUA_INCLUDE_DIR}")
	set(COMMON_LDFLAGS "${COMMON_LDFLAGS} ${LUA_LIBRARY}")
	if(NOT MSVC)
		set(COMMON_LDFLAGS "${COMMON_LDFLAGS} -Wl,--export-all-symbols")
	endif()
endif()
## MAC OSX needs extra linker flags
if(APPLE)
	set(COMMON_LDFLAGS "${COMMON_LDFLAGS} -undefined dynamic_lookup")
endif()

## LibNANOMSG
if(WIN32)
	## need NANOMSG_PATH
	if(IS_DIRECTORY "${NANOMSG_PATH}")
	else()
		message(FATAL_ERROR "Please set the NANOMSG_PATH CMake variable.")
	endif()
endif()
if(IS_DIRECTORY ${NANOMSG_PATH})
	set(COMMON_CFLAGS "${COMMON_CFLAGS} -I${NANOMSG_PATH}/include")
	if(MSVC)
		set(COMMON_LIBS "${COMMON_LIBS};libnanomsg")
	else()
		set(COMMON_LDFLAGS "${COMMON_LDFLAGS} -L${NANOMSG_PATH}/lib")
		set(COMMON_LIBS "${COMMON_LIBS};nanomsg")
	endif()
	link_directories(${NANOMSG_PATH}/lib)
else()
	## fallback to using pkg-config
	include(FindPkgConfig)
	pkg_search_module(NANOMSG REQUIRED libnanomsg)
	set(COMMON_CFLAGS "${COMMON_CFLAGS} ${NANOMSG_CFLAGS}")
	set(COMMON_LDFLAGS "${COMMON_LDFLAGS} ${NANOMSG_LDFLAGS}")
	set(COMMON_LIBS "${COMMON_LIBS};${NANOMSG_LIBRARIES}")
endif()

## LuaNativeObjects
include(LuaNativeObjects)
include(CustomMacros)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}
                    ${CMAKE_CURRENT_BINARY_DIR}
                    ${LUA_INCLUDE_DIR})

## LuaNANOMSG
set(LUA_NANOMSG_SRC
	nanomsg.nobj.lua
)

## LuaNANOMSG Lua source modules
set(LUA_NANOMSG_SRC_LUA_MODS
	src/poller.lua
	src/threads.lua
)

if(${USE_PRE_GENERATED_BINDINGS})
	set(LUA_NANOMSG_SRC src/pre_generated-nanomsg.nobj.c)
else()
	# Generate Lua bindings.
	GenLuaNativeObjects(LUA_NANOMSG_SRC)
endif()

add_library(lua-nanomsg MODULE ${LUA_NANOMSG_SRC})
target_link_libraries(lua-nanomsg ${COMMON_LIBS})
set_target_properties(lua-nanomsg PROPERTIES PREFIX "")
add_target_properties(lua-nanomsg COMPILE_FLAGS "${COMMON_CFLAGS}")
add_target_properties(lua-nanomsg LINK_FLAGS "${LD_FLAGS} ${COMMON_LDFLAGS}")
set_target_properties(lua-nanomsg PROPERTIES OUTPUT_NAME nanomsg)

install(TARGETS lua-nanomsg
        DESTINATION "${INSTALL_CMOD}")

install(FILES ${LUA_NANOMSG_SRC_LUA_MODS}
        DESTINATION "${INSTALL_LMOD}/nanomsg")

