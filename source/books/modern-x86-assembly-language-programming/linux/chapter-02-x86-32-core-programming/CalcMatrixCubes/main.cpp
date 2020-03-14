#include <stdio.h>

extern "C" int CalcMatrixCubes_(int* y, const int* x, int nrows, int ncols);

void CalcMatrixCubes(int* y, const int* x, int nrows, int ncols)
{
	for (int i = 0; i < nrows; i++)
	{
		for (int j = 0; j < ncols; j++)
		{
			int k = i * ncols + j;
			y[k] = x[k] * x[k] * x[k];
		}
	}
}

int main()
{
	const int nrows = 4;
	const int ncols = 3;
	int x[nrows][ncols] = { { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 }, { 10, 11, 12 } };
	int y1[nrows][ncols];
	int y2[nrows][ncols];
	
	CalcMatrixCubes(&y1[0][0], &x[0][0], nrows, ncols);
	CalcMatrixCubes_(&y2[0][0], &x[0][0], nrows, ncols);
	
	for (int i = 0; i < nrows; i++)
	{
		for (int j = 0; j < ncols; j++)
			printf("(%2d, %2d): %6d, %6d, %6d\n", i, j, x[i][j], y1[i][j], y2[i][j]);
	}
	
	return 0;
}
