;name        : comparevcomisd.asm
;description : Compare Scalar Ordered Double-Precision Floating-Point Values and Set EFLAGS
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" void CompareVCOMISS_(float a, float b, bool* results)
;              extern "C" void CompareVCOMISD_(double a, double b, bool* results);

bits 64

global CompareVCOMISS_
global CompareVCOMISD_

section .text

CompareVCOMISS_:
; in : xmm0 = a
;      xmm1 = b
;      rdi = results ptr
; out : rdi contains results as boolean values

; Set result flags based on compare status
    vcomiss xmm0,xmm1
    setp    byte [rdi]              ;RFLAGS.PF = 1 if unordered
    jnp     .unordered
    xor     al,al
    mov     byte [rdi+1],al         ;Use default result values
    mov     byte [rdi+2],al
    mov     byte [rdi+3],al
    mov     byte [rdi+4],al
    mov     byte [rdi+5],al
    mov     byte [rdi+6],al
    jmp     .done

.unordered:

    setb    byte [rdi+1]            ;set byte if a < b
    setbe   byte [rdi+2]            ;set byte if a <= b
    sete    byte [rdi+3]            ;set byte if a == b
    setne   byte [rdi+4]            ;set byte if a != b
    seta    byte [rdi+5]            ;set byte if a > b
    setae   byte [rdi+6]            ;set byte if a >= b

.done:
    ret

CompareVCOMISD_:
; in = xmm0 = a
;      xmm1 = b
;      rdi = results ptr

; Set result flags based on compare status
    vcomisd xmm0,xmm1
    setp    byte [rdi]              ;RFLAGS.PF = 1 if unordered
    jnp     .unordered
    xor     al,al
    mov     byte [rdi+1],al         ;Use default result values
    mov     byte [rdi+2],al
    mov     byte [rdi+3],al
    mov     byte [rdi+4],al
    mov     byte [rdi+5],al
    mov     byte [rdi+6],al
    jmp     .done

.unordered:

    setb    byte [rdi+1]            ;set byte if a < b
    setbe   byte [rdi+2]            ;set byte if a <= b
    sete    byte [rdi+3]            ;set byte if a == b
    setne   byte [rdi+4]            ;set byte if a != b
    seta    byte [rdi+5]            ;set byte if a > b
    setae   byte [rdi+6]            ;set byte if a >= b

.done:
    ret
