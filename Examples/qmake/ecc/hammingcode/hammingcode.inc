%ifndef _HAMMINGCODE_INC_
%define _HAMMINGCODE_INC_

%include "unistd.inc"

;The program changes values,first 4 bits are ignored in the generation of the Hammingcode word
;and the checkbits are cleared.  Bit 7 isn't used in the Hammingcode word because we can only
;have 3 checkbits for 4 bits of data.
;The bit on position 7 is the paritybit for the entire Hammingcode.
;Hammingcode words count the bits from left to right and starting with 1.

    %define DATALENGTH       4
    ; we only can store 4 bits in AL
    %define BITSTOIGNORE     4

%endif
