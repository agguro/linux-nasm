#include <stdio.h>
#include <inttypes.h>
#include "../../../CommonFiles/miscdefs.h"

extern "C" Int64 Cc1_(Int8 a, Int16 b, Int32 c, Int64 d, Int8 e, Int16 f, Int32 g, Int64 h);

int main(void)
{
    Int8 a = 10, e = -20;
    Int16 b = -200, f = 400;
    Int32 c = 300, g = -600;
    Int64 d = 4000, h = -8000;
    
    Int64 x = Cc1_(a, b, c, d, e, f, g, h);

    printf("\nResults for CallingConvention1\n");
    printf("a, b, c, d: %8" PRId8 " %8" PRId16 " %8" PRId32 " %8" PRId64 "\n", a, b, c, d);
    printf("e, f, g, h: %8" PRId8 " %8" PRId16 " %8" PRId32 " %8" PRId64 "\n", e, f, g, h);
    printf("  x:           %8" PRId64 "\n", x);
    return 0;
}
