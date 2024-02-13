//------------------------------------------------
//               Ch02_06.cpp
//------------------------------------------------

#include <iostream>
#include <iomanip>

using namespace std;

extern "C" int NumFibVals_, FibValsSum_;
extern "C" int MemoryAddressing_(int i, int* v1, int* v2, int* v3, int* v4);

int main()
{
    const int w = 5;
    const char nl = '\n';
    const char* delim = ", ";

    FibValsSum_ = 0;

    for (int i = -1; i < NumFibVals_ + 1; i++)
    {
        int v1 = -1, v2 = -1, v3 = -1, v4 = -1;
        int rc = MemoryAddressing_(i, &v1, &v2, &v3, &v4);

        cout << "i = " << setw(w - 1) << i << delim;
        cout << "rc = " << setw(w - 1) << rc << delim;
        cout << "v1 = " << setw(w) << v1 << delim;
        cout << "v2 = " << setw(w) << v2 << delim;
        cout << "v3 = " << setw(w) << v3 << delim;
        cout << "v4 = " << setw(w) << v4 << nl;         //neater when no delim at end of line
//        cout << nl;
//        cout << flush;
    }

    cout << "FibValsSum_ = " << FibValsSum_ << nl;
    return 0;
}
