//------------------------------------------------
//               Ch03_03.cpp
//------------------------------------------------

#include <iostream>
#include <iomanip>

using namespace std;

extern "C" void CalcMatrixSquares_(int* y, const int* x, int nrows, int ncols);

void CalcMatrixSquaresCpp(int* y, const int* x, int nrows, int ncols)
{
    for (int i = 0; i < nrows; i++)
    {
        for (int j = 0; j < ncols; j++)
        {
            int kx = j * ncols + i;
            int ky = i * ncols + j;
            y[ky] = x[kx] * x[kx];
        }
    }
}

int main()
{
    const int nrows = 6;
    const int ncols = 3;
    int y2[nrows][ncols];
    int y1[nrows][ncols];
    int x[nrows][ncols] { { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 },
                          { 10, 11, 12 }, {13, 14, 15}, {16, 17, 18} };

    CalcMatrixSquaresCpp(&y1[0][0], &x[0][0], nrows, ncols);
    CalcMatrixSquares_(&y2[0][0], &x[0][0], nrows, ncols);

    for (int i = 0; i < nrows; i++)
    {
        for (int j = 0; j < ncols; j++)
        {
            cout << "y1[" << std::setw(1) << i << "][" << std::setw(1) << j << "] = ";
            cout << std::setw(4) << y1[i][j] << ' ' ;

            cout << "y2[" << std::setw(1) << i << "][" << std::setw(1) << j << "] = ";
            cout << std::setw(4) << y2[i][j] << ' ';

            cout << "x[" << std::setw(1) << j << "][" << std::setw(1) << i << "] = ";
            cout << std::setw(4) << x[j][i] << '\n';

            if (y1[i][j] != y2[i][j])
                cout << "Compare failed\n";
        }
    }

    return 0;
}
