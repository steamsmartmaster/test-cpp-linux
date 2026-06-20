cmake_minimum_required(VERSION 3.11)
project(UtfConverterProject VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

include(${CMAKE_CURRENT_LIST_DIR}/CMakeCommonSettings.cmake)

add_subdirectory(lib)
add_subdirectory(app)
