glob_sources_and_headers(APP_SOURCES)
add_executable(app ${APP_SOURCES})

set_common_settings(app)

target_link_libraries(app PRIVATE utf_converter)


install(TARGETS app
    DESTINATION bin
)