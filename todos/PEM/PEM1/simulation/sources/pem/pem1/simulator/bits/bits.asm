; Name:         bits.asm
; Build:        see makefile
; Description:  Testprogram for PEM1

BITS 64

[list -]
    %include "bits.inc"
[list +]

section .bss
    
section .data
    message1:    db "bit a has changed - "
     .length:    equ $-message1
    message2:    db "bit b has changed - "
     .length:    equ $-message2
    message3:    db "bit is set",10
     .length:    equ $-message3
    message4:    db "bit is reset",10
     .length:    equ $-message4
     
    BIT a
    BIT b
    
section .text
    global _start
_start:

    mov rdx, OnBitAChanged 
    a.OnChanged
    mov rdx, OnBitBChanged 
    b.OnChanged
    mov rdx, OnBitSet
    a.OnSet
    b.OnSet
    mov rdx, OnBitReset
    a.OnReset
    b.OnReset   
    
    a.Set
    a.Set
    a.Set
    a.Reset
    a.Reset
    a.Invert
    a.Invert
    ; implies a connection between bits
    a.Get
    b.Load
    
    b.Reset
    
    syscall.exit ENOERR

OnBitAChanged:
    syscall.write message1
    ret
OnBitSet:
    syscall.write message3
    ret
OnBitReset:
    syscall.write message4
    ret
OnBitBChanged:
    syscall.write message2
    ret
