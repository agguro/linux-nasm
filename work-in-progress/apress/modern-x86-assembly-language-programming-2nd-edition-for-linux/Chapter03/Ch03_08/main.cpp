//------------------------------------------------
//               Ch03_08.cpp
//------------------------------------------------

#include <iostream>
#include <iomanip>
#include <random>
#include <memory>

using namespace std;

extern "C" long long CompareArrays_(const int* x, const int* y, long long n);

void Init(int* x, int* y, long long n, unsigned int seed)
{
    uniform_int_distribution<> d {1, 10000};
    default_random_engine rng {seed};

    for (long long i = 0; i < n; i++)
        x[i] = y[i] = d(rng);
}

void PrintResult(const char* msg, long long result1, long long result2)
{
    cout << msg << '\n';
    cout << "  expected = " << result1;
    cout << "  actual = " << result2 << "\n\n";
}

int main()
{
    // Allocate and initialize the test arrays
    const long long n = 10000;
    unique_ptr<int[]> x_array {new int[n]};
    unique_ptr<int[]> y_array {new int[n]};
    int* x = x_array.get();
    int* y = y_array.get();

    Init(x, y, n, 11);

    cout << "Results for CompareArrays_ - array_size = " << n << "\n\n";

    long long result;

    // Test using invalid array size
    result = CompareArrays_(x, y, -n);
    PrintResult("Test using invalid array size", -1, result);

    // Test using first element mismatch
    x[0] += 1;
    result = CompareArrays_(x, y, n);
    x[0] -= 1;
    PrintResult("Test using first element mismatch", 0, result);

    // Test using middle element mismatch
    y[n / 2] -= 2;
    result = CompareArrays_(x, y, n);
    y[n / 2] += 2;
    PrintResult("Test using middle element mismatch", n / 2, result);

    // Test using last element mismatch
    x[n - 1] *= 3;
    result = CompareArrays_(x, y, n);
    x[n - 1] /= 3;
    PrintResult("Test using last element mismatch", n - 1, result);

    // Test with identical elements in each array
    result = CompareArrays_(x, y, n);
    PrintResult("Test with identical elements in each array", n, result);
    return 0;
}
