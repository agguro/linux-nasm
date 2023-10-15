#include <stdio.h>

extern "C" int CalcArraySquares(int* y, const int* x, int n);

int CalcArraySquaresCpp(int* y, const int* x, int n)
{
	int sum = 0;
	
	for (int i = 0; i < n; i++)
	{
		y[i] =  x[i] * x[i];
		sum += y[i];
	}
	
	return sum;
}

int main(int argc, char* argv[])
{
	int x[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29};
	const int n = sizeof(x) / sizeof(int);
	int y1[n];
	int y2[n];
	int sum_y1 = CalcArraySquaresCpp(y1, x, n);
	int sum_y2 = CalcArraySquares(y2, x, n);
	
	for (int i = 0; i < n; i++)
		printf("i: %2d  x: %4d  y1: %4d  y2: %4d\n", i, x[i], y1[i], y2[i]);
	printf("\n");
	
	printf("sum_y1: %d\n", sum_y1);
	printf("sum_y2: %d\n", sum_y2);
	
	return 0;
}
