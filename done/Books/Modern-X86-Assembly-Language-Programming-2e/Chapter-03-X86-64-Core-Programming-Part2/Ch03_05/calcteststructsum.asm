;name        : calcteststructsum.asm
;description : Calculate the sum of a structure's values as a 64-bit integer
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" int64_t CalcTestStructSum_(const TestStruct* ts);
;              returns: Sum of structure's values as a 64-bit integer.


bits 64

struc TestStruct
    .Val8:  resb 1
    .Pad8:  resb 1
    .Val16: resw 1
    .Val32: resd 1
    .Val64: resq 1
endstruc

global CalcTestStructSum_
    
section .text

CalcTestStructSum_:
; in : rdi = ts ptr
; out : rax = sum of the structures members as 64 bit value

; Compute ts->Val8 + ts->Val16, note sign extension to 32-bits
    movsx   eax,byte [rdi+TestStruct.Val8]
    movsx   edx,word [rdi+TestStruct.Val16]
    add     eax,edx

; Sign extend previous result to 64 bits
    movsxd  rax,eax

; Add ts->Val32 to sum
    movsxd  rdx,[rdi+TestStruct.Val32]
    add     rax,rdx

; Add ts->Val64 to sum
    add     rax,[rdi+TestStruct.Val64]
    ret
