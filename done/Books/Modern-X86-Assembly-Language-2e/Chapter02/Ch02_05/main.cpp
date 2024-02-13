//------------------------------------------------
//               Ch02_05.cpp
//------------------------------------------------

#include <iostream>
#include <cstdint>

using namespace std;

extern "C" int64_t IntegerMul_(int8_t a, int16_t b, int32_t c, int64_t d, int8_t e, int16_t f, int32_t g, int64_t h);
extern "C" int UnsignedIntegerDiv_(uint8_t a, uint16_t b, uint32_t c, uint64_t d, uint8_t e, uint16_t f, uint32_t g, uint64_t h, uint64_t* quo, uint64_t* rem);

void IntegerMul(void)
{
    int8_t a = 2;
    int16_t b = -3;
    int32_t c = 8;
    int64_t d = 4;
    int8_t e = 3;
    int16_t f = -7;
    int32_t g = -5;
    int64_t h = 10;

    // Calculate a * b * c * d * e * f * g * h
    int64_t prod1 = a * b * c * d * e * f * g * h;
    int64_t prod2 = IntegerMul_(a, b, c, d, e, f, g, h);

    cout << "\nResults for IntegerMul\n";
    cout << "a = " << (int)a << ", b = " << b << ", c = " << c << ' ';
    cout << "d = " << d << ", e = " << (int)e << ", f = " << f << ' ';
    cout << "g = " << g << ", h = " << h << '\n';
    cout << "prod1 = " << prod1 << '\n';
    cout << "prod2 = " << prod2 << '\n';
}

void UnsignedIntegerDiv(void)
{
    uint8_t a = 12;
    uint16_t b = 17;
    uint32_t c = 71000000;
    uint64_t d = 90000000000;
    uint8_t e = 101;
    uint16_t f = 37;
    uint32_t g = 25;
    uint64_t h = 5;
    uint64_t quo1, rem1;
    uint64_t quo2, rem2;

    quo1 = (a + b + c + d) / (e + f + g + h);
    rem1 = (a + b + c + d) % (e + f + g + h);
    UnsignedIntegerDiv_(a, b, c, d, e, f, g, h, &quo2, &rem2);

    cout << "\nResults for UnsignedIntegerDiv\n";
    cout << "a = " << (unsigned)a << ", b = " << b << ", c = " << c << ' ';
    cout << "d = " << d << ", e = " << (unsigned)e << ", f = " << f << ' ';
    cout << "g = " << g << ", h = " << h << '\n';
    cout << "quo1 = " << quo1 << ", rem1 = " << rem1 << '\n';
    cout << "quo2 = " << quo2 << ", rem2 = " << rem2 << '\n';
}

int main()
{
    IntegerMul();
    UnsignedIntegerDiv();
    return 0;
}
