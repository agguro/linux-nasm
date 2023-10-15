#include <cobject.h>
#include <iostream>

using namespace std;

int main()
{
    cobject* c = new cobject();
    c->~cobject();
    return 0;
}
