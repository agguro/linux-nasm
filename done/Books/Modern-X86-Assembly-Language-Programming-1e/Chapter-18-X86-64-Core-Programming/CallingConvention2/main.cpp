#include <stdio.h>
#include <inttypes.h>
#include "../../CommonFiles/miscdefs.h"

extern "C" bool Cc2(const Int64* a, const Int64* b, Int32 n, Int64 * sum_a, Int64* sum_b, Int64* prod_a, Int64* prod_b);

int main(int argc, char* argv[])
{
    const int32_t n = 6;
    Int64 a[n] = { 2, -2, -6, 7, 12, 5 };
    Int64 b[n] = { 3, 5, -7, 8, 4, 9 };
    Int64 sum_a, sum_b;
    Int64 prod_a, prod_b;

    printf("\nResults for CallingConvention2\n");
    
    bool rc = Cc2(a, b, n, &sum_a, &sum_b, &prod_a, &prod_b);

    if (!rc)
        printf("Invalid return code from Cc2()\n");
    else
    {
        printf("               a                b\n");
        for (int i = 0; i < n; i++)
            printf("        %8" PRId64 "         %8" PRId64 "\n", a[i], b[i]);

        printf("\n");
        printf("sum_a:  %8" PRId64 " sum_b:  %8" PRId64 "\n", sum_a, sum_b);
        printf("prod_a: %8" PRId64 " prod_b: %8" PRId64 "\n", prod_a, prod_b);
    }

    return 0;
}
