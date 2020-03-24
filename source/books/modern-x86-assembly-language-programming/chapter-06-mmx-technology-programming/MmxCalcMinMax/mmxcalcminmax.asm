; extern "C" bool MmxCalcMinMax_(Uint8* x, int n, Uint8* x_min, Uint8* x_max);
;
; Description:  The following function calculates the minimum and 
;               maximum values of an array of 8-bit unsigned integers.
;
; Returns:      0 = invalid 'n'
;               1 = success
;
; Name:			mmxcalcminmax.asm
;
; Build:		g++ -c -m32 main.cpp -o main.o -std=c++11
;				nasm -f elf32 -o mmxcalcminmax.o mmxcalcminmax.asm
;				g++ -m32 -o mmxcalcminmax mmxcalcminmax.o main.o
;
;
; Source:		Modern X86 Assembly Language Programming p.164

global MmxCalcMinMax_
extern NMIN_               ;Minimum size of array

section .data

StartMinVal dq 0ffffffffffffffffh    ;Initial packed min value
StartMaxVal dq  0000000000000000h    ;Initial packed max value

section .text

MmxCalcMinMax_:
	push	ebp
	mov 	ebp,esp

; Make sure 'n' is valid
	xor 	eax,eax               ;set error return code
	mov 	ecx,[ebp+12]          ;ecx = 'n'
	cmp 	ecx,[NMIN_]
	jl 		.done                 ;jump if n < NMIN
	test 	ecx,0fh
	jnz 	.done                 ;jump if n & 0x0f != 0

; Initialize
	shr 	ecx,4                 ;ecx = number of 16-byte blocks
	mov 	edx,[ebp+8]           ;edx = pointer to 'x'
	movq 	mm4,[StartMinVal]
	movq 	mm6,mm4               ;mm6:mm4 current min values
	movq 	mm5,[StartMaxVal]
	movq 	mm7,mm5               ;mm7:mm5 current max values

; Scan array for min & max values
.@1:
	movq 	mm0,[edx]             ;mm0 = packed 8 bytes
	movq 	mm1,[edx+8]           ;mm1 = packed 8 bytes
	pminub 	mm6,mm0               ;mm6 = updated min values
	pminub 	mm4,mm1               ;mm4 = updated min values
	pmaxub 	mm7,mm0               ;mm7 = updates max values
	pmaxub 	mm5,mm1               ;mm5 = updates max values
	add 	edx,16                ;set edx to next 16 byte block
	dec 	ecx
	jnz 	.@1                   ;jump if more data remains
; Determine final minimum value
	pminub 	mm6,mm4               ;mm6[63:0] = final 8 min vals
	pshufw 	mm0,mm6,00001110b     ;mm0[31:0] = mm6[63:32]
	pminub 	mm6,mm0               ;mm6[31:0] = final 4 min vals
	pshufw 	mm0,mm6,00000001b     ;mm0[15:0] = mm6[31:16]
	pminub 	mm6,mm0               ;mm6[15:0] = final 2 min vals
	pextrw 	eax,mm6,0             ;ax = final 2 min vals
	cmp 	al,ah
	jbe 	.@2                   ;jump if al <= ah
	mov 	al,ah                 ;al = final min value
.@2:
	mov 	edx,[ebp+16]
	mov 	[edx],al              ;save final min value

; Determine final maximum value
	pmaxub 	mm7,mm5               ;mm7[63:0] = final 8 max vals
	pshufw 	mm0,mm7,00001110b     ;mm0[31:0] = mm7[63:32]
	pmaxub 	mm7,mm0               ;mm7[31:0] = final 4 max vals
	pshufw 	mm0,mm7,00000001b     ;mm0[15:0] = mm7[31:16]
	pmaxub 	mm7,mm0               ;mm7[15:0] = final 2 max vals
	pextrw 	eax,mm7,0             ;ax = final 2 max vals
	cmp 	al,ah
	jae 	.@3                   ;jump if al >= ah
	mov 	al,ah                 ;al = final max value
.@3:
	mov		edx,[ebp+20]
	mov		[edx],al              ;save final max value
; Clear MMX state and set return code
	emms
	mov		eax,1
.done:
	pop		ebp
	ret
