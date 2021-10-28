set(Csvparse_LIBRARY "Csvparse")



set(Csvparse_SOURCE_FILES

	${CMAKE_CURRENT_SOURCE_DIR}/Csvparse.cpp
)

include_directories( 
	#${LUA_INCLUDE_DIR}
	#${TW2CORE_INCLUDE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}
	../Lua/src
	../Csvparse
	../Help
)

add_library(${Csvparse_LIBRARY} SHARED ${Csvparse_SOURCE_FILES} )

set_target_properties(${Csvparse_LIBRARY} PROPERTIES PREFIX "")
target_link_libraries(${Csvparse_LIBRARY} PRIVATE ${LUA_LIBRARY} lualib Help)

IF (CMAKE_SYSTEM_NAME MATCHES "Linux")
	set_target_properties(${Csvparse_LIBRARY} PROPERTIES PREFIX "")
	set(LIBRARY_OUTPUT_PATH /home/magic/Server/res/clib)
ENDIF (CMAKE_SYSTEM_NAME MATCHES "Linux")

IF (CMAKE_SYSTEM_NAME MATCHES "Windows")
	SET(LIBRARY_OUTPUT_PATH ../Share) 
ENDIF (CMAKE_SYSTEM_NAME MATCHES "Windows")
SET_TARGET_PROPERTIES(${Csvparse_LIBRARY} PROPERTIES FOLDER "Help")
