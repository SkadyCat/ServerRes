# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.16

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/magic/Server/res/csrc

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/magic/Server/res/csrc/build

# Include any dependencies generated for this target.
include Help/CMakeFiles/Help.dir/depend.make

# Include the progress variables for this target.
include Help/CMakeFiles/Help.dir/progress.make

# Include the compile flags for this target's objects.
include Help/CMakeFiles/Help.dir/flags.make

Help/CMakeFiles/Help.dir/help.cpp.o: Help/CMakeFiles/Help.dir/flags.make
Help/CMakeFiles/Help.dir/help.cpp.o: ../Help/help.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/magic/Server/res/csrc/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object Help/CMakeFiles/Help.dir/help.cpp.o"
	cd /home/magic/Server/res/csrc/build/Help && /usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/Help.dir/help.cpp.o -c /home/magic/Server/res/csrc/Help/help.cpp

Help/CMakeFiles/Help.dir/help.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/Help.dir/help.cpp.i"
	cd /home/magic/Server/res/csrc/build/Help && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/magic/Server/res/csrc/Help/help.cpp > CMakeFiles/Help.dir/help.cpp.i

Help/CMakeFiles/Help.dir/help.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/Help.dir/help.cpp.s"
	cd /home/magic/Server/res/csrc/build/Help && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/magic/Server/res/csrc/Help/help.cpp -o CMakeFiles/Help.dir/help.cpp.s

# Object files for target Help
Help_OBJECTS = \
"CMakeFiles/Help.dir/help.cpp.o"

# External object files for target Help
Help_EXTERNAL_OBJECTS =

Share/libHelp.a: Help/CMakeFiles/Help.dir/help.cpp.o
Share/libHelp.a: Help/CMakeFiles/Help.dir/build.make
Share/libHelp.a: Help/CMakeFiles/Help.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/magic/Server/res/csrc/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX static library ../Share/libHelp.a"
	cd /home/magic/Server/res/csrc/build/Help && $(CMAKE_COMMAND) -P CMakeFiles/Help.dir/cmake_clean_target.cmake
	cd /home/magic/Server/res/csrc/build/Help && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/Help.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
Help/CMakeFiles/Help.dir/build: Share/libHelp.a

.PHONY : Help/CMakeFiles/Help.dir/build

Help/CMakeFiles/Help.dir/clean:
	cd /home/magic/Server/res/csrc/build/Help && $(CMAKE_COMMAND) -P CMakeFiles/Help.dir/cmake_clean.cmake
.PHONY : Help/CMakeFiles/Help.dir/clean

Help/CMakeFiles/Help.dir/depend:
	cd /home/magic/Server/res/csrc/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/magic/Server/res/csrc /home/magic/Server/res/csrc/Help /home/magic/Server/res/csrc/build /home/magic/Server/res/csrc/build/Help /home/magic/Server/res/csrc/build/Help/CMakeFiles/Help.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : Help/CMakeFiles/Help.dir/depend

