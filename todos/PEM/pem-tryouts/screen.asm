; pem1 screen.asm

%include "pem1.inc"

%define SDL_INIT_VIDEO 0x00000020
%define SDL_SWSURFACE  0
%define SDL_FULLSCREEN -2147483648

BITS 64

section .bss
    
section .data

section .text

    mov     rdi, SDL_INIT_VIDEO
    call    SDL_Init
    cmp     rax, -1
    je      .quit                               ; init error
    
    mov     rdi, 1920
    mov     rsi, 24
    mov     rdx, SDL_SWSURFACE | SDL_FULLSCREEN
    call    SDL_SetVideoMode
    
    
    
    
.quit:
    xor     rdi, rdi
    mov     rax, SYS_EXIT
    syscall

