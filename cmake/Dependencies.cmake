include(${CMAKE_SOURCE_DIR}/cmake/CPM.cmake)

# Done as a function so that updates to variables like
# CMAKE_CXX_FLAGS don't propagate out to other
# targets
function(setup_dependencies)

  # For each dependency, see if it's
  # already been provided to us by a parent project

  if(NOT TARGET Catch2::Catch2WithMain)
    cpmaddpackage("gh:catchorg/Catch2@3.3.2")
  endif()

  if(NOT TARGET gettext)
    cpmaddpackage(
      NAME
      gettext
      VERSION
      0.21-v1.16
      URL
      https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.21-v1.16/gettext0.21-iconv1.16-shared-64.zip
      DOWNLOAD_ONLY
      YES)
    if(gettext_ADDED)
      # lua has no CMake support, so we create our own target

      # file(GLOB gettext_sources ${gettext_SOURCE_DIR}/*.c)
      # list(
      #   REMOVE_ITEM
      #   lua_sources
      #   "${lua_SOURCE_DIR}/lua.c"
      #   "${lua_SOURCE_DIR}/luac.c")
      # add_library(lua STATIC ${lua_sources})

      add_library(
        gettext
        SHARED
        IMPORTED
        GLOBAL)
      add_library(
        intl
        SHARED
        IMPORTED
        GLOBAL)

      target_include_directories(gettext PUBLIC $<BUILD_INTERFACE:${gettext_SOURCE_DIR}>)
      target_include_directories(intl PUBLIC $<BUILD_INTERFACE:${gettext_SOURCE_DIR}>)

      # set_target_properties(
      #   gettext PROPERTIES IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/external/gettext/libgettextlib-0-21.dll
      # )#.lib meybe or ${GETTEXT_LIBRARY}
      # target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE ${DEPENDENCIES} gettext) # ${GETTEXT_LIBRARIES}
      # target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${gettext_SOURCE_DIR}/include)
    endif()
  endif()

endfunction()
