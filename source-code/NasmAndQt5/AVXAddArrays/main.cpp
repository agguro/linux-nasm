/*
 *  AVXAddArrays
 * Source https://www.physicsforums.com/insights/an-intro-to-avx-512-assembly-programming/
 *        downgraded to AVX
*/

#include <iostream>

using std::cout;
using std::endl;
// Prototypes
extern "C" void AddArray(float Dest[], float Arr1[], float Arr2[]);
void PrintArray(float[], int count);

// Data is aligned to 64-byte boundaries
float Array1[] __attribute__((aligned(32))) = // First source array
{
 1, 2, 3, 4, 5, 6, 7, 8
};

float Array2[] __attribute__((aligned(32))) = // Second source array
{
 1, 2, 3, 4, 5, 6, 7, 8
};

float Dest[8] __attribute__((aligned(32))); // Destination arrayµ

int main() {
	
	AddArray(Dest, Array1, Array2); // Call the assembly routine
	PrintArray(Dest, 8);
}

void PrintArray(float Arr[], int count)
{
	for (int i = 0; i < count; i++)
	{
		cout << Arr[i] << '\t';
	}
	cout << endl;
}

