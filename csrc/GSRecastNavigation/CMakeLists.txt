


cmake_minimum_required(VERSION 3.0)

project(RecastNavigation)
#PROJECT(Navigation)

# lib versions
SET(SOVERSION 1)
SET(VERSION 1.0.0)

option(RECASTNAVIGATION_DEMO "Build demo" ON)
option(RECASTNAVIGATION_TESTS "Build tests" ON)
option(RECASTNAVIGATION_EXAMPLES "Build examples" ON)

if(MSVC AND BUILD_SHARED_LIBS)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

include(GNUInstallDirs)

add_subdirectory(DebugUtils)
add_subdirectory(Detour)
add_subdirectory(DetourCrowd)
add_subdirectory(DetourTileCache)
add_subdirectory(Recast)
add_subdirectory(LRiman)


if (RECASTNAVIGATION_TESTS)
    enable_testing()
	
endif ()
