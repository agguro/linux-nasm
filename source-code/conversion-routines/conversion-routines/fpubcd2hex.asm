;name: fpubcdtohex.asm
;
;build: nasm -felf64 fpudectohex.asm -o fpudectohex.o
;
;description: Convert a bcd number from memory into hexadecimal using the fpu.
;             The buffer to store the hexadecimal must be 64 bits (8 bytes) long.
;             The bcd value must be stored as 10 bytes.
;             The byte at the highest address is the sign byte, either 0x00 for positive or
;             0x80 for negative values.
;             The digits are stored in the 9 other bytes, where the byte at the highest address
;             is the most significant group of digits.  The two digits per byte are stored the least
;             significant digit in the most significant nibble.
;             An example is in place:
;             the value: 654321 must be stored as
;             value:    db  0x21,0x43,0x65,0x00,0x00,0x00,0x00,0x00,0x00,0x00
;                        -654321 as
;             value:    db  0x21,0x43,0x65,0x00,0x00,0x00,0x00,0x00,0x00,0x80
;             The most significant nibble of the most significant byte (sign byte) is always 0.
;             rdi has the memory location to the bcd value
;             rsi has the memory location of the 16 byte buffer to store the hexadecimal.
;             The program doesn't check the validity of the bcd string, the bcd value must be in
;             [-999999999999999999,999999999999999999]

bits 64

global fpubcdtohex

fpubcdtohex:
    ;get bcd value from rdi
    fbld    tword[rdi]
    ;store bcd value as hexadecimal at rsi
    fistp   qword[rsi]
    ret
