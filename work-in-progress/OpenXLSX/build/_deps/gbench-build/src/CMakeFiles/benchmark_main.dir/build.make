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
CMAKE_SOURCE_DIR = /mnt/DATA/Projects/sgi/OpenXLSX

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /mnt/DATA/Projects/sgi/OpenXLSX/build

# Include any dependencies generated for this target.
include _deps/gbench-build/src/CMakeFiles/benchmark_main.dir/depend.make

# Include the progress variables for this target.
include _deps/gbench-build/src/CMakeFiles/benchmark_main.dir/progress.make

# Include the compile flags for this target's objects.
include _deps/gbench-build/src/CMakeFiles/benchmark_main.dir/flags.make

_deps/gbench-build/src/CMakeFiles/benchmark_main.dir/benchmark_main.cc.o: _deps/gbench-build/src/CMakeFiles/benchmark_main.dir/flags.make
_deps/gbench-build/src/CMakeFiles/benchmark_main.dir/benchmark_main.cc.o: _deps/gbench-src/src/benchmark_main.cc
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/mnt/DATA/Projects/sgi/OpenXLSX/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object _deps/gbench-build/src/CMakeFiles/benchmark_main.dir/benchmark_main.cc.o"
	cd /mnt/DATA/Projects/sgi/OpenXLSX/build/_deps/gbench-build/src && /usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/benchmark_main.dir/benchmark_main.cc.o -c /mnt/DATA/Projects/sgi/OpenXLSX/build/_deps/gbench-src/src/benchmark_main.cc

_deps/gbench-build/src/CMakeFiles/benchmark_main.dir/benchmark_main.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/benchmark_main.dir/benchmark_main.cc.i"
	cd /mnt/DATA/Projects/sgi/OpenXLSX/build/_deps/gbench-build/src && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /mnt/DATA/Projects/sgi/OpenXLSX/build/_deps/gbench-src/src/benchmark_main.cc > CMakeFiles/benchmark_main.dir/benchmark_main.cc.i

_deps/gbench-build/src/CMakeFiles/benchmark_main.dir/benchmark_main.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/benchmark_main.dir/benchmark_main.cc.s"
	cd /mnt/DATA/Projects/sgi/OpenXLSX/build/_deps/gbench-build/src && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /mnt/DATA/Projects/sgi/OpenXLSX/build/_deps/gbench-src/src/benchmark_main.cc -o CMakeFiles/benchmark_main.dir/benchmark_main.cc.s

# Object files for target benchmark_main
benchmark_main_OBJECTS = \
"CMakeFiles/benchmark_main.dir/benchmark_main.cc.o"

# External object files for target benchmark_main
benchmark_main_EXTERNAL_OBJECTS =

output/libbenchmark_main.a: _deps/gbench-build/src/CMakeFiles/benchmark_main.dir/benchmark_main.cc.o
output/libbenchmark_main.a: _deps/gbench-build/src/CMakeFiles/benchmark_main.dir/build.make
output/libbenchmark_main.a: _deps/gbench-build/src/CMakeFiles/benchmark_main.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/mnt/DATA/Projects/sgi/OpenXLSX/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX static library ../../../output/libbenchmark_main.a"
	cd /mnt/DATA/Projects/sgi/OpenXLSX/build/_deps/gbench-build/src && $(CMAKE_COMMAND) -P CMakeFiles/benchmark_main.dir/cmake_clean_target.cmake
	cd /mnt/DATA/Projects/sgi/OpenXLSX/build/_deps/gbench-build/src && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/benchmark_main.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
_deps/gbench-build/src/CMakeFiles/benchmark_main.dir/build: output/libbenchmark_main.a

.PHONY : _deps/gbench-build/src/CMakeFiles/benchmark_main.dir/build

_deps/gbench-build/src/CMakeFiles/benchmark_main.dir/clean:
	cd /mnt/DATA/Projects/sgi/OpenXLSX/build/_deps/gbench-build/src && $(CMAKE_COMMAND) -P CMakeFiles/benchmark_main.dir/cmake_clean.cmake
.PHONY : _deps/gbench-build/src/CMakeFiles/benchmark_main.dir/clean

_deps/gbench-build/src/CMakeFiles/benchmark_main.dir/depend:
	cd /mnt/DATA/Projects/sgi/OpenXLSX/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /mnt/DATA/Projects/sgi/OpenXLSX /mnt/DATA/Projects/sgi/OpenXLSX/build/_deps/gbench-src/src /mnt/DATA/Projects/sgi/OpenXLSX/build /mnt/DATA/Projects/sgi/OpenXLSX/build/_deps/gbench-build/src /mnt/DATA/Projects/sgi/OpenXLSX/build/_deps/gbench-build/src/CMakeFiles/benchmark_main.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : _deps/gbench-build/src/CMakeFiles/benchmark_main.dir/depend
