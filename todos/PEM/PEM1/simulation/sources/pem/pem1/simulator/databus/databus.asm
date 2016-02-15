; Name:         databus.asm
; Build:        see makefile
; Description:  Testprogram for PEM1

BITS 64

[list -]
    %include "databus.inc"
[list +]

section .bss
    
section .data
    message:               db "databus bit X is "
    .length:               equ $-message
    messageSet:            db "set", 10
    messageSet.length:     equ $-messageSet
    messageReset:          db "reset", 10
    messageReset.length:   equ $-messageReset
    messageChanged:        db "changed ", 10
    messageChanged.length: equ $-messageChanged
    
    DATABUS adresbus
    
section .text
    global _start
_start:
   
    mov     rax, adresbus
    mov     rax, adresbus.bit0
    mov     rax, adresbus.bit0.ptr
    mov     al, adresbus.bit0.value
    
    mov     rax, adresbus.bit1
    mov     rax, adresbus.bit1.ptr
    mov     al, adresbus.bit1.value
    
    mov     rax, adresbus.bit2
    mov     rax, adresbus.bit2.ptr
    mov     al, adresbus.bit2.value
    
    mov     rax, adresbus.bit3
    mov     rax, adresbus.bit3.ptr
    mov     al, adresbus.bit3.value
    
    mov     rax, adresbus.bit4
    mov     rax, adresbus.bit4.ptr
    mov     al, adresbus.bit4.value
    
    mov     rax, adresbus.bit5
    mov     rax, adresbus.bit5.ptr
    mov     al, adresbus.bit5.value
    
    mov     rax, adresbus.bit6
    mov     rax, adresbus.bit6.ptr
    mov     al, adresbus.bit6.value
    
    mov     rax, adresbus.bit7
    mov     rax, adresbus.bit7.ptr
    mov     al, adresbus.bit7.value
      
    mov     al, adresbus.bit0.value
    mov     al, adresbus.bit1.value
    mov     al, adresbus.bit2.value
    mov     al, adresbus.bit3.value
    mov     al, adresbus.bit4.value
    mov     al, adresbus.bit5.value
    mov     al, adresbus.bit6.value
    mov     al, adresbus.bit7.value
    
    mov     rdx, OnBit0Set
    adresbus.bit0.OnSet
    mov     rdx, OnBit1Set
    adresbus.bit1.OnSet
    mov     rdx, OnBit2Set
    adresbus.bit2.OnSet
    mov     rdx, OnBit3Set
    adresbus.bit3.OnSet
    mov     rdx, OnBit4Set
    adresbus.bit4.OnSet
    mov     rdx, OnBit5Set
    adresbus.bit5.OnSet
    mov     rdx, OnBit6Set
    adresbus.bit6.OnSet
    mov     rdx, OnBit7Set
    adresbus.bit7.OnSet

    mov     rdx, OnBit0Reset
    adresbus.bit0.OnReset
    mov     rdx, OnBit1Reset
    adresbus.bit1.OnReset
    mov     rdx, OnBit2Reset
    adresbus.bit2.OnReset
    mov     rdx, OnBit3Reset
    adresbus.bit3.OnReset
    mov     rdx, OnBit4Reset
    adresbus.bit4.OnReset
    mov     rdx, OnBit5Reset
    adresbus.bit5.OnReset
    mov     rdx, OnBit6Reset
    adresbus.bit6.OnReset
    mov     rdx, OnBit7Reset
    adresbus.bit7.OnReset

    mov     rdx, OnBit0Changed
    adresbus.bit0.OnChanged
    mov     rdx, OnBit1Changed
    adresbus.bit1.OnChanged
    mov     rdx, OnBit2Changed
    adresbus.bit2.OnChanged
    mov     rdx, OnBit3Changed
    adresbus.bit3.OnChanged
    mov     rdx, OnBit4Changed
    adresbus.bit4.OnChanged
    mov     rdx, OnBit5Changed
    adresbus.bit5.OnChanged
    mov     rdx, OnBit6Changed
    adresbus.bit6.OnChanged
    mov     rdx, OnBit7Changed
    adresbus.bit7.OnChanged
    
    adresbus.bit0.Set
    adresbus.bit0.Reset
    adresbus.bit0.Invert
    adresbus.bit0.Get
    adresbus.bit1.Load
    
    adresbus.bit1.Set
    adresbus.bit1.Reset
    adresbus.bit1.Invert
    adresbus.bit1.Get
    adresbus.bit2.Load

    adresbus.bit2.Set
    adresbus.bit2.Reset
    adresbus.bit2.Invert
    adresbus.bit2.Get
    adresbus.bit3.Load

    adresbus.bit3.Set
    adresbus.bit3.Reset
    adresbus.bit3.Invert
    adresbus.bit3.Get
    adresbus.bit4.Load

    adresbus.bit4.Set
    adresbus.bit4.Reset
    adresbus.bit4.Invert
    adresbus.bit4.Get
    adresbus.bit5.Load

    adresbus.bit5.Set
    adresbus.bit5.Reset
    adresbus.bit5.Invert
    adresbus.bit5.Get
    adresbus.bit6.Load

    adresbus.bit6.Set
    adresbus.bit6.Reset
    adresbus.bit6.Invert
    adresbus.bit6.Get
    adresbus.bit7.Load

    adresbus.bit7.Set
    adresbus.bit7.Reset
    adresbus.bit7.Invert
    adresbus.bit0.Reset         ; to check bit0.Load
    adresbus.bit7.Get
    adresbus.bit0.Load

    syscall.exit ENOERR

OnBit0Set:
    mov     dl, "0"
    jmp     displaymessageset
OnBit1Set:
    mov     dl, "1"
    jmp     displaymessageset
OnBit2Set:
    mov     dl, "2"
    jmp     displaymessageset
OnBit3Set:
    mov     dl, "3"
    jmp     displaymessageset
OnBit4Set:
    mov     dl, "4"
    jmp     displaymessageset
OnBit5Set:
    mov     dl, "5"
    jmp     displaymessageset
OnBit6Set:
    mov     dl, "6"
    jmp     displaymessageset
OnBit7Set:
    mov     dl, "7"
displaymessageset:
    push    messageSet
    push    messageSet.length
    push    rdx
    jmp     displaymessage
          
OnBit0Reset:
    mov     dl, "0"
    jmp     displaymessagereset
OnBit1Reset:
    mov     dl, "1"
    jmp     displaymessagereset
OnBit2Reset:
    mov     dl, "2"
    jmp     displaymessagereset
OnBit3Reset:
    mov     dl, "3"
    jmp     displaymessagereset
OnBit4Reset:
    mov     dl, "4"
    jmp     displaymessagereset
OnBit5Reset:
    mov     dl, "5"
    jmp     displaymessagereset
OnBit6Reset:
    mov     dl, "6"
    jmp     displaymessagereset
OnBit7Reset:
    mov     dl, "7"
displaymessagereset:
    push    messageReset
    push    messageReset.length
    push    rdx
    jmp     displaymessage
    
OnBit0Changed:
    mov     dl, "0"
    jmp    displaymessagechanged
OnBit1Changed:
    mov     dl, "1"
    jmp    displaymessagechanged
OnBit2Changed:
    mov     dl, "2"
    jmp    displaymessagechanged
OnBit3Changed:
    mov     dl, "3"
    jmp    displaymessagechanged
OnBit4Changed:
    mov     dl, "4"
    jmp    displaymessagechanged
OnBit5Changed:
    mov     dl, "5"
    jmp    displaymessagechanged
OnBit6Changed:
    mov     dl, "6"
    jmp    displaymessagechanged
OnBit7Changed:
    mov     dl, "7"
    jmp    displaymessagechanged
displaymessagechanged:
    push    messageChanged
    push    messageChanged.length
    push    rdx
    
displaymessage:
    pop     rdx                     ; get bit number
    mov     rsi, message
    mov     BYTE [rsi+12], dl       ; put bitnumber in place
    mov     rdx, message.length
    mov     rdi, STDOUT
    mov     rax, SYS_WRITE
    syscall
    pop     rdx                     ; get length message
    pop     rsi                     ; get address message         
    mov     rdi, STDOUT
    mov     rax, SYS_WRITE
    syscall
    ret
