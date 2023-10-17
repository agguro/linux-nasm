//------------------------------------------------
//               Ch03_07.cpp
//------------------------------------------------

#include <iostream>
#include <string.h>

using namespace std;

extern "C" size_t ConcatStrings_(char* des, size_t des_size, const char* const* src, size_t src_n);

void PrintResult(const char* msg, const char* des, size_t des_len, const char* const* src, size_t src_n)
{
    string s_test;
    const char nl = '\n';

    cout << nl << "Test case: " << msg << nl;
    cout << "  Original Strings" << nl;

    for (size_t i = 0; i < src_n; i++)
    {
        const char* s1 = (strlen(src[i]) == 0) ? "<empty string>" : src[i];
        cout << "    i:" << i << " " << s1 << nl;

        s_test += src[i];
    }

    const char* s2 = (des_len == 0) ? "<empty string>" : des;

    cout << "  Concatenated Result" << nl;
    cout << "    " << s2 << nl;

    if (s_test != des)
        cout << "  Error - test string compare failed" << nl;
}

int main()
{
    // Destination buffer size OK
    const char* src1[] = { "One ", "Two ", "Three ", "Four" };
    size_t src1_n = sizeof(src1) / sizeof(char*);
    const size_t des1_size = 64;
    char des1[des1_size];

    size_t des1_len = ConcatStrings_(des1, des1_size, src1, src1_n);
    PrintResult("destination buffer size OK", des1, des1_len, src1, src1_n);

    // Destination buffer too small
    const char* src2[] = { "Red ", "Green ", "Blue ", "Yellow " };
    size_t src2_n = sizeof(src2) / sizeof(char*);
    const size_t des2_size = 16;
    char des2[des2_size];

    size_t des2_len = ConcatStrings_(des2, des2_size, src2, src2_n);
    PrintResult("destination buffer too small", des2, des2_len, src2, src2_n);

    // Empty source string
    const char* src3[] = { "Plane ", "Car ", "", "Truck ", "Boat ", "Train ", "Bicycle " };
    size_t src3_n = sizeof(src3) / sizeof(char*);
    const size_t des3_size = 128;
    char des3[des3_size];

    size_t des3_len = ConcatStrings_(des3, des3_size, src3, src3_n);
    PrintResult("empty source string", des3, des3_len, src3, src3_n);

    // All strings empty
    const char* src4[] = { "", "", "", "" };
    size_t src4_n = sizeof(src4) / sizeof(char*);
    const size_t des4_size = 42;
    char des4[des4_size];

    size_t des4_len = ConcatStrings_(des4, des4_size, src4, src4_n);
    PrintResult("all strings empty", des4, des4_len, src4, src4_n);

    // Minimum des_size
    const char* src5[] = { "1", "22", "333", "4444" };
    size_t src5_n = sizeof(src5) / sizeof(char*);
    const size_t des5_size = 11;
    char des5[des5_size];

    size_t des5_len = ConcatStrings_(des5, des5_size, src5, src5_n);
    PrintResult("minimum des_size", des5, des5_len, src5, src5_n);

    return 0;
}
