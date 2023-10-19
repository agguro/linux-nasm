;https://stackoverflow.com/questions/4812869/how-to-write-self-modifying-code-in-x86-assembly

section .bss
align 4096  ; page size on my machine. You can automate this process using
            ; libc's getpagesize() to make it bit more portable, but hey!,
            ; this is a minimum viable product!

exec: resb 0x10000




section .text

    mprotectoutput: db "mprotect output value %d\n", 0

global _start

_start:
    ; prologue
    push rbp
    mov  rbp, rsp

    ; body
    mov rdi, exec
    mov rsi, 10000
    mov rdx, 7
    
    call mprotect

    ; print output from the mprotect function. If other than 0, the code will
    ; segfault on `jmp rax`.
    mov rdi, mprotectoutput
    mov rsi, rax
    xor rax, rax
    
    call printf

    ; the subroutine will move 0x45 to rax, the return to the address
    ; in register r15

    ; set the return address
    mov  r15, back

    ; rdi will be a counter that counts how many program bytes were written
    xor rdi, rdi

    # 48 c7 c0 45 00 00 00  mov    $0x45,%rax

    mov rax, 0x0000000045c0c748
    mov qword [exec + rdi], rax
    add rdi, 7
    # 41 ff e7              jmp    *%r15

    mov eax, 0x00e7ff41
    mov dword [exec + rdi], eax
    add rdi, 3

    mov rax, exec
    jmp [rax]

back:
    ; epilogue
    mov  rsp, rbp
    pop  rbp
    ret

