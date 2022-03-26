#include <stdio.h>
#include <limits>

using namespace std;

extern "C" void SseSfpCompareFloat(float a, float b, bool* results);
extern "C" void SseSfpCompareDouble(double a, double b, bool* results);

const int m = 7;
const char* OpStrings[m] = {"UO", "LT", "LE", "EQ", "NE", "GT", "GE"};

void SseSfpCompareFloat()
{
    const int n = 4;
    float a[n] = {120.0, 250.0, 300.0, 42.0};
    float b[n] = {130.0, 240.0, 300.0, 0.0};

    // Set NAN test value
    b[n - 1] = numeric_limits<float>::quiet_NaN();

    printf("Results for SseSfpCompareFloat()\n");
    for (int i = 0; i < n; i++)
    {
        bool results[m];

        SseSfpCompareFloat(a[i], b[i], results);
        printf("a: %8f b: %8f\n", a[i], b[i]);

        for (int j = 0; j < m; j++)
            printf("  %s=%d", OpStrings[j], results[j]);
        printf("\n");
    }
}

void SseSfpCompareDouble(void)
{
    const int n = 4;
    double a[n] = {120.0, 250.0, 300.0, 42.0};
    double b[n] = {130.0, 240.0, 300.0, 0.0};

    // Set NAN test value
    b[n - 1] = numeric_limits<double>::quiet_NaN();

    printf("\nResults for SseSfpCompareDouble()\n");
    for (int i = 0; i < n; i++)
    {
        bool results[m];

        SseSfpCompareDouble(a[i], b[i], results);
        printf("a: %8lf b: %8lf\n", a[i], b[i]);

        for (int j = 0; j < m; j++)
            printf("  %s=%d", OpStrings[j], results[j]);
        printf("\n");
    }
}

int main(int argc, char* argv[])
{
    SseSfpCompareFloat();
    SseSfpCompareDouble();
    return 0;
}
