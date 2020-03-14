; Name:     reversearray.asm
; Source:   Modern x86 Assembly Language Programming p.83

bits 32
global  ReverseArray_
section .text

; extern "C" bool ReverseArray_(int* y, const int* x, int n);
; Description:  The following function saves the elements of array 'x'
;               to array 'y' in reverse order.
; Returns       0 = Invalid 'n'
;               1 = Success

%define y   [ebp+8]
%define x   [ebp+12]
%define n   [ebp+16]

ReverseArray_:
    push    ebp
    mov     ebp,esp
    push    esi
    push    edi
    ; Load arguments, make sure 'n' is valid
    xor     eax,eax                 ;error return code
    mov     ecx,n                   ;ecx = 'n'
    test    ecx,ecx
    jle     .error                  ;jump if 'n' <= 0
    ; Initialize pointer to x[n - 1] and direction flag
    mov     esi, x
    lea     esi,[esi+ecx*4-4]       ;esi = &x[n - 1]
    pushfd                          ;save current direction flag
    std                             ;EFLAGS.DF = 1
    mov     edi, y                  ;edi = *y
    ; Repeat loop until array reversal is complete
.repeat:
    lodsd                           ;eax = *x--
    mov     [edi],eax               ;*y = eax
    add     edi,4                   ;y++
    dec     ecx                     ;n--
    jnz     .repeat
    popfd                           ;restore direction flag
    mov     eax,1                   ;set success return code
.error:  
    pop     edi
    pop     esi
    pop     ebp
    ret
