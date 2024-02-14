//------------------------------------------------
//               Ch02_07.cpp
//------------------------------------------------

#include <iostream>
#include <iomanip>

using namespace std;

extern "C" int SignedMinA_(int a, int b, int c);
extern "C" int SignedMaxA_(int a, int b, int c);
extern "C" int SignedMinB_(int a, int b, int c);
extern "C" int SignedMaxB_(int a, int b, int c);

void PrintResult(const char* s1, int a, int b, int c, int result)
{
    const int w = 4;

    cout << s1 << "(";
    cout << setw(w) << a << ", ";
    cout << setw(w) << b << ", ";
    cout << setw(w) << c << ") = ";
    cout << setw(w) << result << '\n';
}

int main()
{
    int a, b, c;
    int smin_a, smax_a, smin_b, smax_b;

    // SignedMin examples
    a = 2; b = 15; c = 8;
    smin_a = SignedMinA_(a, b, c);
    smin_b = SignedMinB_(a, b, c);
    PrintResult("SignedMinA", a, b, c, smin_a);
    PrintResult("SignedMinB", a, b, c, smin_b);
    cout << '\n';

    a = -3; b = -22; c = 28;
    smin_a = SignedMinA_(a, b, c);
    smin_b = SignedMinB_(a, b, c);
    PrintResult("SignedMinA", a, b, c, smin_a);
    PrintResult("SignedMinB", a, b, c, smin_b);
    cout << '\n';

    a = 17; b = 37; c = -11;
    smin_a = SignedMinA_(a, b, c);
    smin_b = SignedMinB_(a, b, c);
    PrintResult("SignedMinA", a, b, c, smin_a);
    PrintResult("SignedMinB", a, b, c, smin_b);
    cout << '\n';

    // SignedMax examples
    a = 10; b = 5; c = 3;
    smax_a = SignedMaxA_(a, b, c);
    smax_b = SignedMaxB_(a, b, c);
    PrintResult("SignedMaxA", a, b, c, smax_a);
    PrintResult("SignedMaxB", a, b, c, smax_b);
    cout << '\n';

    a = -3; b = 28; c = 15;
    smax_a = SignedMaxA_(a, b, c);
    smax_b = SignedMaxB_(a, b, c);
    PrintResult("SignedMaxA", a, b, c, smax_a);
    PrintResult("SignedMaxB", a, b, c, smax_b);
    cout << '\n';

    a = -25; b = -37; c = -17;
    smax_a = SignedMaxA_(a, b, c);
    smax_b = SignedMaxB_(a, b, c);
    PrintResult("SignedMaxA", a, b, c, smax_a);
    PrintResult("SignedMaxB", a, b, c, smax_b);
    cout << '\n';
}
