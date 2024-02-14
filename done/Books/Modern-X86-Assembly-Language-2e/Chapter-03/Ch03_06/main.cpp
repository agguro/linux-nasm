//------------------------------------------------
//               Ch03_06.cpp
//------------------------------------------------

#include <iostream>

using namespace std;

extern "C" unsigned long long CountChars_(const char* s, char c);

int main()
{
    const char nl = '\n';
    const char* s0 = "Test string: ";
    const char* s1 = "  SearchChar: ";
    const char* s2 = " Count: ";

    char c;
    const char* s;

    s = "Four score and seven seconds ago, ...";
    cout << nl << s0 << s << nl;

    c = 's';
    cout << s1 << c << s2 << CountChars_(s, c) << nl;
    c = 'o';
    cout << s1 << c << s2 << CountChars_(s, c) << nl;
    c = 'z';
    cout << s1 << c << s2 << CountChars_(s, c) << nl;
    c = 'F';
    cout << s1 << c << s2 << CountChars_(s, c) << nl;
    c = '.';
    cout << s1 << c << s2 << CountChars_(s, c) << nl;

    s = "Red Green Blue Cyan Magenta Yellow";
    cout << nl << s0 << s << nl;

    c = 'e';
    cout << s1 << c << s2 << CountChars_(s, c) << nl;
    c = 'w';
    cout << s1 << c << s2 << CountChars_(s, c) << nl;
    c = 'l';
    cout << s1 << c << s2 << CountChars_(s, c) << nl;
    c = 'Q';
    cout << s1 << c << s2 << CountChars_(s, c) << nl;
    c = 'n';
    cout << s1 << c << s2 << CountChars_(s, c) << nl;

    return 0;
}
