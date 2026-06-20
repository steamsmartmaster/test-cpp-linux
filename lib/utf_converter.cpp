#include "utf_converter.h"

#include <stdexcept>

#if defined(SML_WINDOWS_OS)
#include <windows.h>
#else
#include <iconv.h>
#endif

namespace utf_utils {

#if defined(SML_WINDOWS_OS)

std::u16string utf8_to_utf16(const std::string& utf8_str) {
    if (utf8_str.empty()) return {};
    int size_needed = MultiByteToWideChar(CP_UTF8, 0, utf8_str.data(), (int)utf8_str.size(), NULL, 0);
    if (size_needed <= 0) {
        throw std::runtime_error("UTF-8 to UTF-16 conversion failed on Windows");
    }
    std::u16string result(size_needed, 0);
    if (MultiByteToWideChar(CP_UTF8, 0, utf8_str.data(), (int)utf8_str.size(), (LPWSTR)result.data(), size_needed) <= 0) {
        throw std::runtime_error("UTF-8 to UTF-16 conversion failed on Windows");
    }
    return result;
}

std::string utf16_to_utf8(const std::u16string& utf16_str) {
    if (utf16_str.empty()) return {};
    int size_needed = WideCharToMultiByte(CP_UTF8, 0, (LPCWSTR)utf16_str.data(), (int)utf16_str.size(), NULL, 0, NULL, NULL);
    if (size_needed <= 0) {
        throw std::runtime_error("UTF-16 to UTF-8 conversion failed on Windows");
    }
    std::string result(size_needed, 0);
    if (WideCharToMultiByte(CP_UTF8, 0, (LPCWSTR)utf16_str.data(), (int)utf16_str.size(), result.data(), size_needed, NULL, NULL) <= 0) {
        throw std::runtime_error("UTF-16 to UTF-8 conversion failed on Windows");
    }
    return result;
}

#elif defined(SML_UNIX_OS)

#if defined(SML_BIG_ENDIAN_OS)
#define UTF16_ENCODING "UTF-16BE"
#elif defined(SML_LITTLE_ENDIAN_OS)
#define UTF16_ENCODING "UTF-16LE"
#else
#error "Endian macro not defined"
#endif

std::u16string utf8_to_utf16(const std::string& utf8_str) {
    if (utf8_str.empty()) return {};
    iconv_t cd = iconv_open(UTF16_ENCODING, "UTF-8");
    if (cd == (iconv_t)-1) {
        throw std::runtime_error("iconv_open failed for UTF-8 to UTF-16 conversion");
    }

    size_t inbytesleft = utf8_str.size();
    char* inbuf = const_cast<char*>(utf8_str.data());

    size_t outbytesleft = inbytesleft * 4;
    std::u16string result(outbytesleft / sizeof(char16_t), 0);
    char* outbuf = reinterpret_cast<char*>(result.data());

    size_t res = iconv(cd, &inbuf, &inbytesleft, &outbuf, &outbytesleft);
    if (iconv_close(cd) != 0) {
        throw std::runtime_error("iconv_close failed for UTF-8 to UTF-16 conversion");
    }

    if (res == (size_t)-1) {
        throw std::runtime_error("UTF-8 to UTF-16 conversion failed via iconv");
    }

    result.resize((outbuf - reinterpret_cast<char*>(result.data())) / sizeof(char16_t));
    return result;
}

std::string utf16_to_utf8(const std::u16string& utf16_str) {
    if (utf16_str.empty()) return {};
    iconv_t cd = iconv_open("UTF-8", UTF16_ENCODING);
    if (cd == (iconv_t)-1) {
        throw std::runtime_error("iconv_open failed for UTF-16 to UTF-8 conversion");
    }

    size_t inbytesleft = utf16_str.size() * sizeof(char16_t);
    char* inbuf = reinterpret_cast<char*>(const_cast<char16_t*>(utf16_str.data()));

    size_t outbytesleft = inbytesleft * 3;
    std::string result(outbytesleft, 0);
    char* outbuf = result.data();

    size_t res = iconv(cd, &inbuf, &inbytesleft, &outbuf, &outbytesleft);
    if (iconv_close(cd) != 0) {
        throw std::runtime_error("iconv_close failed for UTF-16 to UTF-8 conversion");
    }

    if (res == (size_t)-1) {
        throw std::runtime_error("UTF-16 to UTF-8 conversion failed via iconv");
    }

    result.resize(outbuf - result.data());
    return result;
}


#else

#error "Unsupported platform: expected SML_WINDOWS_OS or SML_UNIX_OS"

#endif

} // namespace utf_utils
