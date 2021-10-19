set(BufferReader_LIBRARY "BufferReader")
set(BufferReader_SOURCE_FILES

	${CMAKE_CURRENT_SOURCE_DIR}/BufferReader.cpp
)

include_directories( 
	#${LUA_INCLUDE_DIR}
	#${TW2CORE_INCLUDE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}
	../Lua/src
	../Help
)
add_library(${BufferReader_LIBRARY} SHARED ${BufferReader_SOURCE_FILES} )
set_target_properties(${BufferReader_LIBRARY} PROPERTIES PREFIX "")
target_link_libraries(${BufferReader_LIBRARY} PRIVATE ${LUA_LIBRARY} lualib Help)
IF (CMAKE_SYSTEM_NAME MATCHES "Linux")

	set(LIBRARY_OUTPUT_PATH /home/magic/Server/res/clib)
ENDIF (CMAKE_SYSTEM_NAME MATCHES "Linux")

IF (CMAKE_SYSTEM_NAME MATCHES "Windows")
	SET(LIBRARY_OUTPUT_PATH ../Share) 
ENDIF (CMAKE_SYSTEM_NAME MATCHES "Windows")

SET_TARGET_PROPERTIES(${BufferReader_LIBRARY} PROPERTIES FOLDER "Help")
