#include <stdio.h>
#include <stdint.h>
#include <wchar.h>

extern "C" int ConcatStrings_(wchar_t* des, int des_size, const wchar_t* const* src, int src_n);

int main()
{
    wprintf(L"\nResults for ConcatStrings\n");

    // Destination buffer large enough
    wprintf(L"Destination buffer large enough\n");
    wchar_t* src1[] = { (wchar_t*)(L"One "), (wchar_t*)(L"Two "), (wchar_t*)(L"Three "), (wchar_t*)(L"Four") };
    int src1_n = sizeof(src1) / sizeof(wchar_t*);
    const int des1_size = 64;
    wchar_t des1[des1_size];

    int des1_len = ConcatStrings_(des1, des1_size, src1, src1_n);
    wchar_t* des1_temp = (*des1 != '\0') ? des1 : (wchar_t*)(L"<empty>");
    wprintf((wchar_t*)(L"  des_len: %d (%d) des: %ls \n"), des1_len, wcslen(des1_temp), des1_temp);

    //Destination buffer too small
    wprintf(L"Destination buffer too small, Yellow isn't displayed\n");
    wchar_t* src2[] = { (wchar_t*)(L"Red "), (wchar_t*)(L"Green "), (wchar_t*)(L"Blue "), (wchar_t*)(L"Yellow ") };
    int src2_n = sizeof(src2) / sizeof(wchar_t*);
    const int des2_size = 16;
    wchar_t des2[des2_size];

    int des2_len = ConcatStrings_(des2, des2_size, src2, src2_n);
    wchar_t* des2_temp = (*des2 != '\0') ? des2 : (wchar_t*)(L"<empty>");
    wprintf((wchar_t*)(L"  des_len: %d (%d) des: %ls \n"), des2_len, wcslen(des2_temp), des2_temp);

    // Empty string test
    wprintf(L"Empty string test\n");
    wchar_t* src3[] = { (wchar_t*)(L"Airplane "), (wchar_t*)(L"Car "), (wchar_t*)(L"Truck "), (wchar_t*)(L"Boat ") };
    int src3_n = sizeof(src3) / sizeof(wchar_t*);
    const int des3_size = 128;
    wchar_t des3[des3_size];

    int des3_len = ConcatStrings_(des3, des3_size, src3, src3_n);
    wchar_t* des3_temp = (*des3 != '\0') ? des3 : (wchar_t*)(L"<empty>");
    wprintf((wchar_t*)(L"  des_len: %d (%d) des: %ls \n"), des3_len, wcslen(des3_temp), des3_temp);

    return 0;
}
