#include <stdio.h>
#include <inttypes.h>
#include "../../../CommonFiles/miscdefs.h"

extern "C" Int64 IntegerAdd_(Int64 a, Int64 b, Int64 c, Int64 d, Int64 e, Int64 f);
extern "C" Int64 IntegerMul_(Int8 a, Int16 b, Int32 c, Int64 d, Int8 e, Int16 f, Int32 g, Int64 h);
extern "C" void IntegerDiv_(Int64 a, Int64 b, Int64 quo_rem_ab[2], Int64 c, Int64 d, Int64 quo_rem_cd[2]);

void IntegerAdd(void)
{
    Int64 a = 100;
    Int64 b = 200;
    Int64 c = -300;
    Int64 d = 400;
    Int64 e = -500;
    Int64 f = 600;

    // Calculate a + b + c + d + e + f
    Int64 sum = IntegerAdd_(a, b, c, d, e, f);

    printf("\nResults for IntegerAdd\n");
    printf("a: %" PRId64 " b: %" PRId64 " c: %" PRId64 "\n", a, b, c);
    printf("d: %" PRId64 " e: %" PRId64 " f: %" PRId64 "\n", d, e, f);
    printf("sum: %" PRId64 "\n", sum);
}

void IntegerMul(void)
{
    Int8 a = 2;
    Int16 b = -3;
    Int32 c = 8;
    Int64 d = 4;
    Int8 e = 3;
    Int16 f = -7;
    Int32 g = -5;
    Int64 h = 10;

    // Calculate a * b * c * d * e * f * g * h
    Int64 result = IntegerMul_(a, b, c, d, e, f, g, h);

    printf("\nResults for IntegerMul\n");  
    printf("a: %" PRId8 " b: %" PRId16 " c: %" PRId32 " d: %" PRId64 "\n", a, b, c, d);
    printf("a: %" PRId8 " b: %" PRId16 " c: %" PRId32 " d: %" PRId64 "\n", e, f, g, h);
    printf("result: %" PRId64 "\n", result);
}

void IntegerDiv(void)
{
    Int64 a = 102;
    Int64 b = 7;
    Int64 quo_rem_ab[2];
    Int64 c = 61;
    Int64 d = 9;
    Int64 quo_rem_cd[2];

    // Calculate a / b  and c / d
    IntegerDiv_(a, b, quo_rem_ab, c, d, quo_rem_cd);

    printf("\nResults for IntegerDiv\n");
    printf("a:   %" PRId64 " b:   %" PRId64 " ", a, b);
    printf("quo: %" PRId64 " rem: %" PRId64 "\n", quo_rem_ab[0], quo_rem_ab[1]);
    printf("c:   %" PRId64 " d:   %" PRId64 " ", c, d);
    printf("quo: %" PRId64 " rem: %" PRId64 "\n", quo_rem_cd[0], quo_rem_cd[1]);
}

int main(void)
{
    IntegerAdd();
    IntegerMul();
    IntegerDiv();
    return 0;
}
