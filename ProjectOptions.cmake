include(cmake/SystemLink.cmake)
include(cmake/LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)


macro(dealio_supports_sanitizers)
  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
    set(SUPPORTS_UBSAN ON)
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    set(SUPPORTS_ASAN ON)
  endif()
endmacro()

macro(dealio_setup_options)
  option(dealio_ENABLE_HARDENING "Enable hardening" ON)
  option(dealio_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    dealio_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    dealio_ENABLE_HARDENING
    OFF)

  dealio_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR dealio_PACKAGING_MAINTAINER_MODE)
    option(dealio_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(dealio_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(dealio_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(dealio_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(dealio_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(dealio_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(dealio_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(dealio_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(dealio_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(dealio_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(dealio_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(dealio_ENABLE_PCH "Enable precompiled headers" OFF)
    option(dealio_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(dealio_ENABLE_IPO "Enable IPO/LTO" ON)
    option(dealio_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(dealio_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(dealio_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(dealio_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(dealio_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(dealio_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(dealio_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(dealio_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(dealio_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(dealio_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(dealio_ENABLE_PCH "Enable precompiled headers" OFF)
    option(dealio_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      dealio_ENABLE_IPO
      dealio_WARNINGS_AS_ERRORS
      dealio_ENABLE_USER_LINKER
      dealio_ENABLE_SANITIZER_ADDRESS
      dealio_ENABLE_SANITIZER_LEAK
      dealio_ENABLE_SANITIZER_UNDEFINED
      dealio_ENABLE_SANITIZER_THREAD
      dealio_ENABLE_SANITIZER_MEMORY
      dealio_ENABLE_UNITY_BUILD
      dealio_ENABLE_CLANG_TIDY
      dealio_ENABLE_CPPCHECK
      dealio_ENABLE_COVERAGE
      dealio_ENABLE_PCH
      dealio_ENABLE_CACHE)
  endif()

  dealio_check_libfuzzer_support(LIBFUZZER_SUPPORTED)
  if(LIBFUZZER_SUPPORTED AND (dealio_ENABLE_SANITIZER_ADDRESS OR dealio_ENABLE_SANITIZER_THREAD OR dealio_ENABLE_SANITIZER_UNDEFINED))
    set(DEFAULT_FUZZER ON)
  else()
    set(DEFAULT_FUZZER OFF)
  endif()

  option(dealio_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})

endmacro()

macro(dealio_global_options)
  if(dealio_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    dealio_enable_ipo()
  endif()

  dealio_supports_sanitizers()

  if(dealio_ENABLE_HARDENING AND dealio_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR dealio_ENABLE_SANITIZER_UNDEFINED
       OR dealio_ENABLE_SANITIZER_ADDRESS
       OR dealio_ENABLE_SANITIZER_THREAD
       OR dealio_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${dealio_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${dealio_ENABLE_SANITIZER_UNDEFINED}")
    dealio_enable_hardening(dealio_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(dealio_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(dealio_warnings INTERFACE)
  add_library(dealio_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  dealio_set_project_warnings(
    dealio_warnings
    ${dealio_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  if(dealio_ENABLE_USER_LINKER)
    include(cmake/Linker.cmake)
    configure_linker(dealio_options)
  endif()

  include(cmake/Sanitizers.cmake)
  dealio_enable_sanitizers(
    dealio_options
    ${dealio_ENABLE_SANITIZER_ADDRESS}
    ${dealio_ENABLE_SANITIZER_LEAK}
    ${dealio_ENABLE_SANITIZER_UNDEFINED}
    ${dealio_ENABLE_SANITIZER_THREAD}
    ${dealio_ENABLE_SANITIZER_MEMORY})

  set_target_properties(dealio_options PROPERTIES UNITY_BUILD ${dealio_ENABLE_UNITY_BUILD})

  if(dealio_ENABLE_PCH)
    target_precompile_headers(
      dealio_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(dealio_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    dealio_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(dealio_ENABLE_CLANG_TIDY)
    dealio_enable_clang_tidy(dealio_options ${dealio_WARNINGS_AS_ERRORS})
  endif()

  if(dealio_ENABLE_CPPCHECK)
    dealio_enable_cppcheck(${dealio_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(dealio_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    dealio_enable_coverage(dealio_options)
  endif()

  if(dealio_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(dealio_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(dealio_ENABLE_HARDENING AND NOT dealio_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR dealio_ENABLE_SANITIZER_UNDEFINED
       OR dealio_ENABLE_SANITIZER_ADDRESS
       OR dealio_ENABLE_SANITIZER_THREAD
       OR dealio_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    dealio_enable_hardening(dealio_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()
