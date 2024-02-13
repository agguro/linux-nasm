;name        : integerlogical.asm
;description : Calculate (((a & b) | c ) ^ d) + g_Val1
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" int IntegerShift_(unsigned int a, unsigned int count, unsigned int* a_shl, unsigned int* a_shr);
;returns     : 0 = error (count >= 32), 1 = success

bits 64

global IntegerShift_

section .text

IntegerShift_:
; in : edi = a
;      esi = count
;      rdx = a_shl ptr
;      rcx = a_shr ptr
; out : eax = 0 = error (count >= 32)
;             1 = success
    xor     eax,eax         ;set return code in case of error
    xchg    rsi,rcx         ;exchange contents of rsi (count) and rcx (a_shr)

    cmp     ecx,31          ;compare count against 31
    ja      InvalidCount    ;jump if count > 31

    mov     eax,edi         ;eax = a
    shl     eax,cl          ;eax = a << count;
    mov     [rdx],eax       ;save result (in a_shl)

    shr     edi,cl          ;edi = a >> count
    mov     [rsi],edi       ;save result (in a_shr)

    mov     eax,1           ;set success return code

InvalidCount:
    ret                     ;return to caller
