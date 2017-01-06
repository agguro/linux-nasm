; Name          : tick.asm
;
; Build         : nasm -felf64 -o tick.o -l tick.lst tick.asm
;                 ld -s -m elf_x86_64 tick.o -o tick
;
; Description   : example of named pipes in assembler, goes together with speak.asm
;
; Source        : http://beej.us/guide/bgipc/output/html/multipage/fifos.html
;
; Remark:
; there is no error handling in this example

[list -]
     %include "unistd.inc"
     %include "sys/stat.inc"
[list +]

bits 64

%include "section.bss.inc"                                      ; common definitions in one file

section .data

     fifo_name:     db        FIFO_NAME, 0
     waiting:       db        "waiting for writers...", 10
     .length:       equ       $-waiting
     gotwriter:     db        "got a writer", 10
     .length:       equ       $-gotwriter
     readbytes:
     .part1:        db        "tick: read "
     .part1.length: equ       $-readbytes.part1
     .part2:        db        ' bytes: "'
     .part2.length: equ       $-readbytes.part2
     .part3:        db        '"', 10
     .part3.length: equ       $-readbytes.part3
     
section .text
     global _start
     
_start:
     syscall   mknod, fifo_name, S_IFIFO | S_IRUSR | S_IWUSR, 0
     syscall   write, stdout, waiting, waiting.length
     syscall   open, fifo_name, O_RDONLY
     mov       qword[fd], rax
     syscall   write, stdout, gotwriter, gotwriter.length
     
repeat:     
     syscall   read, qword[fd], buffer, buffer.length
     mov       qword[num], rax
     syscall   write, stdout, readbytes.part1, readbytes.part1.length

     ; convert bytes read to decimal and print
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
     syscall   write, stdout, readbytes.part2, readbytes.part2.length
     syscall   write, stdout, buffer, qword[num]
     syscall   write, stdout, readbytes.part3, readbytes.part3.length
     ; did we wrote any bytes?
     mov       rax, qword[num]
     and       rax, rax
     jnz       repeat
     syscall   exit, 0
