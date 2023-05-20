# add_subdirectory(sdl)
# add_subdirectory(fltk)

# find_package(fmt CONFIG)
# find_package(spdlog CONFIG)
# find_package(CLI11 CONFIG REQUIRED)

# Generic test that uses conan libs
add_executable(dealio main.cpp)
target_link_libraries(
  dealio
  PUBLIC dealio_options dealio_warnings
  PRIVATE )

target_include_directories(dealio PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")
