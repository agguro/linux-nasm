; extern "C" void MmxMulSignedWord_(MmxVal a, MmxVal b, MmxVal* prod_lo, MmxVal* prod_hi)
;
; Description:  The following function performs a SIMD multiplication of
;               two packed signed word operands.  The resultant doubleword
;               products are saved to the specified memory locations.
;
; Name:			mmxaddition.asm
;
; Build:		g++ -c -m32 main.cpp -o main.o -std=c++11
;				nasm -f elf32 -o mmxmultiplication.o mmxmultiplication.asm
;				g++ -m32 -o mmxmultiplication mmxmultiplication.o main.o ../commonfiles/mmxval.o
;
; Source:		Modern X86 Assembly Language Programming p.160

global	MmxMulSignedWord

section .text

MmxMulSignedWord:
	%define	a		[ebp+8]
	%define	b		[ebp+16]
	%define	prod_lo	[ebp+24]
	%define	prod_hi	[ebp+28]
	
	push 	ebp
	mov 	ebp,esp

; Load arguments 'a' and 'b'
	movq 	mm0,a                   ;mm0 = 'a'
	movq 	mm1,b                   ;mm1 = 'b'

; Perform packed signed integer word multiplication
	movq 	mm2,mm0                 ;mm2 = 'a'
	pmullw 	mm0,mm1                 ;mm0 = product low result
	pmulhw 	mm1,mm2                 ;mm1 = product high result

; Unpack and interleave low and high products to form
; final packed doubleword products
	movq 		mm2,mm0             ;mm2 = product low result
	punpcklwd 	mm0,mm1             ;mm0 = low dword products
	punpckhwd	mm2,mm1             ;mm2 = high dword products

; Save the packed doubleword results
	mov 	eax,prod_lo             ;eax = pointer to 'prod_lo'
	mov 	edx,prod_hi             ;edx = pointer to 'prod_hi'
	movq 	[eax],mm0               ;save low dword products
	movq 	[edx],mm2               ;save high dword products

	pop 	ebp
	ret
