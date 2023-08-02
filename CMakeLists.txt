cmake_minimum_required(VERSION 3.23)

if(NOT DEFINED CMAKE_CXX_STANDARD)
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

add_subdirectory(external)

add_subdirectory(src)


set(TEXTDOMAIN ${CMAKE_PROJECT_NAME})

# make_directory(${CMAKE_CURRENT_BINARY_DIR}/locale)
# foreach(ff IN LISTS ffs)
#   get_filename_component(lang ${ff} NAME_WE)
#   make_directory(${CMAKE_CURRENT_BINARY_DIR}/locale/${lang})
#   make_directory(${CMAKE_CURRENT_BINARY_DIR}/locale/${lang}/LC_MESSAGES)
#   add_custom_command(
#     OUTPUT
#       ${CMAKE_CURRENT_BINARY_DIR}/locale/${lang}/LC_MESSAGES/${TEXTDOMAIN}.mo
#     DEPENDS
#       ${ff}
#     COMMAND msgfmt -o
#       ${CMAKE_CURRENT_BINARY_DIR}/locale/${lang}/LC_MESSAGES/${TEXTDOMAIN}.mo
#       ${ff}
#   )
#   add_custom_target(gen_${lang} ALL DEPENDS
#     ${CMAKE_CURRENT_BINARY_DIR}/locale/${lang}/LC_MESSAGES/${TEXTDOMAIN}.mo
#   )
#   add_test(NAME ${lang} COMMAND main)
#   set_property(TEST ${lang} APPEND PROPERTY ENVIRONMENT
#     TEXTDOMAINDIR=${CMAKE_CURRENT_BINARY_DIR}/locale
#     LANGUAGE=${lang}
#   )
#   set_tests_properties(${lang} PROPERTIES
#     PASS_REGULAR_EXPRESSION "${lang} foo"
#   )
# endforeach()

include(CTest)

install(TARGETS dealio RUNTIME DESTINATION bin)

set(GIT_SHA
    "Unknown"
    CACHE STRING "SHA this build was generated from")

string(
  SUBSTRING "${GIT_SHA}"
            0
            8
            GIT_SHORT_SHA)

set(CPACK_PACKAGE_FILE_NAME
    "${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}-${GIT_SHORT_SHA}-${CMAKE_SYSTEM_NAME}-${CMAKE_BUILD_TYPE}-${CMAKE_CXX_COMPILER_ID}-${CMAKE_CXX_COMPILER_VERSION}"
)

include(CPack)
