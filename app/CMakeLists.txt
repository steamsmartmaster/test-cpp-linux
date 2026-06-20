add_executable(app main.cpp)

set_common_settings(app)

target_link_libraries(app PRIVATE utf_converter)
