set(LAoi_LIBRARY "LAoi")


set(LAoi_SOURCE_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/luashare.cpp
)

include_directories( 
	#${LUA_INCLUDE_DIR}
	#${TW2CORE_INCLUDE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}
	../Lua/src
	../Help
	../Aoi
)
add_subdirectory(backward-cpp)
add_library(${LAoi_LIBRARY} SHARED ${LAoi_SOURCE_FILES} ${BACKWARD_ENABLE})
add_backward(${LAoi_LIBRARY})

#add_executable(${LAoi_LIBRARY}  ${LAoi_HEADER_FILES} ${LAoi_SOURCE_FILES} )

set_target_properties(${LAoi_LIBRARY} PROPERTIES PREFIX "")
target_link_libraries(${LAoi_LIBRARY} PRIVATE ${LUA_LIBRARY} lualib Help Aoi)

IF (CMAKE_SYSTEM_NAME MATCHES "Linux")
	set_target_properties(${LAoi_LIBRARY} PROPERTIES PREFIX "")
	set(LIBRARY_OUTPUT_PATH /home/magic/Server/res/clib)
ENDIF (CMAKE_SYSTEM_NAME MATCHES "Linux")

IF (CMAKE_SYSTEM_NAME MATCHES "Windows")
	SET(LIBRARY_OUTPUT_PATH ../Share) 
	set(EXECUTABLE_OUTPUT_PATH ../Share)
ENDIF (CMAKE_SYSTEM_NAME MATCHES "Windows")
SET_TARGET_PROPERTIES(${LAoi_LIBRARY} PROPERTIES FOLDER "Help")
