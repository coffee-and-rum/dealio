cmake_minimum_required(VERSION 3.23)

if (NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 20)
endif()

# strongly encouraged to enable this globally to avoid conflicts between
# -Wpedantic being enabled and -std=c++20 and -std=gnu++20 for example
# when compiling with PCH enabled
set(CMAKE_CXX_EXTENSIONS OFF)

project(
  dealio
  VERSION 0.0.1
  DESCRIPTION ""
  HOMEPAGE_URL "https://github.com/coffee-and-rum/dealio"
  LANGUAGES CXX C)

include(cmake/PreventInSourceBuilds.cmake)
include(ProjectOptions.cmake)

dealio_setup_options()

dealio_global_options()
include(Dependencies.cmake)
dealio_setup_dependencies()

dealio_local_options()

# Adding the src:
add_subdirectory(src)

# Don't even look at tests if we're not top level
if(NOT PROJECT_IS_TOP_LEVEL)
  return()
endif()

# Adding the tests:
include(CTest)

