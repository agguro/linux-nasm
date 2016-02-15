; trimester.asm
;
; calculating in which trimester a month is
; Demonstration on how to get the trimesternumber of a specific monthnumber.
; Divisions take more time to execute than shift instructions.
;
; trimesternr = (( monthnumber - 1 ) >> 2 ) + 1

[list -]
      %include "unistd.inc"
[list +]

bits 64

section .bss
      
section .data

      trimester:  db    "trimester "
      .nr:        db    "0",10
      .length:    equ   $-trimester
      months:     db    "January   : "
      .length:    equ   $-months
                  db    "February  : "
                  db    "March     : "
                  db    "April     : "
                  db    "May       : "
                  db    "June      : "
                  db    "July      : "
                  db    "August    : "
                  db    "September : "
                  db    "October   : "
                  db    "November  : "
                  db    "December  : "
                
section .text
        global _start

_start:

      mov       rcx, 1          ; the months
.repeat:      
      mov       rax, rcx
      call      Trimester
      add       al, "0"
      mov       BYTE[trimester.nr], al
      push      rcx
      mov       rbx, rcx
      dec       rbx
      mov       rsi, months
      imul      rbx, months.length
      add       rsi, rbx
      syscall   write, stdout, rsi, months.length
      syscall   write, stdout, trimester, trimester.length
      pop       rcx
      inc       rcx
      cmp       rcx, 13
      jne       .repeat
      syscall   exit, 0
      
Trimester:
; calculates the trimester number of a month in AL
; (takes 8 bytes)
 
      dec       al              ; t = month - 1
      shr       al, 2           ; t = t idiv 4
      inc       al              ; t = t + 1
      ret                       ; return trimester in AL