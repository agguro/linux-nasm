; tick.asm
;
; example of named pipes in assembler, goes together with speak.asm
; source: http://beej.us/guide/bgipc/output/html/multipage/fifos.html
;         converted from C
;
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
     ; create named pipe fifo-buffer
     mov       rdi, fifo_name
     mov       rsi, S_IFIFO | S_IRUSR | S_IWUSR                  ; type = FIFO, read write by user
     xor       rdx, rdx
     syscall   mknod
     
     ; print message waiting for writers
     mov       rsi, waiting
     mov       rdx, waiting.length
     mov       rdi, stdout
     syscall   write
     
     ; open named pipe in read only mode, named pipe is in blockmode thus waiting for a writer
     mov       rdi, fifo_name
     mov       rsi, O_RDONLY
     syscall   open
     mov       QWORD[fd], rax
     
     ; writer found, inform user
     mov       rsi, gotwriter
     mov       rdx, gotwriter.length
     mov       rdi, stdout
     syscall   write
     
repeat:     
     ; read from the named-pipe
     mov       rdi, QWORD[fd]
     mov       rsi, buffer
     mov       rdx, buffer.length
     syscall   read
     mov       QWORD[num], rax
     
     ; write num of bytes written
     mov       rsi, readbytes.part1
     mov       rdx, readbytes.part1.length
     mov       rdi, stdout
     syscall   write

     ; convert bytes read to decimal and print
     mov       rax, QWORD[num]
     mov       rbx, 10  
     xor       rdx, rdx
     div       rbx
     or        dl, "0"
     mov       BYTE[numbuffer.digits], dl
     xor       rdx, rdx
     div       rbx
     and       dl, dl
     or        dl, "0"
     mov       BYTE[numbuffer.tens], dl
     xor       rdx, rdx
     div       rbx
     or        dl, "0"
     mov       BYTE[numbuffer.hundreds], dl
     
     mov       rsi, numbuffer
     mov       rdx, 3
     mov       al, BYTE[numbuffer.hundreds]
     xor       al, "0"
     jnz       checktens
     inc       rsi
     dec       rdx
     mov       rcx, 1                                            ; hundreds are zero
checktens:
     mov       al, BYTE[numbuffer.tens]
     xor       al, "0"
     jnz       printnum
     cmp       rcx, 1
     jne       printnum
     inc       rsi
     dec       rdx
printnum:
     mov       rdi, stdout
     syscall   write

     ; continue output
     mov       rsi, readbytes.part2
     mov       rdx, readbytes.part2.length
     mov       rdi, stdout
     syscall   write

     ; write the buffer to screen
     mov       rdx, QWORD[num]                           ; bytes read in rdx
     mov       rsi, buffer
     mov       rdi, stdout
     syscall   write

     mov       rsi, readbytes.part3
     mov       rdx, readbytes.part3.length
     mov       rdi, stdout
     syscall   write
     
     ; did we wrote any bytes?
     mov       rax, QWORD[num]
     and       rax, rax
     jnz       repeat
     
     xor       rdi, rdi
     syscall   exit
     