; Name:     quadrimester.asm
;
; Build:    nasm "-felf64" daysinmonth.asm -l daysinmonth.lst -o daysinmonth.o
;
; Description:
; calculating in which quadrimester a month is.
;
; month         nr  binary in AL  AH = AH <- AL  AH <- AH + 1  AH <- AH >> 3  AH <- AH << 1   AL <- AL + AH   AL = AL >> 2
; ----------   ---  ------------  -------------  ------------  -------------  --------------  -------------   ------------
; january       1     00000001      00000001       00000010       00000000         00000000     00000001        00000000
; february      2     00000010      00000010       00000011       00000000         00000000     00000001        00000000
; march         3     00000011      00000011       00000100       00000000         00000000     00000011        00000000
; april         4     00000100      00000100       00000101       00000000         00000000     00000100        00000001
; may           5     00000101      00000101       00000110       00000000         00000000     00000101        00000001
; june          6     00000110      00000110       00000111       00000000         00000000     00000110        00000001
; july          7     00000111      00000111       00001000       00000001         00000010     00001001        00000010
; august        8     00001000      00001000       00001001       00000001         00000010     00001010        00000010
; september     9     00001001      00001001       00001010       00000001         00000010     00001011        00000010
; october      10     00001010      00001010       00001011       00000001         00000010     00001100        00000011
; november     11     00001011      00001011       00001100       00000001         00000010     00001101        00000011
; december     12     00001100      00001100       00001101       00000001         00000010     00001110        00000011
;
; incrementing the value in AL by one and erasing all bits in AH gives us the binary value of the quadrimester of that month.
; 
; Usage:
; This is a demonstration only. 
; Also it's an alternative to get the remainder of the division of 4 bits numbers by 3.

bits 64
                
section .text
        global Quadrimester
    
Quadrimester:
; calculate the quadrimester number of a month in AL
 
      mov       ah, al          ; month in AH
      inc       ah              ; q = month + 1
      shr       ah, 3           ; s = left most bit of q, other bits are destroyed
      shl       ah, 1           ; s = s * 2
      add       al, ah          ; q = q + s
      shr       al, 2           ; q = q div 4
      inc       al              ; q = q + 1
      xor       ah, ah          ; clear AH
      ret                       ; return quadrimester in AL
