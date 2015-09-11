; Name:     congruentialrng.asm
;
; Purpose:  Create pseudo random number x in an interval [a,b] using the 
;           congruential pseudo random generator from George Marsaglia
;           http://school.anhb.uwa.edu.au/personalpages/kwessen/shared/Marsaglia03.html

[list -]
    %include "unistd.inc"
[list +]

%define MAXNUMBERS   255        ; 255 is maximum number for this program
%define LF            10        ; linefeed

BITS 64

section .bss
      buffer:             resb 1
    
section .data
      random:            db       "0"
      .length:           equ      $-random
      ; the table array to store the frequency of each individual number
      table:             db       0,0,0,0,0,0,0,0,0
      tableline1:        db       "number of generated "
      .length:           equ      $-tableline1
      tableline2:        db       "'s : "
      .length:           equ      $-tableline2
      seed:              dq       0                     ; the seed
      
section .text
      global _start
_start:

      mov       rcx, MAXNUMBERS                 ; initialize outer-loop counter
      call      InitRandomGenerator
      
nextRandom:      
      push      rcx
      mov       rdi, random                     ; bufferaddress in RDI
repeat:
      ; generate numbers in the interval [1,9]
      mov       rax, 1                          ; lower boundary of interval
      mov       rdx, 9                          ; higher boundary of interval
      call      GenerateRandom
      ; adjust table with counts for each generated number
      mov       rdx, rax                        ; number in RDX
      mov       rsi, table
      add       rsi, rdx                        ; point to the right place in the table
      dec       rsi
      inc       BYTE[rsi]                       ; increment position in table
      ; convert the number to ASCII
      ; depending the number length needed we convert the number of needed bits in ASCII hexadecimal
      ; in this example I only use the lowest nibble of RAX since the interval is [5,9]
      call      NIBBLEtoHexASCII
      cld
      stosb
      mov       rax, SYS_WRITE
      mov       rdi, STDOUT
      mov       rsi, random
      mov       rdx, random.length              ; add 1 for CRLF
      syscall     
      pop       rcx                             ; restore outer-loop counter
      dec       rcx
      and       rcx, rcx
      jz        printStatistics
      push      rcx                             ; syscall changes RCX !!
      mov       al, ","
      call      WriteChar
      pop       rcx
      jmp       nextRandom
printStatistics:
      mov       al, LF
      call      WriteChar
      mov       rcx, 9
      mov       rsi, table
nextLine:
      push      rsi
      mov       rsi, tableline1
      mov       rdx, tableline1.length
      call      WriteLine      
      mov       rax, 10
      sub       rax, rcx
      call      BYTEtoDecASCII
      call      WriteDecimal
      mov       rsi, tableline2
      mov       rdx, tableline2.length
      call      WriteLine
      pop       rsi
      xor       rax, rax
      lodsb
      call      BYTEtoDecASCII
      call      WriteDecimal
      mov       al, 10
      call      WriteChar
      loop      nextLine
      mov       rax, SYS_EXIT
      xor       rdi, rdi
      syscall

InitRandomGenerator:
      rdtsc
      rol       rdx, 32
      or        rax, rdx
      mov       QWORD[seed], rax
      ret
      
GenerateRandom:
; in RAX :: lower boundary of interval
;    RDX :: higher boundary of interval
      ; calculate interval length
      dec       rax                          ; minus one so we can have value for lower boundary too
      push      rax                          ; save lower boundary
      clc
      sub       rdx, rax                     ; calculate interval length
      mov       rbx, rdx                     ; put in RBX
      call      CongruentialRNG
      ; create random number rax <= number <= rdx
      xor       rdx, rdx
      idiv      rbx                          ; RAX = RAX \ RBX
      cmp       rdx, 0
      jnz       .skip
      add       rdx, rbx
.skip:
      pop       rax                          ; restore lower boundary
      add       rdx, rax                     ; add lower boundary to random number
      mov       rax, rdx                     ; RAX is number in interval [RAX,RDX]
      ret

      ; Multiply with carry algorithm
CongruentialRNG:
      push      rbx
      push      rdx
      xor       rdx, rdx
      mov       rax, QWORD[seed]
      mov       rbx, 69069
      mul       rbx
      add       rax, 362437                  ; RAX is the random number
      mov       QWORD[seed], rax             ; and also new seed
      pop       rdx
      pop       rbx
      ret      
      
      ; write a decimal in EAX to STDOUT
WriteDecimal:
      ror       eax, 16
      and       al, al
      jz        gettenthts
      call      WriteChar
gettenthts:
      rol       eax, 8
      and       al, al
      jz        getdigits
      call      WriteChar
getdigits:
      rol       eax, 8
      call      WriteChar
      ret
      
      ; write a character in AL to STDOUT
WriteChar:
      push      rdx
      push      rsi
      mov       BYTE[buffer], al
      mov       rdx, 1
      mov       rsi, buffer
      jmp       _write
      
      ; write a string pointed by RSI with length RDX to STDOUT
WriteLine:
      push      rdx
      push      rsi
_write:
      push      rdi
      push      rcx
      push      rax
      mov       rdi, STDOUT
      mov       rax, SYS_WRITE
      syscall
      pop       rax
      pop       rcx
      pop       rdi
      pop       rsi
      pop       rdx
      ret

      ; convert a byte in AL to its decimalk ASCII equivalent in EAX
BYTEtoDecASCII:
; in  :: AL  = BYTE or 8 bits
; out :: EAX = lowest 24 bits are Decimal ASCII of BYTE
;int 3
      push      rbx
      push      rcx
      push      rdx
      push      r8
      xor       rcx, rcx
      xor       r8, r8
      mov       rbx, 10
.@@1:      
      xor       rdx, rdx
      idiv      rbx
      or        dl, "0"
      shrd      r8, rdx, 8
      inc       rcx
      and       al, al
      jnz        .@@1
      shl       rcx, 3
      shld      rax, r8, cl
      pop       r8
      pop       rdx
      pop       rcx
      pop       rbx
      ret

      ; convert a nibble in AL to its hexadecimal ASCII equivalent in AL
NIBBLEtoHexASCII:
; in  :: AL = NIBBLE or 4 bits (least significant)
; out :: AL = Hexadecimal ASCII of NIBBLE
      and       al, 0x0F
      or        al, "0"
      cmp       al, "9"
      jbe       .@@1
      add       al, 7
.@@1:
      ret