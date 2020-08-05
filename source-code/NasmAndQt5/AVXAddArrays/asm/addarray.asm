;name: addarray.asm
;
;description: add 2 arrays with the aid of AVX instructions
;
;source https://www.physicsforums.com/insights/an-intro-to-avx-512-assembly-programming/

bits 64

%include "../Driver/inc/addarray.inc"

global AddArray
align 64

section .rodata
    
section .text

AddArray:
	push	rbp
	mov	rbp,rsp

	;rdi : dest array
	;rsi : pointer to array1
	;rdx : pointer to array2
	
	vmovaps ymm0, [rsi] ; Load the first source array
	vmovaps ymm1, [rdx] ; Load the second source array
	vaddps ymm2, ymm0,ymm1 ; Add the two arrays
	vmovaps [rdi],ymm2 ; Store the array sum

	mov	rsp,rbp
	pop	rbp
	ret
