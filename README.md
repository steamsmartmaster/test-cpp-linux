# test-cpp-linux

Cross-platform minimal C++ project demonstrating a shared library
that provides UTF-8 <-> UTF-16 conversion utilities and a small
executable that exercises the library.

## Build (Linux)

Requirements:
- CMake 3.11+
- A C++17 compiler (GCC/Clang)
- `libiconv` (if your system needs it; many Linux distros provide iconv as part of glibc)

Build steps:

```bash
mkdir -p build && cd build
cmake ..
cmake --build . --config Release
```

Run:

```bash
./app/app
```

## Notes
- The project uses modern CMake patterns in `CMakeCommonSettings.cmake`.
- Platform-specific conversion is implemented using `iconv` on Unix
  and WinAPI on Windows.

## Remote
Repository pushed to https://github.com/steamsmartmaster/test-cpp-linux.git