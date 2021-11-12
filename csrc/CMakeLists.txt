
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
# 最低版本要求
CMAKE_MINIMUM_REQUIRED(VERSION 3.10)

# 项目名称
PROJECT(CServer)

# 配置vsocdedebug
add_definitions(-std=c++11)

set(cmake_build_type "Debug")
set(cmake_cxx_flage_debug "$ENV{CXXFLAGS} -O0 -Wall -g -ggdb")
set(cmake_cxx_flags_release "$ENV{CXXFLAGS} -03 -Wall")

# 添加两个子目录

ADD_SUBDIRECTORY(./Lua)
add_subdirectory(./Help)
add_subdirectory(./BufferReader)
add_subdirectory(./GSRecastNavigation)
add_subdirectory(./Csvparse)
add_subdirectory(./Aoi)
add_subdirectory(./LAoi)