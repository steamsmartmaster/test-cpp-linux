add_library(utf_converter SHARED utf_converter.cpp)

set_common_settings(utf_converter)

target_include_directories(utf_converter PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

if(NOT WIN32)
    find_package(Iconv REQUIRED)
    target_include_directories(utf_converter PRIVATE ${Iconv_INCLUDE_DIRS})
    target_link_libraries(utf_converter PRIVATE Iconv::Iconv)
endif()
