

function(set_common_settings target)

    set(globalTag "SML")
    include(TestBigEndian)
    test_big_endian(isBigEndian)

    # Enforce C++17 as the minimum required standard for the target.
    # This automatically propagates to targets that link against this target.
    target_compile_features(${target} PRIVATE 
    "cxx_std_17"
    )

    # Platform definitions using generator expressions.
    # Generator expressions are evaluated at build system generation time, allowing for 
    # more dynamic and accurate compiler definitions per target without manual variable expansion.
    # UNIX is a CMake configure-time variable that is true for any Unix-like platform (Linux, macOS, BSDs).
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

    # Set endianness macros dynamically based on the target architecture's byte order.
    # This prevents the need to rely on compiler-specific built-ins (like __BYTE_ORDER__).
    if(isBigEndian)
        target_compile_definitions(${target} PRIVATE
        "${globalTag}_BIG_ENDIAN_OS=1"
        )
    else()
        target_compile_definitions(${target} PRIVATE
        "${globalTag}_LITTLE_ENDIAN_OS=1"
        )
    endif()

    # Detect the compiler ID using generator expressions and expose it as a preprocessor macro.
    # Useful for conditionally applying compiler-specific workarounds or optimizations in the C++ code.
    target_compile_definitions(${target} PRIVATE
        $<$<CXX_COMPILER_ID:MSVC>:${globalTag}_MSVC_COMPILER=1>
        $<$<CXX_COMPILER_ID:GNU>:${globalTag}_GCC_COMPILER=1>
        $<$<CXX_COMPILER_ID:Clang>:${globalTag}_CLANG_COMPILER=1>
    )

   
    # Automatically compute an uppercase, C-safe identifier based on the target name.
    # This is conventionally used to define export/import macros for dynamic libraries.
    string(TOUPPER "${target}" target_upper)
    string(MAKE_C_IDENTIFIER "${target_upper}" target_upper)
    target_compile_definitions(${target} PRIVATE 
    "${globalTag}_${target_upper}_EXPORTS=1"
    )

    #include(GenerateExportHeader)
    #generate_export_header(${target} EXPORT_MACRO_NAME ${globalTag}_${target_upper}_API)

    # Enable strict compiler warnings across supported compilers to catch potential code quality issues early.
    # Note: These flags are primarily for GCC/Clang. For MSVC, /W4 is typically preferred instead.
    target_compile_options(${target} PRIVATE 
    "-Wall" 
    "-Wextra" 
    "-Wpedantic"
    )

    # Additional compiler visibility and debug-specific options:
    # -fvisibility-ms-compat: Instructs GCC/Clang to hide symbols by default, matching MSVC's __declspec behavior.
    # $<$<CONFIG:Debug>:...>: Applies zero optimization (-O0) and maximum debug information (-g3) exclusively for Debug configuration builds.
    target_compile_options(${target} PRIVATE 
    "-fvisibility-ms-compat"
    $<$<CONFIG:Debug>:-O0;-g3>
    )

    # Linker options (primarily applicable to ELF systems like Linux):
    # -Bsymbolic: Forces the linker to bind global symbol references to the definitions within the shared library itself, 
    #             preventing symbol interposition and slightly improving load times.
    # --as-needed: Prevents linking against shared libraries unless they satisfy unresolved symbol references, reducing bloat.
    # --no-undefined: Enforces strict symbol resolution at link time, failing the build immediately if any symbol is missing.
    # -z,lazy: Instructs the dynamic linker to defer function symbol resolution until the function is first executed.
    # -rpath,$ORIGIN: Embeds a relative search path instruction into the binary, telling the loader to search for shared 
    #                 libraries in the same directory as the executing binary ($ORIGIN).
    target_link_options(${target} PRIVATE 
    "-Wl,-Bsymbolic"
    "-Wl,--as-needed"
    "-Wl,--no-undefined"
    "-Wl,-z,lazy"
    "-Wl,-rpath,\$ORIGIN"
    )

endfunction()

# Helper function to recursively discover source and header files relative to the caller's directory.
# CAUTION: Using globbing for source files is historically discouraged by CMake documentation because 
# adding or removing files will not automatically trigger a re-configuration of the build system unless 
# the CMakeLists.txt itself is modified, or CMake version 3.12+ features (like CONFIGURE_DEPENDS) are utilized.
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