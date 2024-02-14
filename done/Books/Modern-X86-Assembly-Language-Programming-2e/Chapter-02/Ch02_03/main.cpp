//------------------------------------------------
//               Ch02_03.cpp
//------------------------------------------------

#include <iostream>
#include <iomanip>
#include <bitset>

using namespace std;

extern "C" int IntegerShift_(unsigned int a, unsigned int count, unsigned int* a_shl, unsigned int* a_shr);

static void PrintResult(const char* s, int rc, unsigned int a, unsigned int count, unsigned int a_shl, unsigned int a_shr)
{
    bitset<32> a_bs(a);
    bitset<32> a_shl_bs(a_shl);
    bitset<32> a_shr_bs(a_shr);
    const int w = 10;
    const char nl = '\n';

    cout << s << '\n';
    cout << "count =" << setw(w) << count << nl;
    cout << "a =    " << setw(w) << a << " (0b" << a_bs << ")" << nl;

    if (rc == 0)
        cout << "Invalid shift count" << nl;
    else
    {
        cout << "shl =  " << setw(w) << a_shl << " (0b" << a_shl_bs << ")" << nl;
        cout << "shr =  " << setw(w) << a_shr << " (0b" << a_shr_bs << ")" << nl;
    }

    cout << nl;
}

int main()
{
    int rc;
    unsigned int a, count, a_shl, a_shr;

    a = 3119;
    count = 6;
    rc = IntegerShift_(a, count, &a_shl, &a_shr);
    PrintResult("Test 1", rc, a, count, a_shl, a_shr);

    a = 0x00800080;
    count = 4;
    rc = IntegerShift_(a, count, &a_shl, &a_shr);
    PrintResult("Test 2", rc, a, count, a_shl, a_shr);

    a = 0x80000001;
    count = 31;
    rc = IntegerShift_(a, count, &a_shl, &a_shr);
    PrintResult("Test 3", rc, a, count, a_shl, a_shr);

    a = 0x55555555;
    count = 32;
    rc = IntegerShift_(a, count, &a_shl, &a_shr);
    PrintResult("Test 4", rc, a, count, a_shl, a_shr);

    return 0;
}
