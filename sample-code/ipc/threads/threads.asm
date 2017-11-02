; name: threads.asm
;
; description:  Pure assembly, library-free Linux threading demo
;               A demonstration of library-free, Pthreads-free threading in Linux with
;               pure x86_64 assembly. Thread stacks are allocated with the syscall mmap
;               and new threads are spawned with the clone syscall.
;               Synchronization is achieved with the x86 `lock` instruction prefix.
;
; build:        nasm -felf64 -Fdwarf -g -l threads.lst threads.asm -o threads.o
;               ld -g -melf_x86_64 threads.o -o threads  
;
; source:       [Raw Linux Threads via System Calls](http://nullprogram.com/blog/2015/05/15/)

bits 64

%include "threads.inc"

global _start

section .bss

section .data
    count:	dq MAX_LINES
    hello:	db `Hello from \e[93;1mmain\e[0m!\n\0`
    hello1:	db `Hello from \e[91;1mthread 1\e[0m!\n\0`
    hello2:	db `Hello from \e[91;1mthread 2\e[0m!\n\0`
    
section .text

_start:
; Spawn a few threads
    mov	    rdi, threadfn1
    call    thread_create
    mov	    rdi, threadfn2
    call    thread_create

.loop:
    call    check_count
    mov	    rdi, hello
    call    puts
    mov	    rdi, 0
    jmp	    .loop

; void threadfn1(void)
threadfn1:
    call    check_count
    mov	    rdi, hello1
    call    puts
    jmp	    threadfn1

; void threadfn2(void)
threadfn2:
    call    check_count
    mov	    rdi, hello2
    call    puts
    jmp	    threadfn2

; void check_count(void) -- may not return
check_count:
    mov	    rax, -1
    lock    xadd [count], rax
    jl	    .exit
    ret
.exit:
    syscall exit, 0

; void puts(char *)
puts:
    mov	    rsi, rdi
    mov	    rdx, -1
.count:
    inc	    rdx
    cmp	    byte[rsi + rdx], 0
    jne	    .count
    syscall write, stdout
    ret

; long thread_create(void (*)(void))
thread_create:
    push    rdi
    call    stack_create
    lea	    rsi, [rax + STACK_SIZE - 8]
    pop	    qword [rsi]
    syscall clone, THREAD_FLAGS
    ret

; void *stack_create(void)
stack_create:
    syscall mmap, 0, STACK_SIZE,PROT_WRITE | PROT_READ,MAP_ANONYMOUS | MAP_PRIVATE | MAP_GROWSDOWN
    ret
