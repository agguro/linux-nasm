//------------------------------------------------
//               Ch03_09.cpp
//------------------------------------------------

#include <iostream>
#include <iomanip>
#include <random>

using namespace std;

extern "C" int ReverseArray_(int* y, const int* x, int n);

void Init(int* x, int n)
{
    unsigned int seed = 17;
    uniform_int_distribution<> d {1, 1000};
    default_random_engine rng {seed};

    for (int i = 0; i < n; i++)
        x[i] = d(rng);
}

int main()
{
    const int n = 25;
    int x[n], y[n];

    Init(x, n);
    int rc = ReverseArray_(y, x, n);

    if (rc != 0)
    {
        cout << "\nResults for ReverseArray\n";

        const int w = 5;
        bool compare_error = false;

        for (int i = 0; i < n && !compare_error; i++)
        {
            cout << "  i: " << setw(w) << i;
            cout << "  y: " << setw(w) << y[i];
            cout << "  x: " << setw(w) << x[i] << '\n';

            if (x[i] != y[n - 1 - i])
                compare_error = true;
        }

        if (compare_error)
            cout << "ReverseArray compare error\n";
        else
            cout << "ReverseArray compare OK\n";
    }
    else
        cout << "ReverseArray_() failed\n";

    return 0;
}
