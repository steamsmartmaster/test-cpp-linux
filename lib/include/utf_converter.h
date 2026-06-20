#pragma once

#include <string>

#if defined(SML_WINDOWS_OS)
#  ifdef SML_UTF_CONVERTER_EXPORTS
#    define SML_UTF_CONVERTER_API __declspec(dllexport)
#  else
#    define SML_UTF_CONVERTER_API __declspec(dllimport)
#  endif
#else
#  define SML_UTF_CONVERTER_API __attribute__((visibility("default")))
#endif

namespace utf_utils {

SML_UTF_CONVERTER_API std::u16string utf8_to_utf16(const std::string& utf8_str);
SML_UTF_CONVERTER_API std::string utf16_to_utf8(const std::u16string& utf16_str);

} // namespace utf_utils
