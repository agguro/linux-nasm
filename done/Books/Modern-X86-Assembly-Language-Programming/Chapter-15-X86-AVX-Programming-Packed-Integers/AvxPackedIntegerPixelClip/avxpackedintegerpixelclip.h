#pragma once

#include "../../CommonFiles/miscdefs.h"

// The following structure must match the stucture that's declared
// in the file avxpackedintegerpixelclip.asm.
typedef struct
{
    Uint8* Src;                 // source buffer
    Uint8* Des;                 // destination buffer
    Uint32 NumPixels;           // number of pixels
    Uint32 NumClippedPixels;    // number of clipped pixels
    Uint8 ThreshLo;             // low threshold
    Uint8 ThreshHi;             // high threshold
} PcData;

// Functions defined in avxpackedintegerpixelclip.asm
extern "C" bool AvxPiPixelClip(PcData* pc_data);
