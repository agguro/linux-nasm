//------------------------------------------------
//               Ch03_04.cpp
//------------------------------------------------

#include <iostream>
#include <iomanip>
#include <random>

using namespace std;

extern "C" int CalcMatrixRowColSums_(int* row_sums, int* col_sums, const int* x, int nrows, int ncols);

void Init(int* x, int nrows, int ncols)
{
    unsigned int seed = 13;
    uniform_int_distribution<> d {1, 200};
    default_random_engine rng {seed};

    for (int i = 0; i < nrows * ncols; i++)
        x[i] = d(rng);
}

void PrintResult(const char* msg, const int* row_sums, const int* col_sums, const int* x, int nrows, int ncols)
{
    const int w = 6;
    const char nl = '\n';

    cout << msg;
    cout << "-----------------------------------------\n";

    for (int i = 0; i < nrows; i++)
    {
        for (int j = 0; j < ncols; j++)
            cout << setw(w) << x[i* ncols + j];
        cout << "  " << setw(w) << row_sums[i] << nl;
    }

    cout << nl;

    for (int i = 0; i < ncols; i++)
        cout << setw(w) << col_sums[i];
    cout << nl;
}

int CalcMatrixRowColSumsCpp(int* row_sums, int* col_sums, const int* x, int nrows, int ncols)
{
    int rc = 0;

    if (nrows > 0 && ncols > 0)
    {
        for (int j = 0; j < ncols; j++)
            col_sums[j] = 0;

        for (int i = 0; i < nrows; i++)
        {
            row_sums[i] = 0;
            int k = i * ncols;

            for (int j = 0; j < ncols; j++)
            {
                int temp = x[k + j];
                row_sums[i] += temp;
                col_sums[j] += temp;
            }
        }

        rc = 1;
    }

    return rc;
}

int main()
{
    const int nrows = 7;
    const int ncols = 5;
    int x[nrows][ncols];

    Init((int*)x, nrows, ncols);

    int row_sums1[nrows], col_sums1[ncols];
    int row_sums2[nrows], col_sums2[ncols];

    const char* msg1 = "\nResults using CalcMatrixRowColSumsCpp\n";
    const char* msg2 = "\nResults using CalcMatrixRowColSums_\n";

    int rc1 = CalcMatrixRowColSumsCpp(row_sums1, col_sums1, (int*)x, nrows, ncols);
    int rc2 = CalcMatrixRowColSums_(row_sums2, col_sums2, (int*)x, nrows, ncols);

    if (rc1 == 0)
        cout << "CalcMatrixRowSumsCpp failed\n";
    else
        PrintResult(msg1, row_sums1, col_sums1, (int*)x, nrows, ncols);

    if (rc2 == 0)
        cout << "CalcMatrixRowSums_ failed\n";
    else
        PrintResult(msg2, row_sums2, col_sums2, (int*)x, nrows, ncols);

    return 0;
}
