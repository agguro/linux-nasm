#include <stdio.h>

extern "C" double FtoC(double deg_f);
extern "C" double CtoF(double deg_c);

int main(int argc, char* argv[])
{
    double deg_fvals[] = {-459.67, -40.0, 0.0, 32.0, 72.0, 98.6, 212.0};
    int nf = sizeof(deg_fvals) / sizeof(double);

    for (int i = 0; i < nf; i++)
    {
        double deg_c = FtoC(deg_fvals[i]);
        printf("i: %d  f: %10.4lf c: %10.4lf\n", i, deg_fvals[i], deg_c);
    }

    printf("\n");

    double deg_cvals[] = {-273.15, -40.0, -17.77, 0.0, 25.0, 37.0, 100.0};
    int nc = sizeof(deg_cvals) / sizeof(double);

    for (int i = 0; i < nc; i++)
    {
        double deg_f = CtoF(deg_cvals[i]);
        printf("i: %d  c: %10.4lf f: %10.4lf\n", i, deg_cvals[i], deg_f);
    }

    return 0;
}
