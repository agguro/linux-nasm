; name        : avx_addArrays.asm
;
; description : add 2 arrays with AVX instructions
;
; build       : nasm -felf64 -Fdwarf -o avx_addArrays.o avx_addArrays.asm 
;
; C calling   : extern "C" void avx_addArrays(float dest[], float arr1[], float arr2[]);

bits 64

global avx_addArrays

align 16

section .text

avx_addArrays:

    push	rbp
    mov	    rbp,rsp

    ;rdi : dest array
    ;rsi : pointer to array1
    ;rdx : pointer to array2

    vmovaps xmm0, [rsi]         ;load the first source array
    vmovaps xmm1, [rdx]         ;load the second source array
    vaddps  xmm2, xmm0,xmm1     ;add the two arrays
    vmovaps [rdi],xmm2          ;store the array sum

    mov	    rsp,rbp
    pop	    rbp
    ret
