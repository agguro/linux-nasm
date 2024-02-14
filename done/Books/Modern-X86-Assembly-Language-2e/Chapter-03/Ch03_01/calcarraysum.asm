;name        : calcarraysum.asm
;description : Calculates the sum of the elements in array x
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" int CalcArraySum_(const int* x, int n)
;              returns: Sum of elements in array x

bits 64

global CalcArraySum_
    
section .text

CalcArraySum_:
; in : rdi = x ptr
;      esi = n
; out : sum of the elements in array x

; Initialize sum to zero
    xor     eax,eax                         ;sum = 0

; Make sure 'n' is greater than zero
    cmp     esi,0
    jle     InvalidCount                    ;jump if n <= 0

; Sum the elements of the array
.repeat:
    add     eax,[rdi]                       ;add next element to total (sum += *x)
    add     rdi,4                           ;set pointer to next element (x++)
    dec     esi                             ;adjust counter (n -= 1)
    jnz     .repeat                         ;repeat if not done

InvalidCount:
    ret
