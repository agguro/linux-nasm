# Install script for directory: /home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/plugins

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

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/DebuggerCore/cmake_install.cmake")
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/Analyzer/cmake_install.cmake")
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/Assembler/cmake_install.cmake")
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/BinaryInfo/cmake_install.cmake")
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/BinarySearcher/cmake_install.cmake")
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/Bookmarks/cmake_install.cmake")
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/BreakpointManager/cmake_install.cmake")
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/CheckVersion/cmake_install.cmake")
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/DumpState/cmake_install.cmake")
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/FunctionFinder/cmake_install.cmake")
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/HardwareBreakpoints/cmake_install.cmake")
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/OpcodeSearcher/cmake_install.cmake")
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/ProcessProperties/cmake_install.cmake")
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/ROPTool/cmake_install.cmake")
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/References/cmake_install.cmake")
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/SymbolViewer/cmake_install.cmake")
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/Backtrace/cmake_install.cmake")
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/HeapAnalyzer/cmake_install.cmake")
  include("/home/agguro/Repository/Github/edb-debugger-0.9.21/edb-debugger-0.9.21/build/plugins/ODbgRegisterView/cmake_install.cmake")

endif()

