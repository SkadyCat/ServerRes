add_compile_options(-fPIC)
set(LRiman_LIBRARY "NavCore")

set(LRiman_HEADER_FILES
	${CMAKE_CURRENT_SOURCE_DIR}/Include/Context.h
	${CMAKE_CURRENT_SOURCE_DIR}/Include/InputGeom.h
	${CMAKE_CURRENT_SOURCE_DIR}/Include/ChunkyTriMesh.h
	${CMAKE_CURRENT_SOURCE_DIR}/Include/MeshLoaderObj.h
	${CMAKE_CURRENT_SOURCE_DIR}/Include/Sample.h

	${CMAKE_CURRENT_SOURCE_DIR}/Include/Sample_SoloMesh.h
	#${CMAKE_CURRENT_SOURCE_DIR}/Include/NavMeshTesterTool.h
	${CMAKE_CURRENT_SOURCE_DIR}/Include/Scene.h
)
#%(AdditionalOptions) /machine:X86
set(LRiman_SOURCE_FILES
	${CMAKE_CURRENT_SOURCE_DIR}/Source/main.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/Source/Context.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/Source/InputGeom.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/Source/ChunkyTriMesh.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/Source/Sample.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/Source/MeshLoaderObj.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/Source/Sample_SoloMesh.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/Source/Share.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/Source/Scene.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/Source/main.cpp
)


include_directories( 
	#${LUA_INCLUDE_DIR}
	#${TW2CORE_INCLUDE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/Include
	#${PROJECT_SOURCE_DIR}/Lua
)
include_directories(../DebugUtils/Include)
include_directories(../Detour/Include)
include_directories(../DetourCrowd/Include)
include_directories(../DetourTileCache/Include)
include_directories(../Recast/Include)
include_directories(../../Help)
include_directories(../../Lua/src)
set_property(TARGET ${prj_target} PROPERTY FOLDER Samples)


add_library(${LRiman_LIBRARY} SHARED ${LRiman_HEADER_FILES} ${LRiman_SOURCE_FILES} )
#add_executable(${LRiman_LIBRARY}  ${LRiman_HEADER_FILES} ${LRiman_SOURCE_FILES} )
#add_executable (TowerTest main.cpp ${LAOI_LIBRARY})
#set_target_properties(${LAOI_LIBRARY} PROPERTIES LINKER_LANGUAGE C)


SET_TARGET_PROPERTIES(${LRiman_LIBRARY} PROPERTIES FOLDER "Navigation")


#install(TARGETS ${LAOI_LIBRARY} DESTINATION "${MODULE_INSTALL_PATH}")
target_link_libraries(${LRiman_LIBRARY} DebugUtils Detour DetourCrowd DetourTileCache Recast lualib Help)

IF (CMAKE_SYSTEM_NAME MATCHES "Linux")
	set_target_properties(${LRiman_LIBRARY} PROPERTIES PREFIX "")
	
	#target_link_libraries(${LRiman_LIBRARY} DebugUtils Detour DetourCrowd DetourTileCache Recast lualib Help)

	set(LIBRARY_OUTPUT_PATH /home/magic/skynets/skynet/luaclib)
ENDIF (CMAKE_SYSTEM_NAME MATCHES "Linux")

IF (CMAKE_SYSTEM_NAME MATCHES "Windows")
	set_target_properties(${LRiman_LIBRARY} PROPERTIES PREFIX "")
	set(LIBRARY_OUTPUT_PATH ../../Share)
	set(EXECUTABLE_OUTPUT_PATH ../../Share)
	#target_link_libraries(${LRiman_LIBRARY})

ENDIF (CMAKE_SYSTEM_NAME MATCHES "Windows")

#SET_TARGET_PROPERTIES(${ProjectName} PROPERTIES FOLDER "ModuleLogic")

