//------------------------------------------------
//               Ch05_05.cpp
//------------------------------------------------

#include <iostream>
#include <iomanip>
#include <limits>
#include <string>

using namespace std;

extern "C" void CompareVCMPSD_(double a, double b, bool* results);

const string g_Dashes(40, '-');

int main()
{
    const char* cmp_names[] =
    {
        "cmp_eq", "cmp_neq", "cmp_lt", "cmp_le",
        "cmp_gt", "cmp_ge", "cmp_ord", "cmp_unord"
    };

    const size_t num_cmp_names = sizeof(cmp_names) / sizeof(char*);

    const size_t n = 6;
    double a[n] = {120.0, 250.0, 300.0, -18.0, -81.0, 42.0};
    double b[n] = {130.0, 240.0, 300.0, 32.0, -100.0, 0.0};

    b[n - 1] = numeric_limits<double>::quiet_NaN();

    cout << "Results for CompareVCMPSD\n";
    cout << g_Dashes << '\n';

    for (size_t i = 0; i < n; i++)
    {
        bool cmp_results[num_cmp_names];

        CompareVCMPSD_(a[i], b[i], cmp_results);

        cout << "a = " << a[i] << "   ";
        cout << "b = " << b[i] << '\n';

        for (size_t j = 0; j < num_cmp_names; j++)
        {
            string s1 = cmp_names[j] + string(":");
            string s2 = ((j & 1) != 0) ? "\n" : "  ";

            cout << left << setw(12) << s1;
            cout << boolalpha << setw(6) << cmp_results[j] << s2;
        }

        cout << "\n";
    }

    return 0;
}
