#include "../../CommonFiles/mmxval.h"

// The order of the name constants in the following enum must match
// the table that is defined in mmxAddition.asm.

enum MmxAddOp : unsigned int
{
    paddb,      // packed byte addition with wraparound
    paddsb,     // packed byte addition with signed saturation
    paddusb,    // packed byte addition with unsigned saturation
    paddw,      // packed word addition with wraparound
    paddsw,     // packed word addition with signed saturation
    paddusw,    // packed word addition with unsigned saturation
    paddd       // packed doubleword addition with wrapround
};

extern "C" bool MmxAdd(MmxVal a, MmxVal b, MmxAddOp op, MmxVal *c );

void MmxAddBytes(void)
{
    MmxVal a, b, c;
    char buff [256];
	
    // Packed byte addition - signed integers
    a.i8[0] = 50;   b.i8[0] = 30;
    a.i8[1] = 80;   b.i8[1] = 64;
    a.i8[2] = -27;  b.i8[2] = -32;
    a.i8[3] = -70;  b.i8[3] = -80;

    a.i8[4] = -42;  b.i8[4] = 90;
    a.i8[5] = 60;   b.i8[5] = -85;
    a.i8[6] = 64;   b.i8[6] = 90;
    a.i8[7] = 100;  b.i8[7] = -30;

    printf("\n\nPacked byte addition - signed integers\n");
    printf("a:  %s\n", a.ToString_i8(buff, sizeof(buff)));
    printf("b:  %s\n", b.ToString_i8(buff, sizeof(buff)));

    MmxAdd(a, b, MmxAddOp::paddb, &c);
    printf("\npaddb results\n");
    printf("c:  %s\n", c.ToString_i8(buff, sizeof(buff)));

    MmxAdd(a, b, MmxAddOp::paddsb, &c);
    printf("\npaddsb results\n");
    printf("c:  %s\n", c.ToString_i8(buff, sizeof(buff)));

    // Packed byte addition - unsigned integers
    a.u8[0] = 50;  b.u8[0] = 30;
    a.u8[1] = 80;  b.u8[1] = 64;
    a.u8[2] = 132; b.u8[2] = 130;
    a.u8[3] = 200; b.u8[3] = 180;

    a.u8[4] = 42;  b.u8[4] = 90;
    a.u8[5] = 60;  b.u8[5] = 85;
    a.u8[6] = 140; b.u8[6] = 160;
    a.u8[7] = 10;  b.u8[7] = 14;

    printf("\n\nPacked byte addition - unsigned integers\n");
    printf("a:  %s\n", a.ToString_u8(buff, sizeof(buff)));
    printf("b:  %s\n", b.ToString_u8(buff, sizeof(buff)));

    MmxAdd(a, b, MmxAddOp::paddb, &c);
    printf("\npaddb results\n");
    printf("c:  %s\n", c.ToString_u8(buff, sizeof(buff)));

    MmxAdd(a, b, MmxAddOp::paddusb, &c);
    printf("\npaddusb results\n");
    printf("c:  %s\n", c.ToString_u8(buff, sizeof(buff)));
}

void MmxAddWords(void)
{
    MmxVal a, b, c;
    char buff [256];

    // Packed word addition - signed integers
    a.i16[0] = 550;     b.i16[0] = 830;
    a.i16[1] = 30000;   b.i16[1] =5000;
    a.i16[2] = -270;    b.i16[2] = -320;
    a.i16[3] = -7000;   b.i16[3] = -32000;

    printf("\n\nPacked word addition - signed integers\n");
    printf("a:  %s\n", a.ToString_i16(buff, sizeof(buff)));
    printf("b:  %s\n", b.ToString_i16(buff, sizeof(buff)));

    MmxAdd(a, b, MmxAddOp::paddw, &c);
    printf("\npaddw results\n");
    printf("c:  %s\n", c.ToString_i16(buff, sizeof(buff)));

    MmxAdd(a, b, MmxAddOp::paddsw, &c);
    printf("\npaddsw results\n");
    printf("c:  %s\n", c.ToString_i16(buff, sizeof(buff)));

    // Packed word addition - unsigned integers
    a.u16[0] = 50;     b.u16[0] = 30;
    a.u16[1] = 48000;  b.u16[1] = 20000;
    a.u16[2] = 132;    b.u16[2] = 130;
    a.u16[3] = 10000;  b.u16[3] = 60000;

    printf("\n\nPacked word addition - unsigned integers\n");
    printf("a:  %s\n", a.ToString_u16(buff, sizeof(buff)));
    printf("b:  %s\n", b.ToString_u16(buff, sizeof(buff)));

    MmxAdd(a, b, MmxAddOp::paddw, &c);
    printf("\npaddw results\n");
    printf("c:  %s\n", c.ToString_u16(buff, sizeof(buff)));

    MmxAdd(a, b, MmxAddOp::paddusw, &c);
    printf("\npaddusw results\n");
    printf("c:  %s\n", c.ToString_u16(buff, sizeof(buff)));
}

int main(int argc, char* argv[])
{
    MmxAddBytes();
    MmxAddWords();
    return 0;
}
