; extern "C" bool MmxShift(MmxVal a, MmxShiftOp shift_op, int count, MmxVal* b);
;
; Description:  The following function demonstrates use of various MMX
;               shift instructions.
;
; Returns:      0 = invalid 'shift_op' argument
;               1 = success
;
; Name:			mmxshift.asm
;
; Build:		g++ -c -m32 main.cpp -o main.o -std=c++11
;				nasm -f elf32 -o mmxshift.o mmxshift.asm
;				g++ -m32 -o mmxshift mmxshift.o main.o ../commonfiles/mmxval.o
;
; Source:		Modern X86 Assembly Language Programming p.156

global MmxShift

section .data
align 4

; The order of the labels in the following table must correspond
; to the enum that is defined in MmxShift.cpp.

	%define	DWORD_SIZE	4
	
ShiftOpTable:	dd MmxShift.mmxPsllw
				dd MmxShift.mmxPsrlw
				dd MmxShift.mmxPsraw
				dd MmxShift.mmxPslld
				dd MmxShift.mmxPsrld
				dd MmxShift.mmxPsrad
ShiftOpTableCount equ ($ - ShiftOpTable) / DWORD_SIZE

section .text

MmxShift:
	%define a			[ebp+8]
	%define shift_op	[ebp+16]
	%define	count		[ebp+20]
	%define b			[ebp+24]
	
	push 	ebp
	mov 	ebp,esp

; Make sure 'shift_op' is valid
	xor 	eax,eax                           ;set error code
	mov 	edx,shift_op                      ;load 'shift_op'
	cmp 	edx,ShiftOpTableCount             ;compare against table count
	jae 	.badShiftOp                       ;jump if 'shift_op' invalid

; Jump to the specfied shift operation
	mov 	eax,1                             ;set success return code
	movq 	mm0,a                             ;load 'a'
	movd 	mm1,dword count                   ;load 'count' into low dword
	jmp 	[ShiftOpTable+edx*DWORD_SIZE]

.mmxPsllw:
	psllw	mm0,mm1                           ;shift left logical word
	jmp .saveResult

.mmxPsrlw:
	psrlw	mm0,mm1                           ;shift right logical word
	jmp .saveResult

.mmxPsraw:
	psraw	mm0,mm1                           ;shift right arithmetic word
	jmp .saveResult

.mmxPslld:
	pslld	mm0,mm1                           ;shift left logical dword
	jmp .saveResult

.mmxPsrld:
	psrld	mm0,mm1                           ;shift right logical dword
	jmp .saveResult

.mmxPsrad:
	psrad	mm0,mm1                           ;shift right arithmetic dword
	jmp .saveResult

.badShiftOp:
	pxor	mm0,mm0                           ;use 0 if 'shift_op' is bad
	jmp	.done
	
.saveResult:
	mov     edx,b                             ;edx = ptr to 'b'
	movq    [edx],mm0                         ;save shift result
	emms                                      ;clear MMX state
.done:
	pop ebp
	ret
