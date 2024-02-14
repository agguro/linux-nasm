//------------------------------------------------
//               Ch05_12.cpp
//------------------------------------------------

#include <iostream>
#include <iomanip>
#include <cmath>

using namespace std;

extern "C" bool Cc4_(const double* ht, const double* wt, int n, double* bsa1, double* bsa2, double* bsa3);

int main()
{
    const int n = 6;
    const double ht[n] = { 150, 160, 170, 180, 190, 200 };
    const double wt[n] = { 50.0, 60.0, 70.0, 80.0, 90.0, 100.0 };
    double bsa1_a[n], bsa1_b[n];
    double bsa2_a[n], bsa2_b[n];
    double bsa3_a[n], bsa3_b[n];

    for (int i = 0; i < n; i++)
    {
        bsa1_a[i] = 0.007184 * pow(ht[i], 0.725) * pow(wt[i], 0.425);
        bsa2_a[i] = 0.0235 * pow(ht[i], 0.42246) * pow(wt[i], 0.51456);
        bsa3_a[i] = sqrt(ht[i] * wt[i] / 3600.0);
    }

    Cc4_(ht, wt, n, bsa1_b, bsa2_b, bsa3_b);

    cout << "Results for Cc4\n\n";
    cout << fixed;

    const char sp = ' ';

    for (int i = 0; i < n; i++)
    {
        cout << setprecision(1);
        cout << "height: " << setw(6) << ht[i] << " cm\n";
        cout << "weight: " << setw(6) << wt[i] << " kg\n";

        cout << setprecision(6);

        cout << "BSA (C++):    ";
        cout << setw(10) << bsa1_a[i]  << sp;
        cout << setw(10) << bsa2_a[i]  << sp;
        cout << setw(10) << bsa3_a[i]  << " (sq. m)\n";

        cout << "BSA (X86-64): ";
        cout << setw(10) << bsa1_b[i]  << sp;
        cout << setw(10) << bsa2_b[i]  << sp;
        cout << setw(10) << bsa3_b[i]  << " (sq. m)\n\n";
    }
    return 0;
}
