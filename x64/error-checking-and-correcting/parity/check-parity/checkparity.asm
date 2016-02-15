; Name:     checkparity
; Build:    see makefile
; Run:      ./checkparity
; Description:
;   "In x86 processors, the parity flag reflects the parity only of the least significant
;   byte of the result, and is set if the number of set bits of ones is even."
;   source: http://en.wikipedia.org/wiki/Parity_flag
;   Therefore this example algorithm to determine the parity of a 63 bit dataword in RAX. Bit
;   63 (remember we count the bits starting at zero) wil be used as the parity bit of the
;   dataword.
;   As an extra option you can choose to calculate parity even or parity odd paritybit.
;   Just keep in mind that parity odd is less in use, therefor parity even in the example.
;   Even so, parity checks aren't common on 63 bits, the chance having more than one
;   erroneous bit increases with the number of bits in a dataword.
;   However to demonstrate the loopnz instruction in combination with CL, I find it a nice
;   example calculating parity on huge datawords.

BITS 64

[list -]
    %include "syscalls.inc"
    %include "termio.inc"
[list +]

    %define PARITY_EVEN     0
    %define PARITY_ODD      1
    
    PARITY_METHOD   equ PARITY_EVEN ; define to PARITY_ODD if you like the other parity check method

    ; the databits on which we will test
    ;                                         bitnumbers
    ;                ----------------------------------------------------------------  
    ;                66  6         5         4         3         2         1
    ;                43  0         0         0         0         0         0         0
    %define DATABITS 01000000000000000000000000000000000000000000000000000000000000000b
    ;
    ; bit 64 is the paritybit that comes with the dataword, remember we don't calculate, we check.
    ; We expect the message "parity not correct" since we check on even parity and there is an odd
    ; number of 1 bits 

section .bss

section .data
    
    message:        db  "The paritybit is "
      .placeholder  db  0,0,0,0         ; to store "NOT " if the check result in not ok
                    db  "ok.", 10
      .end:

section .text
    global _start

_start:

    mov     al, PARITY_METHOD                   ; set the parity method in AL
    mov     cl, 8                               ; check 8 bits at the time
    mov     rdx, DATABITS                       ; databits to test in RDX
    rcl     rdx, 1                              ; move the parity bit via the CFlag
    adc     ah, 0                               ; into AH and back
    rcr     rdx, 1                              ; into his original place
nextGroup:
    test    rdx, rdx                            ; test parity of DL
    jp      isParityEven                        ; if parity even don't touch AL
    xor     al, 1                               ; if parity odd invert AL
isParityEven:
    shr     rdx, 8                              ; next group of 8 bits
    or      cl, cl                              ; compare CL with zero, if zero then we are done
    loopnz  nextGroup                           ; process next group of 8 bits

    cmp     ah, al                              ; compare both the received paritybit (AH) with the calculated
                                                ; paritybit (AL)
    je      WriteMessage                        ; write the message
    mov     ebx, "NOT "                         ; if paritybits aren't the same then modify the message
    mov     DWORD[message.placeholder], ebx     ; by putting "NOT " into the placeholder

WriteMessage:   
    push    message                             ; rsi = message pointer
    pop     rsi
    push    message.end-message                 ; rdx is the message length
    pop     rdx
    push    STDOUT
    pop     rdi
    push    SYS_WRITE
    pop     rax
    syscall
    
    push    byte 0                              ; stop execution
    pop     rdi
    push    byte SYS_EXIT
    pop     rax
    syscall