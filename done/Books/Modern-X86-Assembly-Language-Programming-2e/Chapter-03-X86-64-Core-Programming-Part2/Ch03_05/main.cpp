//------------------------------------------------
//               Ch03_05.cpp
//------------------------------------------------

#include <iostream>
#include <iomanip>
#include <cstdint>

using namespace std;

struct TestStruct
{
    int8_t  Val8;
    int8_t  Pad8;
    int16_t Val16;
    int32_t Val32;
    int64_t Val64;
};

extern "C" int64_t CalcTestStructSum_(const TestStruct* ts);

int64_t CalcTestStructSumCpp(const TestStruct* ts)
{
    return ts->Val8 + ts->Val16 + ts->Val32 + ts->Val64;
}

int main()
{
    TestStruct ts;

    ts.Val8 = -100;
    ts.Val16 = 2000;
    ts.Val32 = -300000;
    ts.Val64 = 40000000000;

    int64_t sum1 = CalcTestStructSumCpp(&ts);
    int64_t sum2 = CalcTestStructSum_(&ts);

    cout << "ts1.Val8 =  " << (int)ts.Val8 << '\n';
    cout << "ts1.Val16 = " << ts.Val16 << '\n';
    cout << "ts1.Val32 = " << ts.Val32 << '\n';
    cout << "ts1.Val16 = " << ts.Val64 << '\n';
    cout << '\n';
    cout << "sum1 = " << sum1 << '\n';
    cout << "sum2 = " << sum2 << '\n';

    return 0;
}
