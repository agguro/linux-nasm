;name        : reversearray.asm
;description : reverse array y and copy in array x
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" int ReverseArray_(int* y, const int* x, int n);
;              returns: 0 = invalid n, 1 = success

bits 64

global ReverseArray_

section .text

ReverseArray_:
; in : rdi = y ptr
;      rsi = x ptr
;      edx = n
; out : rax = 0 : n <= 0 invalid
;       rax = 1 : success x = reversed of y

; Make sure n is valid
    xor     eax,eax             ;error return code
    test    edx,edx             ;is n <= 0?
    jle     InvalidArg          ;jump if n <= 0

; Initialize registers for reversal operation
    mov     ecx,edx             ;rcx = n
    lea     rsi,[rsi+rcx*4-4]   ;rsi = &x[n - 1]

; Save caller's RFLAGS.DF, then set RFLAGS.DF to 1
    pushfq                      ;save caller's RFLAGS.DF
    std                         ;RFLAGS.DF = 1

; Repeat loop until array reversal is complete
.repeat:
    lodsd                       ;eax = *x--
    mov     [rdi],eax           ;*y = eax
    add     rdi,4               ;y++
    dec     rcx                 ;n--
    jnz     .repeat

; Restore caller's RFLAGS.DF and set return code
    popfq                       ;restore caller's RFLAGS.DF
    mov     eax,1               ;set success return code

; Restore non-volatile registers and return
InvalidArg:
    ret
