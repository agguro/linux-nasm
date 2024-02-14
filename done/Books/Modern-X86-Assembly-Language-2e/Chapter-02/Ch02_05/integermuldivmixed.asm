;name        : integermuldivmixed.asm
;description : mixed integer multiplication and division
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" int64_t IntegerMul_(int8_t a, int16_t b, int32_t c, int64_t d, int8_t e, int16_t f, int32_t g, int64_t h);
;            : extern "C" int UnsignedIntegerDiv_(uint8_t a, uint16_t b, uint32_t c, uint64_t d, uint8_t e, uint16_t f, uint32_t g, uint64_t h, uint64_t* quo, uint64_t* rem);

bits 64

global IntegerMul_
global UnsignedIntegerDiv_

section .text

IntegerMul_:
; in : dil = int8_t a
;      si = int16_t b
;      edx = int32_t c
;      rcx = int64_t d
;      r8b = int8_t e
;      r9w = int16_t f
;      [rsp+8] = int32_t g
;      [rsp+16] = int64_t h

; Calculate a * b * c * d
    movsx   rax,dil                 ;rax = sign_extend(a)
    movsx   rsi,si                  ;rsi = sign_extend(b)
    imul    rax,rsi                 ;rax = a * b
    movsxd  rdx,edx                 ;rdx = sign_extend(c)
    imul    rcx,rdx                 ;rcx = c * d

    imul    rax,rcx                 ;rax = a * b * c * d

; Calculate e * f * g * h
    movsx   rcx,r8b                 ;rcx = sign_extend(e)
    movsx   r9,r9w                  ;r9 = sign_extend(f)
    imul    rcx,r9                  ;rcx = e * f
    movsxd  rdx,dword[rsp+8]        ;rdx = sign_extend(g)
    imul    rdx,qword[rsp+16]       ;rdx = g * h

    imul rcx,rdx                    ;rcx = e * f * g * h

; Compute the final product
    imul rax,rcx                    ;rax = final product
    ret

UnsignedIntegerDiv_:
; in : dil = a
;      si  = b
;      edx = c
;      rcx = d
;      r8b = e
;      r9w = f
;      [rsp+8]  = g
;      [rsp+16] = h
;      [rsp+24] = quo ptr
;      [rsp+32] = rem ptr
; out : rax = return code

; Calculate a + b + c + d
    movzx   rax,dil                 ;rax = zero_extend(a)
    movzx   rsi,si                  ;rsi = zero_extend(b)
    add     rax,rsi                 ;rax = a + b
    ;following instructio seems superfluous but 32 bit
    ;instruction running on 64 bit clears the upper 32
    ;bits from the register running on.
    mov     edx,edx                 ;rdx = zero_extend(c)
    add     rdx,rcx                 ;rdx = c + d
    add     rax,rdx                 ;rax = a + b + c + d
    ;clear rdx for later division
    xor     rdx,rdx                 ;rdx:rax = a + b + c + d

; Calculate e + f + g + h
    movzx   r8,r8b                  ;r8 = zero_extend(e)
    movzx   r9,r9w                  ;r9 = zero_extend(f)
    add     r8,r9                   ;r8 = e + f
    mov     r10d,dword[rsp+8]       ;r10 = zero_extend(g)
    add     r10,qword[rsp+16]       ;r10 = g + h;
    add     r8,r10                  ;r8 = e + f + g + h
    jnz     DivOK                   ;jump if divisor is not zero

    xor     eax,eax                 ;set error return code
    jmp     Done

; Calculate (a + b + c + d) / (e + f + g + h)

DivOK:
    div     r8                      ;unsigned divide rdx:rax / r8
    mov     rcx,[rsp+24]
    mov     [rcx],rax               ;save quotient
    mov     rcx,[rsp+32]
    mov     [rcx],rdx               ;save remainder

    mov     eax,1                   ;set success return code

Done:
    ret
