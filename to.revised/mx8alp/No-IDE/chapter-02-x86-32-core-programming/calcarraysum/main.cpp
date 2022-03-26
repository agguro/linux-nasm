#include <stdio.h>

extern "C" int CalcArraySum(const int* x, int n);

int CalcArraySumCpp(const int* x, int n)
{
	int sum = 0;
	
	for (int i = 0; i < n; i++)
		sum += *x++;
	
	return sum;
}

int main(int argc, char* argv[])
{
	int x[] = {1, 7, -3, 5, 2, 9, -6, 12};
	int n = sizeof(x) / sizeof(int);
	
	printf("Elements of x[]\n");
	for (int i = 0; i < n; i++)
		printf("%d ", x[i]);
	printf("\n\n");
	
	int sum1 = CalcArraySumCpp(x, n);
	int sum2 = CalcArraySum(x, n);
	
	printf("sum1: %d\n", sum1);
	printf("sum2: %d\n", sum2);
	return 0;
}
