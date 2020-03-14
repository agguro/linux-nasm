; Name:  oop.asm
; Build: see makefile or

[list -]
%include "oop.inc"
[list +]

BITS 64
[list -]
%include "bit.class"
%include "databus.class"
%include "gate.class"

[list +]

section .bss
    
section .data

    BIT a, 0
    db "databus"
    DATABUS databus
    db "end databus"
    changed:    db  "a was changed",10
    .length:    equ $-changed
    bitchanged: db  "databus bit was changed",10
    .length:    equ $-bitchanged

    GATE gate
    
section .text
    global _start
_start:

    a.ptr
    mov     dl, BYTE[rax]
    a.Set
    a.Reset
    a.Invert
    a.Get
    
    mov dl, 1
    a.Load
    
    
    databus.bit0.value
    databus.bit0.Set
    databus.bit0.Reset
    databus.bit0.Invert
    databus.bit0.Get

    databus.bit1.value
    databus.bit1.Set
    databus.bit1.Reset
    databus.bit1.Invert
    databus.bit1.Get

    databus.bit2.value
    databus.bit2.Set
    databus.bit2.Reset
    databus.bit2.Invert
    databus.bit2.Get

    databus.bit3.value
    databus.bit3.Set
    databus.bit3.Reset
    databus.bit3.Invert
    databus.bit3.Get

    databus.bit4.value
    databus.bit4.Set
    databus.bit4.Reset
    databus.bit4.Invert
    databus.bit4.Get

    databus.bit5.value
    databus.bit5.Set
    databus.bit5.Reset
    databus.bit5.Invert
    databus.bit5.Get

    databus.bit6.value
    databus.bit6.Set
    databus.bit6.Reset
    databus.bit6.Invert
    databus.bit6.Get

    databus.bit7.value
    databus.bit7.Set
    databus.bit7.Reset
    databus.bit7.Invert
    databus.bit7.Get

    
    
    
    
    syscall.exit ENOERR

