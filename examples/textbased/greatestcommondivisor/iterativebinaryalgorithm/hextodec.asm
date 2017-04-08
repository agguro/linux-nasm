; Name: hextodec.asm
;
; Description: sHexToDecAscii
;              convert a 64 bit signed hexadecimal to unpacked decimal value.
;              The pointer to the buffer containing the decimal value is passed
;              in rax, the length of the decimal is passed in rdx.
;
;              uHexToDecAscii
;              convert a 64 bit signed hexadecimal to unpacked decimal value.
;              The pointer to the buffer containing the decimal value is passed
;              in rax, the length of the decimal is passed in rdx.
;
; Build: nasm -elf64 hextodec.asm

global sHexToDecAscii
global uHexToDecAscii

bits 64

section .text

uHexToDecAscii:
    push    r9   
    xor     r9,r9                       ;do unsigned convertion
    inc     r9
    jmp     sHexToDecAscii.start
sHexToDecAscii:
    push    r9
    xor     r9,r9
.start:
    push    r8
    push    rsi
    push    rbx
    push    rdi                         ;save value on stack
    mov     r8,rdi                      ;save value in r8
    ;initialize the buffer
    mov     rdi,rsi
    xor     rax,rax
    stosq                               ;clear the buffer
    stosq
    stosd
    mov     rdi,rsi
    add     rdi,19                      ;point to end of buffer
    mov     rax,r8                      ;get the hexadecimal value in rax
    and     rax,rax                     ;is it zero?
    jz      .iszero
    jns     .convert
    and     r9,r9                       ;is r9=1 -> unsigned convertion
    jnz     .convert
    mov     byte[rsi],'-'               ;set sign byte
    neg     rax                         ;get absolute value of rax
.convert:
    ;rax has the absolute value,rdi points to the last byte in the buffer
    ;start to convert.
    mov     rbx,10                      ;decimal base in rbx
.repeat:
    xor     rdx,rdx                     ;clear rdx
    div     rbx                         ;divide by ten, rdx has remainder, rax quotient
    or      dl,0x30                     ;make human readable
    mov     byte[rdi],dl                ;save digit
    dec     rdi                         ;adjust buffer pointer for next digit
    and     rax,rax                     ;is quotient zero?
    jnz     .repeat                     ;if not repeat the whole loop
    and     r9,r9                       ;is r9=1 -> continue unsigned
    jnz     .ispositive
    and     r8,r8                       ;test is value is negative
    jns     .ispositive
    mov     byte[rdi],'-'               ;value is negative, copy sign byte
    dec     rdi                         ;adjust buffer and continue calculating length
.ispositive:
    mov     rdx,rsi
    add     rdx,19                      ;point to last position in buffer
    sub     rdx,rdi                     ;subtract start position to get length of number
    inc     rdi                         ;adjust buffer pointer
    jmp     .exit
.iszero:
    or      byte[rdi],'0'               ;make ascii
    inc     rdx                         ;length of decimal value is 1
.exit:
    mov     rax,rdi                     ;return pointer in rax
    pop     rdi                         ;restore hexadecimal value in rdi
    pop     rbx                         ;restore used registers
    pop     rsi
    pop     r8
    pop     r9
    ret
