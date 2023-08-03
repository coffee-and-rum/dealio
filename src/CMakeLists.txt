set( LOCALIZATION 
    main.cpp 
    TestPrint.hpp 
    TestPrint.cpp
    )

source_group(Localization FILES ${LOCALIZATION})

add_executable(${CMAKE_PROJECT_NAME} ${LOCALIZATION})
