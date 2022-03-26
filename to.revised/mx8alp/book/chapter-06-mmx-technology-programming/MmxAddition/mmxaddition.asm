; extern "C" bool MmxAdd(MmxVal a, MmxVal b, MmxAddOp op, MmxVal *c );
;
; Description:  The following function demonstrates use of the
;               padd* instructions.
;
; Returns:      c contains the calculated result.
;				eax returns true if success otherwise false
;
; Name:			mmxaddition.asm
;
; Build:		g++ -c -m32 main.cpp -o main.o -std=c++11
;				nasm -f elf32 -o mmxaddition.o mmxaddition.asm
;				g++ -m32 -o mmxaddition mmxaddition.o main.o ../commonfiles/mmxval.o
;
; Source:		Modern X86 Assembly Language Programming p.149

global	MmxAdd

section .data
align 4

; The order of the labels in the following table must match
; the enum that is defined in MmxAddition.cpp.

	%define	DWORD_SIZE	4

AddOpTable:	dd MmxAdd.mmxPaddb
			dd MmxAdd.mmxPaddsb
			dd MmxAdd.mmxPaddusb
			dd MmxAdd.mmxPaddw
			dd MmxAdd.mmxPaddsw
			dd MmxAdd.mmxPaddusw
			dd MmxAdd.mmxPaddd
AddOpTableCount equ ($ - AddOpTable) / DWORD_SIZE

section .text

MmxAdd:
	%define a		[ebp+8]
	%define b		[ebp+16]
	%define add_op	[ebp+24]
	%define c		[ebp+28]
	
	push	ebp
	mov		ebp,esp

; Make sure 'add_op' is valid
	mov		eax,add_op                      ;load 'add_op'
	cmp		eax,AddOpTableCount             ;compare to table count
	jae		.badAddOp                       ;jump if 'add_op' is invalid

; Load parameters and execute specified instruction
	movq	mm0,a                           ;load 'a'
	movq	mm1,b                           ;load 'b'
	jmp		[AddOpTable+eax*DWORD_SIZE]     ;jump to specified 'add_op'

.mmxPaddb:
	paddb	mm0,mm1                         ;packed byte addition using
	jmp		.saveResult                     ;wraparound

.mmxPaddsb:
	paddsb	mm0,mm1                         ;packed byte addition using
	jmp		.saveResult                     ;signed saturation

.mmxPaddusb:
	paddusb	mm0,mm1                         ;packed byte addition using
	jmp		.saveResult                     ;unsigned saturation

.mmxPaddw:
	paddw	mm0,mm1                         ;packed word addition using
	jmp		.saveResult                     ;wraparound

.mmxPaddsw:
	paddsw	mm0,mm1                         ;packed word addition using
	jmp		.saveResult                     ;signed saturation

.mmxPaddusw:
	paddusw	mm0,mm1                         ;packed word addition using
	jmp		.saveResult                     ;unsigned saturation

.mmxPaddd:
	paddd	mm0,mm1                         ;packed dword addition using
	jmp		.saveResult                     ;wraparound

.badAddOp:
	pxor	mm0,mm0                         ;return 0 if 'add_op' is bad
	pxor	mm2,mm2
	xor 	eax,eax							;return value false
	jmp		.done
; Move final result into edx:eax
.saveResult:
	; g++ doesn't return 64 bit values in edx:eax therefor the patch to store the value in c
	mov 	eax, 1							;return value true
	pshufw	mm2,mm0,01001110b               ;swap high & low dwords
.done:
	; save values of mmo and mm2 in c
	mov		edx,c
	movq	[edx],mm0
	movq	[edx+8],mm2
	emms                                    ;clear MMX state
	pop		ebp
	ret
