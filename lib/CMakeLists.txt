glob_sources_and_headers(LIB_SOURCES)
add_library(utf_converter SHARED ${LIB_SOURCES})

set_common_settings(utf_converter)

target_include_directories(utf_converter PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

if(NOT WIN32)
    find_package(Iconv REQUIRED)
    target_include_directories(utf_converter PRIVATE ${Iconv_INCLUDE_DIRS})
    target_link_libraries(utf_converter PRIVATE Iconv::Iconv)
endif()


install(TARGETS utf_converter
    DESTINATION bin
)