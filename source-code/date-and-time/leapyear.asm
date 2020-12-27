;name: leapyear.asm
;
;build: nasm -felf64 leapyear.asm -o leapyear.o
;
;description: determine if a year is a leapyear or not.
;             

bits 64

section .text

global leapyear
leapyear:
;leapyear
; in : rdi = uint year
; out : rax is true(1) or false(0)
    push    rbx             ;save used registers
    push    rcx
    push    rdx
    mov     rax,rdi
    xor     rcx,rcx         ;rcx = false(0), assume not leap
    test    rax,3           ;last two bits 0?
    jnz     .done           ;if not year is not divisible by 4 -> no leapyear
    inc     rcx             ;assume year is a leapyear, rcx = true(1)
    xor     rdx,rdx         ;prepare rdx for division
    mov     rbx,100         ;year / 100
    div     rbx
    and     rdx,rdx         ;remainder = 0?
    jnz     .done           ;not leap
    test    rax,3           ;multiples of 100 aren't leap years except if last two bits
                            ;are zero 0 (divisible by 4) then also divisible by 400
    jz      .done           ;yes, leap year
    dec     rcx             ;no, not leap year, rcx = false(0)
.done:
    mov     rax,rcx         ;mov result in RAX
    pop     rdx
    pop     rcx
    pop     rbx
    ret
