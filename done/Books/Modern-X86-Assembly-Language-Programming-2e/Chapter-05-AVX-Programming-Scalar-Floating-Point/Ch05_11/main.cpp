//------------------------------------------------
//               Ch05_11.cpp
//------------------------------------------------

#include <iostream>
#include <iomanip>
#define _USE_MATH_DEFINES
#include <math.h>

using namespace std;

extern "C" bool Cc3_(const double* r, const double* h, int n, double* sa_cone, double* vol_cone);

int main()
{
    const int n = 7;
    double r[n] = { 1, 1, 2, 2, 3, 3, 4.25 };
    double h[n] = { 1, 2, 3, 4, 5, 10, 12.5 };

    double sa_cone1[n], sa_cone2[n];
    double vol_cone1[n], vol_cone2[n];

    // Calculate surface area and volume of right-circular cones
    for (int i = 0; i < n; i++)
    {
        sa_cone1[i] = M_PI * r[i] * (r[i] + sqrt(r[i] * r[i] + h[i] * h[i]));
        vol_cone1[i] = M_PI * r[i] * r[i] * h[i] / 3.0;
    }

    Cc3_(r, h, n, sa_cone2, vol_cone2);

    cout << fixed;
    cout << "Results for Cc3\n\n";

    const int w = 14;
    const char nl = '\n';
    const char sp = ' ';

    for (int i = 0; i < n; i++)
    {
        cout << setprecision(2);
        cout << "r/h: " << setw(w) << r[i] << sp;
        cout << setw(w) << h[i] << nl;

        cout << setprecision(6);
        cout << "sa:  " << setw(w) << sa_cone1[i] << sp;
        cout << setw(w) << sa_cone2[i] << nl;
        cout << "vol: " << setw(w) << vol_cone1[i] << sp;
        cout << setw(w) << vol_cone2[i] << nl;
        cout << nl;
    }

    return 0;
}
