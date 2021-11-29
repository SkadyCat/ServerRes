
add_compile_options(-fPIC)
aux_source_directory(. DIR_SRCS)
include_directories(.)
set(Help_LIBRARY "Help")

set(Help_HEADER_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/help.h
)

set(Help_SOURCE_FILES
	${CMAKE_CURRENT_SOURCE_DIR}/help.cpp
)

include_directories( 
	#${LUA_INCLUDE_DIR}
	#${TW2CORE_INCLUDE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}
	../Lua/src
)
# 
add_library(Help STATIC  ${Help_SOURCE_FILES} ${Help_HEADER_FILES} )
target_link_libraries(Help lualib)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ../Share)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ../Share)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ../Share)
set(LIBRARY_OUTPUT_PATH ../Share)

SET_TARGET_PROPERTIES(Help PROPERTIES FOLDER "Help")