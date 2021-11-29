set(Aoi_LIBRARY "Aoi")
add_compile_options(-fPIC)


set(Aoi_SOURCE_FILES
	${CMAKE_CURRENT_SOURCE_DIR}/aoi.c
	${CMAKE_CURRENT_SOURCE_DIR}/test.c
)

set(Aoi_HEADER_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/aoi.h
)

include_directories( 
	#${LUA_INCLUDE_DIR}
	#${TW2CORE_INCLUDE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}
	../Lua/src
	../Help
)

add_library(${Aoi_LIBRARY} STATIC ${Aoi_HEADER_FILES} ${Aoi_SOURCE_FILES} )
#add_executable(${Aoi_LIBRARY}  ${Aoi_HEADER_FILES} ${Aoi_SOURCE_FILES} )

set_target_properties(${Aoi_LIBRARY} PROPERTIES PREFIX "")
target_link_libraries(${Aoi_LIBRARY} PRIVATE ${LUA_LIBRARY} lualib Help)

IF (CMAKE_SYSTEM_NAME MATCHES "Linux")
	set_target_properties(${Aoi_LIBRARY} PROPERTIES PREFIX "")
	set(LIBRARY_OUTPUT_PATH /home/magic/Server/res/clib)
ENDIF (CMAKE_SYSTEM_NAME MATCHES "Linux")

IF (CMAKE_SYSTEM_NAME MATCHES "Windows")
	SET(LIBRARY_OUTPUT_PATH ../Share) 
	set(EXECUTABLE_OUTPUT_PATH ../Share)
ENDIF (CMAKE_SYSTEM_NAME MATCHES "Windows")
SET_TARGET_PROPERTIES(${Aoi_LIBRARY} PROPERTIES FOLDER "Help")
