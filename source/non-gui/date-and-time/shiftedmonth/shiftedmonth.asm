; Name:     shiftedmonth.asm
;
; Build:    nasm "-felf64" shiftedmonth.asm -l shiftedmonth.lst -o shiftedmonth.o
;
; Description:
; Calculates the shifted month from a given month.  This number can be used to calculate Easter sundays.
; The routine doesn't check for legal month numbers, it takes out the lower four bits to calculate with.
; returns shifted month number in rax or zero when dqMonth isn't a legal month number.
;
; in assembly language 'common way' rax = monthnumber
;
; The routine returns for:
;
;  AX <- month number       AX <- AX - 3        AND AX, 1111 0100 0000 1111           NOT AL                AND AL,AH               INC AL
;                                                                                                                              = shifted month number
; -------------------   -------------------     ---------------------------     -------------------     -------------------    ----------------------
; 0000 0000 0000 0001   1111 1111 1111 1110         1111 0100 0000 1110         0000 1011 0000 1110     0000 1011 0000 1010     0000 1011 0000 1011
; 0000 0000 0000 0010   1111 1111 1111 1111         1111 0100 0000 1111         0000 1011 0000 1111     0000 1011 0000 1011     0000 1011 0000 1100
; 0000 0000 0000 0011   0000 0000 0000 0000         0000 0000 0000 0000         1111 1111 0000 0000     1111 1111 0000 0000     1111 1111 0000 0001
; 0000 0000 0000 0100   0000 0000 0000 0001         0000 0000 0000 0001         1111 1111 0000 0001     1111 1111 0000 0001     1111 1111 0000 0010
; 0000 0000 0000 0101   0000 0000 0000 0010         0000 0000 0000 0010         1111 1111 0000 0010     1111 1111 0000 0010     1111 1111 0000 0011
; 0000 0000 0000 0110   0000 0000 0000 0011         0000 0000 0000 0011         1111 1111 0000 0011     1111 1111 0000 0011     1111 1111 0000 0100
; 0000 0000 0000 0111   0000 0000 0000 0100         0000 0000 0000 0100         1111 1111 0000 0100     1111 1111 0000 0100     1111 1111 0000 0101
; 0000 0000 0000 1000   0000 0000 0000 0101         0000 0000 0000 0101         1111 1111 0000 0101     1111 1111 0000 0101     1111 1111 0000 0110
; 0000 0000 0000 1001   0000 0000 0000 0110         0000 0000 0000 0110         1111 1111 0000 0110     1111 1111 0000 0110     1111 1111 0000 0111
; 0000 0000 0000 1010   0000 0000 0000 0111         0000 0000 0000 0111         1111 1111 0000 0111     1111 1111 0000 0111     1111 1111 0000 1000
; 0000 0000 0000 1011   0000 0000 0000 1000         0000 0000 0000 1000         1111 1111 0000 1000     1111 1111 0000 1000     1111 1111 0000 1001
; 0000 0000 0000 1100   0000 0000 0000 1001         0000 0000 0000 1001         1111 1111 0000 1001     1111 1111 0000 1001     1111 1111 0000 1010
;
; we see that the value in AL is the shifted month number of the month earlier present in AL.  The only action we have to perform is clearing all the unsignificant bits.
;
; Remark:
; The user needs to check if the month is a legal number. If not, the function returns a wrong number in RAX.

section .text
        global ShiftedMonth

ShiftedMonth:
	; month number is in RAX
	and		rax, 1111b		; take only lower 4 bits in concern
	; test month number
	dec		ax				; minus 3
	dec		ax
	dec		ax
	and		ax, 1111010000001111b
	not		ah
	and		al, ah	
	inc		al
	and		ax, 1111b		; only lower 4 bits are relevant for the result
	ret
