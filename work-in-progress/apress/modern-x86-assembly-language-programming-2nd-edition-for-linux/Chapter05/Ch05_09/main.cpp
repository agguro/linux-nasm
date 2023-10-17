//------------------------------------------------
//               Ch05_09.cpp
//------------------------------------------------

#include <iostream>
#include <cstdint>

using namespace std;

extern "C" int64_t Cc1_(int8_t a, int16_t b, int32_t c, int64_t d, int8_t e, int16_t f, int32_t g, int64_t h);

int main()
{
    int8_t a = 10, e = -20;
    int16_t b = -200, f = 400;
    int32_t c = 300, g = -600;
    int64_t d = 4000, h = -8000;

    int64_t sum = Cc1_(a, b, c, d, e, f, g, h);

    const char nl = '\n';

    cout << "Results for Cc1\n\n";

    cout << "a = " << (int)a << nl;
    cout << "b = " << b << nl;
    cout << "c = " << c << nl;
    cout << "d = " << d << nl;
    cout << "e = " << (int)e << nl;
    cout << "f = " << f << nl;
    cout << "g = " << g << nl;
    cout << "h = " << h << nl;
    cout << "sum = " << sum << nl;

    return 0;
}
