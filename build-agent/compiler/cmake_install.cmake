# Install script for directory: /home/s4il0r/Documents/Cursor/li-langverse/li-cursor-agents/data/workspaces/li-langverse/lic/bench_improver-1780130199108/repo/compiler

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
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
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

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/llvm-objdump-22")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/s4il0r/Documents/Cursor/li-langverse/li-cursor-agents/data/workspaces/li-langverse/lic/bench_improver-1780130199108/repo/build-agent/compiler/common/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/s4il0r/Documents/Cursor/li-langverse/li-cursor-agents/data/workspaces/li-langverse/lic/bench_improver-1780130199108/repo/build-agent/compiler/cache/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/s4il0r/Documents/Cursor/li-langverse/li-cursor-agents/data/workspaces/li-langverse/lic/bench_improver-1780130199108/repo/build-agent/compiler/config/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/s4il0r/Documents/Cursor/li-langverse/li-cursor-agents/data/workspaces/li-langverse/lic/bench_improver-1780130199108/repo/build-agent/compiler/analyze/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/s4il0r/Documents/Cursor/li-langverse/li-cursor-agents/data/workspaces/li-langverse/lic/bench_improver-1780130199108/repo/build-agent/compiler/diagnostics/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/s4il0r/Documents/Cursor/li-langverse/li-cursor-agents/data/workspaces/li-langverse/lic/bench_improver-1780130199108/repo/build-agent/compiler/lexer/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/s4il0r/Documents/Cursor/li-langverse/li-cursor-agents/data/workspaces/li-langverse/lic/bench_improver-1780130199108/repo/build-agent/compiler/parser/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/s4il0r/Documents/Cursor/li-langverse/li-cursor-agents/data/workspaces/li-langverse/lic/bench_improver-1780130199108/repo/build-agent/compiler/ast/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/s4il0r/Documents/Cursor/li-langverse/li-cursor-agents/data/workspaces/li-langverse/lic/bench_improver-1780130199108/repo/build-agent/compiler/types/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/s4il0r/Documents/Cursor/li-langverse/li-cursor-agents/data/workspaces/li-langverse/lic/bench_improver-1780130199108/repo/build-agent/compiler/mir/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/s4il0r/Documents/Cursor/li-langverse/li-cursor-agents/data/workspaces/li-langverse/lic/bench_improver-1780130199108/repo/build-agent/compiler/codegen/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/s4il0r/Documents/Cursor/li-langverse/li-cursor-agents/data/workspaces/li-langverse/lic/bench_improver-1780130199108/repo/build-agent/compiler/verify/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/s4il0r/Documents/Cursor/li-langverse/li-cursor-agents/data/workspaces/li-langverse/lic/bench_improver-1780130199108/repo/build-agent/compiler/lic/cmake_install.cmake")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/home/s4il0r/Documents/Cursor/li-langverse/li-cursor-agents/data/workspaces/li-langverse/lic/bench_improver-1780130199108/repo/build-agent/compiler/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
