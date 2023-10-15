#pragma once
#include "../../CommonFiles/miscdefs.h"

// These functions are defined in AvxFma.cpp
extern void AvxFmaSmooth5Cpp(float* y, const float*x, Uint32 n, const float* sm5_mask);
extern bool AvxFmaInitX(float* x, Uint32 n);

// These functions are defined in AvxFma_.asm
extern "C" void AvxFmaSmooth5a(float* y, const float*x, Uint32 n, const float* sm5_mask);
extern "C" void AvxFmaSmooth5b(float* y, const float*x, Uint32 n, const float* sm5_mask);
extern "C" void AvxFmaSmooth5c(float* y, const float*x, Uint32 n, const float* sm5_mask);

// next function is removed because of windows-only functions.  In time I need to figure out
// how to reconstruct this function for g++ on Linux
// These functions are defined in AvxFmaTimed.cpp
//extern void AvxFmaTimed(void);
