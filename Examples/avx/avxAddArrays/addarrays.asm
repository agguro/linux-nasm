;name: addarrays.asm
;
;description: add 2 arrays with the aid of AVX instructions
;
;source: https://www.physicsforums.com/insights/an-intro-to-avx-512-assembly-programming/

bits 64

global AddArrays

align 32

section .text

AddArrays:
    push	rbp
    mov	    rbp,rsp

    ;rdi : dest array
    ;rsi : pointer to array1
    ;rdx : pointer to array2

    vmovaps ymm0, [rsi]         ;load the first source array
    vmovaps ymm1, [rdx]         ;load the second source array
    vaddps  ymm2, ymm0,ymm1     ;add the two arrays
    vmovaps [rdi],ymm2          ;store the array sum

    mov	    rsp,rbp
    pop	    rbp
    ret
