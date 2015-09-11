; quadrimester.asm
;
; calculating in which quadrimester a month is.
; Demonstration on how to get a quadrimesternumber for a specific month.
; Shift operations are faster than divisions therefor this little program,
; however this algorithm takes more shifts than semester an trimester algorithms, I've added
; this program for being complete.
; Also it's an alternative for dividing 4 bits numbers by 3.
;
; quadrimester = ((((( monthnumber + 1 ) >> 3 ) << 1 ) + monthnumber ) >> 2 ) + 1

[list -]
      %include "unistd.inc"
[list +]

bits 64

section .bss
      
section .data

      quadrimester: db   "quadrimester "
      .nr:          db   "0",10
      .length:      equ  $-quadrimester
      months:       db   "January   : "
      .length:      equ  $-months
                    db   "February  : "
                    db   "March     : "
                    db   "April     : "
                    db   "May       : "
                    db   "June      : "
                    db   "July      : "
                    db   "August    : "
                    db   "September : "
                    db   "October   : "
                    db   "November  : "
                    db   "December  : "
                
section .text
        global _start

_start:

      mov       rcx, 1          ; the months
.repeat:      
      mov       rax, rcx
      call      Quadrimester
      add       al, "0"
      mov       BYTE[quadrimester.nr], al
      push      rcx
      mov       rbx, rcx
      dec       rbx
      mov       rsi, months
      imul      rbx, months.length
      add       rsi, rbx
      syscall   write, stdout, rsi, months.length
      syscall   write, stdout, quadrimester, quadrimester.length
      pop       rcx
      inc       rcx
      cmp       rcx, 13
      jne       .repeat
      syscall   exit, 0
      
Quadrimester:
; calculate the quadrimester number of a month in AL
 
      mov       ah, al          ; month in AH
      inc       ah              ; q = month + 1
      shr       ah, 3           ; s = left most bit of q (sign bit)
      shl       ah, 1           ; s = s * 2
      add       al, ah          ; q = q + s
      xor       ah, ah          ; clear AH, can be removed if ignored in result
      shr       al, 2           ; q = q div 4
      inc       al              ; q = q + 1
      ret                       ; return quadrimester in AL