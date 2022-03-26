;name          : speak.asm
;
;build         : nasm -felf64 -o speak.o -l speak.lst tick.asm
;                ld -s -m elf_x86_64 speak.o -o speak
;
;description   : example of named pipes in assembler, goes together with tick.asm
;
;source        : http://beej.us/guide/bgipc/output/html/multipage/fifos.html
;
;remark        : don't put more characters in the buffer than the size allows
;                You could get an error "Bad file descriptor"

[list -]
     %include "unistd.inc"
     %include "fcntl.inc"
[list +]

     %define FIFO_NAME "american_maid"
     
bits 64

section .bss

    fd:         resq  1                   ; file descriptor of named pipe
    buffer:     resb  300                 ; buffer to write to
    .length:    equ   $-buffer
    num         resq  1
    numbuffer:   
    .hundreds:  resb  1
    .tens:      resb  1
    .digits:    resb  1

section .rodata

    fifo_name:      db  FIFO_NAME, 0
    waiting:        db  "waiting for readers...", 10
    .length:        equ $-waiting
    gotreader:      db  "got a reader--type some stuff", 10
    .length:        equ $-gotreader
    wrotebytes:
    .part1:         db  "speak: wrote "
    .part1.length:  equ $-wrotebytes.part1
    .part2:         db  " bytes", 10
    .part2.length:  equ $-wrotebytes.part2
     
section .text

global _start
_start:
     ; create named pipe fifo-buffer
    syscall mknod, fifo_name, S_IFIFO | S_IRUSR | S_IWUSR, 0
    syscall write, stdout, waiting, waiting.length
    syscall open, fifo_name, O_WRONLY
    mov     qword[fd], rax
    syscall write, stdout, gotreader, gotreader.length
repeat:     
    syscall read, stdin, buffer, buffer.length
    dec     rax                     ; bytes read minus 1 for linefeed
    mov     qword[num], rax        
    mov     rdx, rax                ; bytes read in RDX
    and     rdx, rdx                ; bytes left to write?
    jz      exit                    ; nope, user just pressed ENTER, we can quit
    syscall write, qword[fd], buffer
    syscall write, stdout, wrotebytes.part1, wrotebytes.part1.length
    mov     rax, qword[num]
    mov     rbx, 10  
    xor     rdx, rdx
    div     rbx
    or      dl, "0"
    mov     byte[numbuffer.digits], dl
    xor     rdx, rdx
    div     rbx
    and     dl, dl
    or      dl, "0"
    mov     byte[numbuffer.tens], dl
    xor     rdx, rdx
    div     rbx
    or      dl, "0"
    mov     byte[numbuffer.hundreds], dl
    mov     rsi, numbuffer
    mov     rdx, 3
    mov     al, byte[numbuffer.hundreds]
    xor     al, "0"
    jnz     checktens
    inc     rsi
    dec     rdx
    mov     rcx, 1                               ; hundreds are zero
checktens:
    mov     al, byte[numbuffer.tens]
    xor     al, "0"
    jnz     printnum
    cmp     rcx, 1
    jne     printnum
    inc     rsi
    dec     rdx
printnum:
    syscall write, stdout
    syscall write, stdout, wrotebytes.part2, wrotebytes.part2.length
    jmp     repeat     
exit:
    syscall exit, 0
