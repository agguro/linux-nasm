; Name          : speak.asm
;
; Build         : nasm -felf64 -o speak.o -l speak.lst tick.asm
;                 ld -s -m elf_x86_64 speak.o -o speak
;
; Description   : example of named pipes in assembler, goes together with tick.asm
;
; Source        : http://beej.us/guide/bgipc/output/html/multipage/fifos.html
;
; Remark:
; there is no error handling in this example
; don't put more characters in the buffer than the size allows - You could get an error "Bad file descriptor"

[list -]
     %include "unistd.inc"
     %include "fcntl.inc"
[list +]

bits 64

%include "section.bss.inc"                                      ; common definitions in one file

section .data

     fifo_name:     db        FIFO_NAME, 0
     waiting:       db        "waiting for readers...", 10
     .length:       equ       $-waiting
     gotreader:     db        "got a reader--type some stuff", 10
     .length:       equ       $-gotreader
     wrotebytes:
     .part1:        db        "speak: wrote "
     .part1.length: equ       $-wrotebytes.part1
     .part2:        db        " bytes", 10
     .part2.length: equ       $-wrotebytes.part2
     
section .text
     global _start

_start:
     ; create named pipe fifo-buffer
     syscall   mknod, fifo_name, S_IFIFO | S_IRUSR | S_IWUSR, 0
     syscall   write, stdout, waiting, waiting.length
     syscall   open, fifo_name, O_WRONLY
     mov       QWORD[fd], rax
     syscall   write, stdout, gotreader, gotreader.length
     
repeat:     
     syscall   read, stdin, buffer, buffer.length
     dec       rax                                ; bytes read minus 1 for linefeed
     mov       qword[num], rax
         
     mov       rdx, rax                           ; bytes read in RDX
     and       rdx, rdx                           ; bytes left to write?
     jz        exit                               ; nope, user just pressed ENTER, we can quit
     syscall   write, qword[fd], buffer
     syscall   write, stdout, wrotebytes.part1, wrotebytes.part1.length
     
     mov       rax, qword[num]
     mov       rbx, 10  
     xor       rdx, rdx
     div       rbx
     or        dl, "0"
     mov       byte[numbuffer.digits], dl
     xor       rdx, rdx
     div       rbx
     and       dl, dl
     or        dl, "0"
     mov       byte[numbuffer.tens], dl
     xor       rdx, rdx
     div       rbx
     or        dl, "0"
     mov       byte[numbuffer.hundreds], dl
     
     mov       rsi, numbuffer
     mov       rdx, 3
     mov       al, byte[numbuffer.hundreds]
     xor       al, "0"
     jnz       checktens
     inc       rsi
     dec       rdx
     mov       rcx, 1                                            ; hundreds are zero
checktens:
     mov       al, byte[numbuffer.tens]
     xor       al, "0"
     jnz       printnum
     cmp       rcx, 1
     jne       printnum
     inc       rsi
     dec       rdx
     
printnum:
     syscall   write, stdout
     syscall   write, stdout, wrotebytes.part2, wrotebytes.part2.length
     jmp       repeat
     
exit:
     syscall   exit, 0
