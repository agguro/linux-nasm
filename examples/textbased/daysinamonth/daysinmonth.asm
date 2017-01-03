; Name:     daysinmonth.asm
;
; Build:    nasm "-felf64" daysinmonth.asm -l daysinmonth.lst -o daysinmonth.o
;
; Description:
; All though easy solvable with an array of days in a given month, I demonstrate here the
; calculation of the number of days in a month the binary way with one register only.
;
; February has in this program always 28 days. Combined with a leapyear you can add one day.
;                                                                                                                
; month         nr  binary in AL  AH = AH <- AL   AH >> 3  AH <- AH xor AL  AH <- AH and 1  AH <- AH or 00011110  
; ----------   ---  ------------  -------------  --------  ---------------  --------------  --------------------
; january       1     00000001      00000001     00000000     00000001         00000001          00011111
; february      2     00000010      00000010     00000000     00000010         00000000          00011110
; march         3     00000011      00000011     00000000     00000011         00000001          00011111
; april         4     00000100      00000100     00000000     00000100         00000000          00011110
; may           5     00000101      00000101     00000000     00000101         00000001          00011111
; june          6     00000110      00000110     00000000     00000110         00000000          00011110
; july          7     00000111      00000111     00000000     00000111         00000001          00011111
; august        8     00001000      00001000     00000001     00001001         00000001          00011111
; september     9     00001001      00001001     00000001     00001000         00000000          00011110
; october      10     00001010      00001010     00000001     00001011         00000001          00011111
; november     11     00001011      00001011     00000001     00001010         00000000          00011110
; december     12     00001100      00001100     00000001     00001101         00000001          00011111
;
; with the result for days in a month we just have to check if the monthnumber is 2. If so then we 'erase' bit 1.
; This wil result for february the value 00011100b or 28.


bits 64

                
section .text
        global DaysInMonth

      
DaysInMonth:
; calculates the number of days in a month, february count 28 days.
; The caller program can check for leapyears and add one day to february.

      mov       ah, al              ; monthnumber in AH
      shr       ah, 3
      xor       ah, al
      and       ah, 1
      or        ah, 30
      dec       al
      dec       al                  ; when AL is zero, zero flag is set
      jnz       .done
      xor       ah, 2               ; if zero flag set, days = days - 2
.done:      
      shr       ax, 8
      ret                           ; return number of days in AL
