; Name:  oop.asm
; Build: see makefile or

[list -]
%include "oop.inc"
[list +]

BITS 64
[list -]
%include "classes/bit.class"
%include "classes/databus.class"
;%include "classes/gate.class"

[list +]

section .bss
    
section .data

    BIT a
    db "databus"
    
    DATABUS databus
    db "end databus"
    
    changed:    db  "a was changed",10
    .length:    equ $-changed
    bitchanged: db  "databus bit was changed",10
    .length:    equ $-bitchanged


section .text
    global _start
_start:

;	mov rdx,OnBitChanged
;	a.OnChanged
; 	mov rdx,OnBitSet;
;	a.OnSet
;	mov rdx,OnBitReset
;	a.OnReset

;    a.Set
;    a.Reset
;    a.Invert
;    a.Get
;    mov dl, 1
;    a.Load
    
	mov rdx,OnBitChanged
    databus.0.OnChanged
    
    databus.0.Set
    databus.0.Reset
    databus.0.Invert
    databus.0.Get

    databus.1.Set
    databus.1.Reset
    databus.1.Invert
    databus.1.Get

    databus.2.Set
    databus.2.Reset
    databus.2.Invert
    databus.2.Get

    databus.3.Set
    databus.3.Reset
    databus.3.Invert
    databus.3.Get

    databus.4.Set
    databus.4.Reset
    databus.4.Invert
    databus.4.Get

    databus.5.Set
    databus.5.Reset
    databus.5.Invert
    databus.5.Get

    databus.6.Set
    databus.6.Reset
    databus.6.Invert
    databus.6.Get

    databus.7.Set
    databus.7.Reset
    databus.7.Invert
    databus.7.Get
    
    syscall exit, 0

OnBitChanged:
    syscall write, stdout, changed, changed.length
    ret
    
OnBitSet:
    syscall write, stdout, changed, changed.length
    ret
OnBitReset:
    syscall write, stdout, changed, changed.length
    ret
