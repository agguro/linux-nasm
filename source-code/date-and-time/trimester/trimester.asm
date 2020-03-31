; Name:     trimester.asm
;
; Build:    nasm "-felf64" trimester.asm -l trimester.lst -o trimester.o
;
; Description:
; calculating in which trimester a month is.
;
; month         nr  binary in AL  AL <- AL - 1  AL <- AL >> 2
; ----------   ---  ------------  ------------  -------------
; january       1     00000001      00000000       00000000  
; february      2     00000010      00000001       00000000  
; march         3     00000011      00000010       00000000  
; april         4     00000100      00000011       00000000  
; may           5     00000101      00000100       00000001  
; june          6     00000110      00000101       00000001  
; july          7     00000111      00000110       00000001  
; august        8     00001000      00000111       00000001  
; september     9     00001001      00001000       00000010  
; october      10     00001010      00001001       00000010  
; november     11     00001011      00001010       00000010  
; december     12     00001100      00001011       00000010  
;
; incrementing the value in AL by one and erasing all bits in AH gives us the binary value of the semester of that month.
; 
; Usage:
; This is a demonstration only. 
; Also it's an alternative to get the remainder of the division of 4 bits numbers by 4.

bits 64
                
section .text
        global Trimester

Trimester:
; calculates the trimester number of a month in AL
 
      dec       al              ; t = month - 1
      shr       al, 2           ; t = t idiv 4
      inc       al              ; t = t + 1
      ret                       ; return trimester in AL
