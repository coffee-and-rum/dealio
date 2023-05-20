cmake_minimum_required(VERSION 3.23)

if (NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 20)
endif()

# strongly encouraged to enable this globally to avoid conflicts between
# -Wpedantic being enabled and -std=c++20 and -std=gnu++20 for example
# when compiling with PCH enabled
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

project(
  dealio
  VERSION 0.0.1
  DESCRIPTION "Dealio - deal documents creator"
  HOMEPAGE_URL "https://github.com/coffee-and-rum/dealio"
  LANGUAGES CXX C)

include(Dependencies.cmake)
setup_dependencies()

add_subdirectory(src)

include(CTest)

