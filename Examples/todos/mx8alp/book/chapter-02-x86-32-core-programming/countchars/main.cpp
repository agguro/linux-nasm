#include <stdio.h>
#include <stdint.h>
#include <wchar.h>

extern "C" int CountChars(wchar_t* s, wchar_t c);

int main(int argc, char* argv[])
{
	wchar_t c;
	wchar_t* s;
	
	s = (wchar_t*)(L"Four score and seven seconds ago, ...");
	wprintf(L"\nTest string: %ls\n", s);
	c = L's';
	wprintf(L"  SearchChar: %c Count: %d\n", c, CountChars(s, c));
	c = L'F';
	wprintf(L"  SearchChar: %c Count: %d\n", c, CountChars(s, c));
	c = L'o';
	wprintf(L"  SearchChar: %c Count: %d\n", c, CountChars(s, c));
	c = L'z';
	wprintf(L"  SearchChar: %c Count: %d\n", c, CountChars(s, c));
	
	s = (wchar_t*)(L"Red Green Blue Cyan Magenta Yellow");
	wprintf(L"\nTest string: %ls\n", s);
	c = L'e';
	wprintf(L"  SearchChar: %c Count: %d\n", c, CountChars(s, c));
	c = L'w';
	wprintf(L"  SearchChar: %c Count: %d\n", c, CountChars(s, c));
	c = L'Q';
	wprintf(L"  SearchChar: %c Count: %d\n", c, CountChars(s, c));
	c = L'l';
	wprintf(L"  SearchChar: %c Count: %d\n", c, CountChars(s, c));
	
	return 0;
}
