#include <cobject.h>

using namespace std;

int main()
{
    cobject* c = new cobject();
    c->~cobject();
    return 0;
}
