; Name:     calcarraysum.asm
; Source:   Modern x86 Assembly Language Programming p.56

bits 32
global  CalcArraySum_
section .text

; extern "C" int CalcArraySum_(const int* x, int n);
; Description:  This function sums the elements of a signed
;               integer array.

%define x    [ebp+8]
%define n    [ebp+12]

CalcArraySum_:
    push    ebp
    mov     ebp,esp
    ; Load arguments and initialize sum
    mov     edx,x                   ;edx = 'x'
    mov     ecx,n                   ;ecx = 'n'
    xor     eax,eax                 ;eax = sum
    ; Make sure 'n' is greater than zero
    cmp     ecx,0
    jle     .invalidCount
    ; Calculate the array element sum
.l1:
    add     eax,[edx]               ;add next element to sum
    add     edx,4                   ;set pointer to next element
    dec     ecx                     ;adjust counter
    jnz     .l1                     ;repeat if not done
.invalidCount:
    pop     ebp
    ret
