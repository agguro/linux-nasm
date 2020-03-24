#include <stdio.h>
#define _USE_MATH_DEFINES
#include <math.h>
#include <stddef.h>

// Uncomment line below to enable display of PDATA information
#define DISPLAY_PDATA_INFO

// This structure must agree with the structure that's defined
// in file SseScalarFloatingPointParallelograms_.asm.
typedef struct
{
    double A;               // Length of left and right
    double B;               // Length of top and bottom
    double Alpha;           // Angle alpha in degrees
    double Beta;            // Angle beta in degrees
    double H;               // Height of parallelogram
    double Area;            // Parallelogram area
    double P;               // Length of diagonal P
    double Q;               // Length of diagonal Q
    bool BadValue;          // Set to true if A, B, or Alpha is invalid
    char Pad[7];            // Reserved for future use
} PDATA;

extern "C" bool SseSfpParallelograms_(PDATA* pdata, int n);
extern "C" const double DegToRad = M_PI / 180.0;
extern "C" const int SizeofPdataX86 = sizeof (PDATA);
//const bool PrintPdataInfo = true;

void SetPdata(PDATA* pdata, double a, double b, double alpha)
{
    pdata->A = a;
    pdata->B = b;
    pdata->Alpha = alpha;
}

int main()
{

#ifdef DISPLAY_PDATA_INFO
    size_t spd1 = sizeof(PDATA);
    size_t spd2 = SizeofPdataX86;

    if (spd1 != spd2)
        printf("PDATA size discrepancy [%d, %d]", static_cast<int>(spd1), static_cast<int>(spd2));
    else
    {    
        printf("sizeof(PDATA):      %4d\n", static_cast<int>(spd1));
        printf("Offset of A:        %4d\n", (int)offsetof(PDATA,A));
        printf("Offset of B:        %4d\n", (int)offsetof(PDATA, B));
        printf("Offset of Alpha:    %4d\n", (int)offsetof(PDATA, Alpha));
        printf("Offset of Beta:     %4d\n", (int)offsetof(PDATA, Beta));
        printf("Offset of H         %4d\n", (int)offsetof(PDATA, H));
        printf("Offset of Area:     %4d\n", (int)offsetof(PDATA, Area));
        printf("Offset of P:        %4d\n", (int)offsetof(PDATA, P));
        printf("Offset of Q:        %4d\n", (int)offsetof(PDATA, Q));
        printf("Offset of BadValue  %4d\n", (int)offsetof(PDATA, BadValue));
        printf("Offset of Pad       %4d\n", (int)offsetof(PDATA, Pad));
    }
#endif

    const int n = 10;
    PDATA pdata[n];

    // Create some test parallelograms
    SetPdata(&pdata[0], -1.0, 1.0, 60.0);
    SetPdata(&pdata[1], 1.0, -1.0, 60.0);
    SetPdata(&pdata[2], 1.0, 1.0, 181.0);
    SetPdata(&pdata[3], 1.0, 1.0, 90.0);
    SetPdata(&pdata[4], 3.0, 4.0, 90.0);
    SetPdata(&pdata[5], 2.0, 3.0, 30.0);
    SetPdata(&pdata[6], 3.0, 2.0, 60.0);
    SetPdata(&pdata[7], 4.0, 2.5, 120.0);
    SetPdata(&pdata[8], 5.0, 7.125, 135.0);
    SetPdata(&pdata[9], 8.0, 8.0, 165.0);

    SseSfpParallelograms_(pdata, n);

    for (int i = 0; i < n; i++)
    {
        PDATA* p = &pdata[i];
        printf("\npdata[%d] - BadValue = %d\n", i, p->BadValue);
        printf("  A:      %12.6lf  B:    %12.6lf\n", p->A, p->B);
        printf("  Alpha:  %12.6lf  Beta: %12.6lf\n", p->Alpha, p->Beta);
        printf("  H:      %12.6lf  Area: %12.6lf\n", p->H, p->Area);
        printf("  P:      %12.6lf  Q:    %12.6lf\n", p->P, p->Q);
    }
    return 0;
}
