;name: checkparity.asm
;
;build: nasm "-felf64" checkparity.asm -l checkparity.lst -o checkparity.o
;       ld -s -melf_x86_64 -o checkparity checkparity.o 
;
;description: "In x86 processors, the parity flag reflects the parity only of the least significant
;             byte of the result, and is set if the number of set bits of ones is even."
;             source: http://en.wikipedia.org/wiki/Parity_flag
;             Therefore this example algorithm to determine the parity of a 63 bit dataword in RAX. Bit
;             63 (remember we count the bits starting at zero) will be used as the parity bit of the
;             dataword.
;remark:
;As an extra option you can choose to calculate parity even or parity odd paritybit.
;Just keep in mind that parity odd is less in use, therefor parity even in the example.
;Even so, parity checks aren't common on 63 bits, the chance having more than one
;erroneous bit increases with the number of bits in a dataword.
 
BITS 64

[list -]
    %include "unistd.inc"
    %include "sys/termios.inc"
[list +]

%define PARITY_EVEN     1
%define PARITY_ODD      0
%define PARITY_METHOD   PARITY_EVEN ; define to PARITY_ODD if you like the other parity check method

;the databits on which we will test
;                                         bitnumbers
;                ----------------------------------------------------------------  
;                66  6         5         4         3         2         1
;                43  0         0         0         0         0         0        0

%define DATABITS 1110000000000000000000000000000000000000000000000000000000000000b

;bit 64 is the paritybit that comes with the dataword, remember we don't calculate, we check.
;We expect the message "parity not correct" since we check on even parity and there is an odd
;number of 1 bits 

section .data
    
    message:        db  "The parity bit is "
      .placeholder  db  0,0,0,0         ; to store "NOT " if the check result in not ok                    
      %if PARITY_METHOD = PARITY_EVEN
                    db  "1.", 10        
      %else
                    db  "0.", 10
      %endif
      .length:      equ $-message
      
section .text
    
global _start
_start:

;we cannot check the parity of the entire 64 bit word on a Intel x86
;therefor this routine
    mov     al, PARITY_METHOD                   ;set the parity method in AL
    mov     cl, 8                               ;check 8 bits at the time
    mov     rdx, DATABITS                       ;databits to test in RDX
    rcl     rdx, 1                              ;move the parity bit via the CFlag
    adc     ah, 0                               ;into AH and back
    clc                                         ;clear carry bit
    rcr     rdx, 1                              ;into his original place
nextGroup:
    test    rdx, rdx                            ;test parity of DL
    jp      isParityEven                        ;if parity even don't touch AL
    xor     al, 1                               ;if parity odd invert AL
isParityEven:
    shr     rdx, 8                              ;next group of 8 bits
    or      cl, cl                              ;compare CL with zero, if zero then we are done
    loopnz  nextGroup                           ;process next group of 8 bits

    cmp     ah, al                              ;compare both the received paritybit (AH) with the calculated
                                                ;paritybit (AL)
    je      write                               ;write the message
    mov     ebx, "not "                         ;if paritybits aren't the same then modify the message
    mov     dword [message.placeholder], ebx    ;by putting "NOT " into the placeholder

write:

    syscall write, stdout, message, message.length
    syscall exit, 0
    
