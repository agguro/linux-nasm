;name: threads.asm
;
;description: Pure assembly, library-free Linux threading demo
;             A demonstration of library-free, Pthreads-free threading in Linux with
;             pure x86_64 assembly. Thread stacks are allocated with the syscall mmap
;             and new threads are spawned with the clone syscall.
;             Synchronization is achieved with the x86 `lock` instruction prefix.
;
;source:      [Raw Linux Threads via System Calls](http://nullprogram.com/blog/2015/05/15/)

bits 64

%include "../threads/threads.inc"

global main

section .bss
;uninitialized read-write data 

section .data
;initialized read-write data
    count:  dq MAX_LINES
    hello:  db "Hello from main!",10,0
    hello1: db "Hello from thread 1!!",10,0
    hello2: db "Hello from thread 2!!",10,0

section .rodata
;read-only data

section .text

main:
;spawn a few threads
    mov	    rdi, threadfn1
    call    thread_create
    mov	    rdi, threadfn2
    call    thread_create

.loop:
    call    check_count
    mov	    rdi, hello
    call    puts
    mov	    rdi,0
    jmp	    .loop

threadfn1:
    call    check_count
    mov	    rdi, hello1
    call    puts
    jmp	    threadfn1

threadfn2:
    call    check_count
    mov	    rdi, hello2
    call    puts
    jmp	    threadfn2

; -- may not return
check_count:
    mov	    rax, -1
    lock    xadd [count], rax
    jl	    .exit
    ret
.exit:
    ;don't use 'ret', the program will behave strang!
    syscall exit,0                     ;exit program

puts:
    mov	    rsi, rdi
    mov	    rdx, -1
.count:
    inc	    rdx
    cmp	    byte[rsi + rdx], 0
    jne	    .count
    syscall write, stdout
    ret

thread_create:
    push    rdi
    call    stack_create
    lea	    rsi, [rax + STACK_SIZE - 8]
    pop	    qword [rsi]
    syscall clone, THREAD_FLAGS
    ret

stack_create:
    ;!!! r8=-1 and r9=0 when building this example with qmake (c/c++ libs)
    ;!!! otherwise the syscall mmap returns with an error (ENOMEM in my case)
    ;In a 'normal' build (native with nasm and ld) unitializing  r8 and r9 doesn't
    ;seem to give problems.  Must be the C-library
    mov     r8,-1
    mov     r9,0
    syscall mmap, 0, STACK_SIZE, PROT_WRITE | PROT_READ, MAP_ANONYMOUS | MAP_PRIVATE | MAP_GROWSDOWN

    ret
