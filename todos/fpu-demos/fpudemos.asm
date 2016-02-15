; fpudemos
; nasm -felf64 fpudemos.asm -o fpudemos.o && ld -o fpudemos fpudemos.o

bits 64

section .bss

section .data

    ival    dq  625
    iresult dq  0
    bcdvalue   db 56h,27h,52h,01h,0,0,0,0,0,0           ; bcd 1522756
    bcdresult  db 0,0,0,0,0,0,0,0,0,0                   ; bcd 1234 -> result of sqrt(1522756) stored as 34 12
    
    bval    db 34h,12h,0,0,0,0,0,0                 ; 1234
    bfrac   db 34h,12h,0,0,0,0,0,0                 ; 1234
    
            db "result" 
    bresult db 0,0,0,0,0,0,0,0,0,0                 ; 1523060
            db "fraction"
    bfraction db 0,0,0,0,0,0,0,0,0,0               ; 56642756
            db "decimals"
    decfrac db 00h,00h,00h,00h,00h,00h,00h,00h,01h,00h
            db "end of number"
    ctrlwrd     dw 0
    newctrlwrd   dw 0


section .text

global  _start:

_start:

    
    mov      rsi, ival
    fild     qword[ival]
    fsqrt
    fistp     qword[ival]               ; store as hexadecimal

    fbld     [bcdvalue]
    fsqrt
    fbstp    [bcdresult]
    
    fbld     [bval]
    fbld     [bfrac]
    fbld     [decfrac]
    fmul
    fadd
    fsqrt
    fst      st1
    fstcw    word[ctrlwrd]
    fwait
    
    ; enable truncating
    mov      ax, word[ctrlwrd]
    and      ax,0F3FFh
    or       ax,0C00h
    mov      word[newctrlwrd], ax
    fldcw    word[newctrlwrd]
        
    frndint
    fsub     st1,st0
    nop
    mov rsi, bresult
    fbstp    [bresult]                  ; store integer part
    mov rsi, decfrac
    fbld     [decfrac]
    fmul
    frndint
    
    ; restore control word
    fbstp    [decfrac]
    fldcw    word[ctrlwrd]
    
    xor      rdi,rdi
    mov      rax, 60
    syscall
    