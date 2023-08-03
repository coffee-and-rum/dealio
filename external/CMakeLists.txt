include(${CMAKE_SOURCE_DIR}/cmake/Dependencies.cmake)
# setup_dependencies()

# find_package(Gettext REQUIRED)
find_package(Intl REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC ${Intl_LIBRARY})
target_include_directories(${PROJECT_NAME} PUBLIC ${Intl_INCLUDE_DIRS})