//------------------------------------------------
//               Ch05_04.cpp
//------------------------------------------------

#include <string>
#include <iostream>
#include <iomanip>
#include <limits>

using namespace std;

extern "C" void CompareVCOMISS_(float a, float b, bool* results);
extern "C" void CompareVCOMISD_(double a, double b, bool* results);

const char* c_OpStrings[] = {"UO", "LT", "LE", "EQ", "NE", "GT", "GE"};
const size_t c_NumOpStrings = sizeof(c_OpStrings) / sizeof(char*);

const string g_Dashes(72, '-');

template <typename T> void PrintResults(T a, T b, const bool* cmp_results)
{
    cout << "a = " << a << ", ";
    cout << "b = " << b << '\n';

    for (size_t i = 0; i < c_NumOpStrings; i++)
    {
        cout << c_OpStrings[i] << '=';
        cout << boolalpha << left << setw(6) << cmp_results[i] << ' ';
    }

    cout << "\n\n";
}

void CompareVCOMISS()
{
    const size_t n = 6;
    float a[n] {120.0, 250.0, 300.0, -18.0, -81.0, 42.0};
    float b[n] {130.0, 240.0, 300.0, 32.0, -100.0, 0.0};

    // Set NAN test value
    b[n - 1] = numeric_limits<float>::quiet_NaN();

    cout << "\nResults for CompareVCOMISS\n";
    cout << g_Dashes << '\n';

    for (size_t i = 0; i < n; i++)
    {
        bool cmp_results[c_NumOpStrings];

        CompareVCOMISS_(a[i], b[i], cmp_results);
        PrintResults(a[i], b[i], cmp_results);
    }
}

void CompareVCOMISD(void)
{
    const size_t n = 6;
    double a[n] {120.0, 250.0, 300.0, -18.0, -81.0, 42.0};
    double b[n] {130.0, 240.0, 300.0, 32.0, -100.0, 0.0};

    // Set NAN test value
    b[n - 1] = numeric_limits<double>::quiet_NaN();

    cout << "\nResults for CompareVCOMISD\n";
    cout << g_Dashes << '\n';

    for (size_t i = 0; i < n; i++)
    {
        bool cmp_results[c_NumOpStrings];

        CompareVCOMISD_(a[i], b[i], cmp_results);
        PrintResults(a[i], b[i], cmp_results);
    }
}

int main()
{
    CompareVCOMISS();
    CompareVCOMISD();
    return 0;
}
