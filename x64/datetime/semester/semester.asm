; semester.asm
;
; calculating in which semester a month is
; This program is merely a demonstration on how to convert a month number to the semester number for that specific
; month. You can however easely divide the monthnumber by six but divisions take more time to execute than shift instrictions.
;
; semesternr = (( monthnumber + 1 ) >> 3 ) + 1
; january has montnumber 1

[list -]
      %include "unistd.inc"
[list +]

bits 64

section .bss
      
section .data

      semester: db      "semester "
      .nr:      db      "0",10
      .length:  equ     $-semester
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

      mov       rcx, 1          ; the months, starting with january as month = 1
.repeat:      
      mov       rax, rcx
      call      Semester
      add       al, "0"
      mov       BYTE[semester.nr], al
      push      rcx
      mov       rbx, rcx
      dec       rbx
      mov       rsi, months
      imul      rbx, months.length
      add       rsi, rbx
      syscall   write, stdout, rsi, months.length
      syscall   write, stdout, semester, semester.length
      pop       rcx
      inc       rcx
      cmp       rcx, 13
      jne       .repeat
      syscall   exit, 0
      
Semester:
; calculates the semester number of a month in AL
 
      inc       al              ; s = month + 1
      shr       al, 3           ; s = s div 8
      inc       al              ; s = s + 1
      ret                       ; return semester in AL