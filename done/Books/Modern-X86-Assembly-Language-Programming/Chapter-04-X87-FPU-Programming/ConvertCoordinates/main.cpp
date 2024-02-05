#include <stdio.h>

extern "C" void RectToPolar(double x, double y, double* r, double* a);
extern "C" void PolarToRect(double r, double a, double* x, double* y);

int main(int argc, char* argv[])
{
    double x1[] = { 0, 3, -3, 4, -4 };
    double y1[] = { 0, 3, -3, 4, -4 };
    const int nx = sizeof(x1) / sizeof(double);
    const int ny = sizeof(y1) / sizeof(double);
	// to improve readability for myself I've added this line and degree symbol
	printf("[i, j]       x[i]      y[i]        r           a          x2         y2\n");
    for (int i = 0; i < ny; i++)
    {
        for (int j = 0; j < nx; j++)
        {
            double r, a, x2, y2;
            RectToPolar(x1[i], y1[j], &r, &a);
            PolarToRect(r, a, &x2, &y2);
            printf("[%d, %d]: ", i, j);
            printf("(%8.4lf, %8.4lf) ", x1[i], y1[j]);
            printf("(%8.4lf, %10.4lf°) ", r, a);			// added degree symbol
            printf("(%8.4lf, %8.4lf)\n", x2, y2);
        }
    }
    return 0;
}
