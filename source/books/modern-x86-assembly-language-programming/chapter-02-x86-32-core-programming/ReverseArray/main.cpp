#include <stdio.h>
#include <stdlib.h> //srand function

extern "C" bool ReverseArray_(int* y, const int* x, int n);

int main()
{
	const int n = 21;
	int x[n], y[n];
	
	// Initialize test array
	srand(31);
	for (int i = 0; i < n; i++)
		x[i] = rand() % 1000;
	
	if(ReverseArray_(y, x, n)){
	
		printf("\nResults for ReverseArray\n");
		for (int i = 0; i < n; i++)
		{
			printf("  i: %2d  y: %5d  x: %5d\n", i, y[i], x[i]);
			if (x[i] != y[n - 1 - i])
				printf("  Compare failed!\n");
		}
	}else{
		printf("n cannot be negative\n");
	}
	return 0;
}
