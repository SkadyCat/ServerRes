# Install script for directory: /home/magic/Server/res/csrc/GSRecastNavigation/Detour

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/magic/Server/res/csrc/build/GSRecastNavigation/Detour/libDetour.a")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/recastnavigation" TYPE FILE FILES
    "/home/magic/Server/res/csrc/GSRecastNavigation/Detour/Include/DetourAlloc.h"
    "/home/magic/Server/res/csrc/GSRecastNavigation/Detour/Include/DetourAssert.h"
    "/home/magic/Server/res/csrc/GSRecastNavigation/Detour/Include/DetourCommon.h"
    "/home/magic/Server/res/csrc/GSRecastNavigation/Detour/Include/DetourMath.h"
    "/home/magic/Server/res/csrc/GSRecastNavigation/Detour/Include/DetourNavMesh.h"
    "/home/magic/Server/res/csrc/GSRecastNavigation/Detour/Include/DetourNavMeshBuilder.h"
    "/home/magic/Server/res/csrc/GSRecastNavigation/Detour/Include/DetourNavMeshQuery.h"
    "/home/magic/Server/res/csrc/GSRecastNavigation/Detour/Include/DetourNode.h"
    "/home/magic/Server/res/csrc/GSRecastNavigation/Detour/Include/DetourStatus.h"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE FILE FILES "/home/magic/Server/res/csrc/build/GSRecastNavigation/Detour/Detour-d.pdb")
  endif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
endif()

