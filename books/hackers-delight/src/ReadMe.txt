Hacker's Delight Linux assembly files.
Assemble with nasm, link with ld or use the Makefile.

Following functions are already available:

3valcomp	: three valued compare
absolute	: absolute value
average		: average of two integers
irob		: isolate rightmost one bit
krobstzco	: keep rightmost one bit, set trailing zero bits, clear all other bits
ktobsrzco	: keep trailing one bits, set rightmost zero bit, clear all other bits
nlz		: number of leading zeros
ntz		: number of trailing zeros
parity		: paritybit
pop		: number of one bits
sign		: sign bit
signext		: sign extension
snoob		: next higher number with same number of one bits
srsfu		: shift right signed from unsigned
torcob		: turn off the rightmost contigious string of one bits
torob		: turn off rightmost one bit
torobsa		: turn off rightmost one bit, set all other bits
torzb		: turn on rightmost zero bit
torzbca		: turn on rightmost zero bit, clear all other bits
totob		: turn off trailing one bits
totobsa		: turn off trailing one bits, set all other bits
totzb		: turn on trailing zero bits
totzbca		: turn on trailing zero bits, clear all other bits

2018-01-17 : This repository will be updated soon...
A better implementation is the use of macros because the programs are rather short.  Anyway here are the subroutines.
The Makefile does not generate a static or dynamic library (not yet)
nlz and ntz subroutines needs a remake and put it all in a loop.
