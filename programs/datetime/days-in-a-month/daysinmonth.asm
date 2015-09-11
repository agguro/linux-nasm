; daysinmonth.asm
;
; calculating the days in a month using boolean instructions.
; February hass in this program always 28 days. Combined with a leapyear you can add one day.

[list -]
      %include "unistd.inc"
[list +]

bits 64

section .bss
      
section .data

      days:     db      "00 days",10
      .length:  equ     $-days
      months:   db      "January   : "
      .length:  equ     $-months
                db      "February  : "
                db      "March     : "
                db      "April     : "
                db      "May       : "
                db      "June      : "
                db      "July      : "
                db      "August    : "
                db      "September : "
                db      "October   : "
                db      "November  : "
                db      "December  : "
                
section .text
        global _start

_start:

     mov       rcx, 1          ; the months
.repeat:      
     mov       rax, rcx
     call      DaysInMonth
     mov       bl, 10
     idiv      bl
     add       ax, "00"
     mov       WORD[days], ax
     push      rcx
     mov       rbx, rcx
     dec       rbx
     mov       rsi, months
     imul      rbx, months.length
     add       rsi, rbx
     syscall   write, stdout, rsi, months.length
     syscall   write, stdout, days, days.length
     pop       rcx
     inc       rcx
     cmp       rcx, 13
     jne       .repeat
     
     syscall   exit, 0
      
DaysInMonth:
; calculates the number of days in a month, february count 28 days, depending the year
; we have to add 1 day, but for this the mainprogram is responsable.

      mov       ah, al             ; monthnumber in AH
      shr       ah, 3
      xor       ah, al
      and       ah, 1
      or        ah, 28
      xor       al, 2
      jz        .@1
      or        ah, 2
.@1:      
      shr       ax, 8
      ret                       ; return number of days in AL