#include <iostream>
#include <string>
#include "utf_converter.h"

int main() {
    try {
        std::string original_utf8 = "Hello, 世界! (World)";
        std::cout << "Original UTF-8: " << original_utf8 << "\n";

        std::u16string utf16_str = utf_utils::utf8_to_utf16(original_utf8);
        std::cout << "Converted to UTF-16. Length: " << utf16_str.length() << " code units.\n";

        std::string converted_back_utf8 = utf_utils::utf16_to_utf8(utf16_str);
        std::cout << "Converted back to UTF-8: " << converted_back_utf8 << "\n";

        if (original_utf8 == converted_back_utf8) {
            std::cout << "Conversion successful!" << std::endl;
        } else {
            std::cout << "Conversion failed!" << std::endl;
            return 1;
        }
    } catch (const std::exception& ex) {
        std::cerr << "Conversion error: " << ex.what() << '\n';
        return 1;
    }

    return 0;
}
