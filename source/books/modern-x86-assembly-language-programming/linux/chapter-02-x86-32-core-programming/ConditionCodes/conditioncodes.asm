; Name:     conditioncodes.asm
; Source:   Modern x86 Assembly Language Programming p.50

bits 32
global  SignedMinA_
global  SignedMaxA_
global  SignedMinB_
global  SignedMaxB_
global  SignedIsEQ_
section .text

%define a   [ebp+8]
%define b   [ebp+12]
%define c   [ebp+16]

; extern "C" int SignedMinA_(int a, int b, int c);
; Description:  Determines minimum of three signed integers
;               using conditional jumps.
; Returns       min(a, b, c)

SignedMinA_:
    push    ebp
    mov     ebp,esp
    mov     eax,a               ;eax = 'a'
    mov     ecx,b               ;ecx = 'b'
    ; Determine min(a, b)
    cmp     eax,ecx
    jle     .l1
    mov     eax,ecx             ;eax = min(a, b)
    ; Determine min(a, b, c)
.l1:
    mov     ecx,c               ;ecx = 'c'
    cmp     eax,ecx
    jle     .l2
    mov     eax,ecx             ;eax = min(a, b, c)
.l2:
    pop     ebp
    ret

; extern "C" int SignedMaxA_(int a, int b, int c);
;
; Description:  Determines maximum of three signed integers
;               using conditional jumps.
;
; Returns:      max(a, b, c)

SignedMaxA_:
    push    ebp
    mov     ebp,esp
    mov     eax,a               ;eax = 'a'
    mov     ecx,b               ;ecx = 'b'
    cmp     eax,ecx
    jge     .l1
    mov     eax,ecx             ;eax = max(a, b)
.l1:
    mov     ecx,c               ;ecx = 'c'
    cmp     eax,ecx
    jge     .l2
    mov     eax,ecx             ;eax = max(a, b, c)
.l2:
    pop     ebp
    ret

; extern "C" int SignedMinB_(int a, int b, int c);
;
; Description:  Determines minimum of three signed integers
;               using conditional moves.
;
; Returns       min(a, b, c)

SignedMinB_:
    push    ebp
    mov     ebp,esp
    mov     eax,a               ;eax = 'a'
    mov     ecx,b               ;ecx = 'b'
    ; Determine smallest value using the CMOVG instruction
    cmp     eax,ecx
    cmovg   eax,ecx             ;eax = min(a, b)
    mov     ecx,c               ;ecx = 'c'
    cmp     eax,ecx
    cmovg   eax,ecx             ;eax = min(a, b, c)
    pop     ebp
    ret

; extern "C" int SignedMaxB_(int a, int b, int c);
;
; Description:  Determines maximum of three signed integers
;               using conditional moves.
;
; Returns:      max(a, b, c)

SignedMaxB_:
    push    ebp
    mov     ebp,esp
    mov     eax,a               ;eax = 'a'
    mov     ecx,b               ;ecx = 'b'
    ; Determine largest value using the CMOVL instruction
    cmp     eax,ecx
    cmovl   eax,ecx             ;eax = max(a, b)
    mov     ecx,c               ;ecx = 'c'
    cmp     eax,ecx
    cmovl   eax,ecx             ;eax = max(a, b, c)
    pop     ebp
    ret

; extern "C" bool SignedIsEQ_(int a, int b);
;
; Description:  Compare a against b and set AL appropriately.
;
; Returns:      True if a = b, False if not equal.

SignedIsEQ_:
	push    ebp
    mov     ebp,esp
    xor     eax,eax
    mov     ecx,a
    cmp     ecx,b
    sete    al
    pop     ebp
    ret
