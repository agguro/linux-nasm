;name: fpuhextobcd.asm
;
;build: nasm -felf64 fpuhextobcd.asm -o fpuhextobcd.asm
;
;description: conversion from hexadecimal to bcd using the fpu.
;             The buffer to store the bcd value must be 10 bytes long.
;             The hexadecimal value is stored in a 64 bit memory location (8 bytes).
;             The bcd value is stored as follows:
;             The byte at the highest address is the sign byte, either 0x00 for positive or
;             0x80 for negative values.
;             The digits are stored in the 9 other bytes, where the byte at the highest address
;             is the most significant group of digits.  The two digits per byte are stored the least
;             significant digit in the most significant nibble.
;
;             An example:
;             the value: 654321 must be stored as
;             value:    db  0x21,0x43,0x65,0x00,0x00,0x00,0x00,0x00,0x00,0x00
;                        -654321 as
;             value:    db  0x21,0x43,0x65,0x00,0x00,0x00,0x00,0x00,0x00,0x80
;
;             The most significant nibble of the most significant byte (sign byte) is always 0.
;             rdi has the memory location to the hexdecimal value
;             rsi has the memory location of the 10 byte buffer to store the bcd value.
;             The program doesn't check the boundaries of the hexadecimal value which are
;             [0xF21F494C589C0001,0x0DE0B6B3A763FFFF] signed values

bits 64

global fpuhextobcd

fpuhextobcd:
    ;get hexadecimal value at rdi in fpu
    fild    qword[rdi]
    ;store value in fpu as bcd at rsi
    fbstp   tword[rsi]
    ret
