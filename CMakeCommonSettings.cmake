

function(set_common_settings target)

    set(globalTag "SML")
    include(TestBigEndian)
    test_big_endian(isBigEndian)

    # Require C++17 standard for the target
    target_compile_features(${target} PRIVATE 
    "cxx_std_17"
    )

    # Platform definitions using generator expressions
    # UNIX is a CMake configure-time variable that is true for any Unix-like platform.
    target_compile_definitions(${target} PRIVATE
        $<$<BOOL:${WIN32}>:${globalTag}_WINDOWS_OS=1>
        $<$<BOOL:${UNIX}>:${globalTag}_UNIX_OS=1>
        $<$<PLATFORM_ID:Linux>:${globalTag}_LINUX_OS=1>
        $<$<PLATFORM_ID:Darwin>:${globalTag}_MACOS_OS=1>
        $<$<PLATFORM_ID:iOS>:${globalTag}_IOS_OS=1>
        $<$<PLATFORM_ID:Android>:${globalTag}_ANDROID_OS=1>
        $<$<PLATFORM_ID:FreeBSD>:${globalTag}_FREEBSD_OS=1>
        $<$<PLATFORM_ID:OpenBSD>:${globalTag}_OPENBSD_OS=1>
    )

    if(isBigEndian)
        target_compile_definitions(${target} PRIVATE
        "${globalTag}_BIG_ENDIAN_OS=1"
        )
    else()
        target_compile_definitions(${target} PRIVATE
        "${globalTag}_LITTLE_ENDIAN_OS=1"
        )
    endif()

    # Compiler definitions using generator expressions
    target_compile_definitions(${target} PRIVATE
        $<$<CXX_COMPILER_ID:MSVC>:${globalTag}_MSVC_COMPILER=1>
        $<$<CXX_COMPILER_ID:GNU>:${globalTag}_GCC_COMPILER=1>
        $<$<CXX_COMPILER_ID:Clang>:${globalTag}_CLANG_COMPILER=1>
    )

   
    #convert ${target} to c identifier and uppercase for export macros
    #define the macro name as ${target_upper}_EXPORTS for export symbols when building the library      
    string(TOUPPER "${target}" target_upper)
    string(MAKE_C_IDENTIFIER "${target_upper}" target_upper)
    target_compile_definitions(${target} PRIVATE 
    "${globalTag}_${target_upper}_EXPORTS=1"
    )

    #include(GenerateExportHeader)
    #generate_export_header(${target} EXPORT_MACRO_NAME ${globalTag}_${target_upper}_API)

    # Enable strict compiler warnings to catch potential issues early
    target_compile_options(${target} PRIVATE 
    "-Wall" 
    "-Wextra" 
    "-Wpedantic"
    )

    # Additional compiler options:
    # -fvisibility-ms-compat: Match MSVC symbol visibility behavior (hides symbols by default unless explicitly exported)
    # $<$<CONFIG:Debug>:...>: CMake generator expression applying no optimization (-O0) and max debug info (-g3) only for Debug builds
    target_compile_options(${target} PRIVATE 
    "-fvisibility-ms-compat"
    $<$<CONFIG:Debug>:-O0;-g3>
    )

    # Linker options:
    # -Bsymbolic: Bind references to global symbols to their definitions within the shared library (optimizes load time and prevents symbol collision)
    # --as-needed: Only link against libraries that provide actually used symbols (reduces unnecessary dependencies)
    # --no-undefined: Fail the build immediately if there are unresolved symbols at link time (prevents runtime crashes)
    # -z,lazy: Defer symbol resolution until the function is actually called at runtime (lazy binding)
    # rpath,$ORIGIN: Add the directory containing the current executable/library to the runtime search path for shared libraries
    target_link_options(${target} PRIVATE 
    "-Wl,-Bsymbolic"
    "-Wl,--as-needed"
    "-Wl,--no-undefined"
    "-Wl,-z,lazy"
    "-Wl,-rpath,\$ORIGIN"
    )

endfunction()

# Helper function to glob all C++ source and header files in the current directory and subdirectories
function(glob_sources_and_headers out_var)
    file(GLOB_RECURSE SOURCES_AND_HEADERS 
        "${CMAKE_CURRENT_LIST_DIR}/*.cpp"
        "${CMAKE_CURRENT_LIST_DIR}/*.c"
        "${CMAKE_CURRENT_LIST_DIR}/*.cc"
        "${CMAKE_CURRENT_LIST_DIR}/*.cxx"
        "${CMAKE_CURRENT_LIST_DIR}/*.h"
        "${CMAKE_CURRENT_LIST_DIR}/*.hpp"
        "${CMAKE_CURRENT_LIST_DIR}/*.hxx"
    )
    set(${out_var} ${SOURCES_AND_HEADERS} PARENT_SCOPE)
endfunction()