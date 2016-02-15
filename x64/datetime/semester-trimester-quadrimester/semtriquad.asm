>; semtriquad.asm
;
; calculating semester, trimester and quadrimester of a given month
; The month is given in his numerical form where m is [1..12]
; The results are returned as integer.
; This program must be viewed in a debugger.

[list -]
     %include "unistd.inc"
[list +]

bits 64

section .bss
      
section .data
      
section .text
     global _start

_start:

     mov       rcx, 1          ; the months
.repeat:      
     mov       rax, rcx
     push      rax
     call      SemTriQuad
     pop       rax
     inc       rcx
     cmp       rcx, 13
     jne       .repeat
     syscall   exit, 0
      
SemTriQuad:
; calculate the semester, trimester and quadrimester number of a month in AL
; the result is returned in RAX as unpacked decimal as follows:
; EAX = 000S0T0Q where S is the semester number, T the trimester number and Q the quadrimester number of the month.
; You could save some bytes by deleting the lines from the second call .@1 until the ret. The values are then stored in:
; DH = semester, DL = trimester, AL = quadrimester.

      mov       ah, al          ; month in AH
                                ; calculate the trimester
      dec       al              ; m = m - 1 
      shr       al, 2           ; m = m &gt;&gt; 2
      inc       al              ; m = m + 1
      mov       dl, al          ; DL = trimester =  ( ( m - 1 ) &gt;&gt; 2 ) + 1
      ; continue calculation of quadrimester
      mov       al, ah          ; restore m
      inc       ah              ; m = m + 1
      shr       ah, 3           ; m = m &gt;&gt; 3
      inc       ah              ; s = m + 1
      mov       dh, ah          ; DH = semester = ( ( m + 1 ) &gt;&gt; 3 ) + 1
      ; continue calculation of quadrimester
      dec       ah              ; s = s - 1
      shl       ah, 1           ; s = s * 2
      add       al, ah          ; AL = q = m (in AL) + s (in AH) 
      shr       al, 2           ; q = q &gt;&gt; 2
      inc       al              ; quadrimester = q + 1
      ror       eax, 8          ; put all numbers in EAX and in place (0S0T0Q)   
      mov       ax, dx
      rol       eax, 8
      ret