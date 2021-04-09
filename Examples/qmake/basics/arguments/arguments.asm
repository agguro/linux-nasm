;name: arguments.asm
;
;description: Read the number of arguments and if any write it to stdout.
;
;build: nasm -felf64 arguments.asm -o arguments.o
;   ld -melf_x86_64 arguments.o -o arguments

bits 64

    %include "../../../qmake/basics/arguments/arguments.inc"

global main
    crlf:       equ     10

section .bss
                      ;reserve 20 bytes as a buffer
    argc:       resq    1
    progname:   resq    1
    argv:       resq    1
    envp:       resq    1
    argc_dec:   resq    1

section .data
    buffer:     times  20   db  0
    dymmy:      times  16   db 'C'

section .rodata

    msgArgc:    db  "argc        : "
    .len:       equ $-msgArgc
    msgProg:    db  "Programname : "
    .len:       equ $-msgProg
    msgArgv:    db  "argv[]      : "
    .len:       equ $-msgArgv
    eol:        db  10
    .len:       equ $-eol

section .text

main:
    push    rbp
    mov     rbp,rsp
    sub     rsp, 0x20

    ;save argc
    mov    [argc],rdi

    ;get pointer to argv
    mov    [argv],rsi                   ;get start of argv

    ;get pointer to programname
    mov    rax,[argv]                   ;read pointer to argv[]
    mov    rax,[rax]                    ;read value of argv[0]
    mov    [progname],rax               ;start af asciiz path + programname

    ;adjust argv to point to argument list instead of programname
    mov     rax,[argv]                  ;argv[0] is programname
    add     rax,8                       ;read pointer to argv[1]
    mov     [argv],rax                  ;save pointer, beware that the value can be zero if no args are on the commandline

    ;save pointer to envp on stack
    mov    rax,[argv]                   ;read first pointer to argv[]
    mov    rdx,[argc]                   ;get number of items in array argv[]
    shl    rdx,3                        ;multiply by 8
    add    rax,rdx                      ;add to argv[]
    mov    rax,[rax]                    ;read pointer to envp[]
    mov    [envp],rax                   ;start of envp[]

    ;write message and argc as unsigned integer to stdout
    syscall write,stdout,msgArgc,msgArgc.len

    ;convert argc to decimal ASCII return string pointer in rax
    mov     rdi,[argc]                  ;value of argc in rdi
    dec     rdi                         ;minus one for programname
    call    hex2dec_ascii               ;convert to stringz
    mov     [argc_dec],rax              ;save stringz pointer
    ;calculate length of stringz at rdi
    mov     rdi,rax
    call    StringLength
    mov     rdx,rax                     ;save stringlength
    ;print this string
    syscall write,stdout,[argc_dec],rdx
    ;print eol
    syscall write,stdout,eol,eol.len


    syscall write,stdout,eol,eol.len
    ;write message and the programname to stdout
    syscall write,stdout,msgProg,msgProg.len

    syscall write,stdout,eol,eol.len
    ;write message and all arguments to STDOUT
    syscall write,stdout,msgArgv,msgArgv.len

    syscall write,stdout,eol,eol.len

jmp Exit
    ;convert the value of argc in unsigned integer ASCII
    mov     rdi,[argc]                  ;argc in rdi
    dec	    rdi                         ;number of arguments minus programname
    call    hex2dec_ascii                     ;convert RDI into unsigned integer ASCII

    ;write string at rdi to stdout
    mov     rdi,rax                     ;stringz pointer in rdi
    call    Write.string                ;write the unsigned integer
    mov     rdi,crlf                    ;end of line
    call    Write.char



    call    Write.string
    pop     rsi                         ;get programname from stack
    call    Write.string                ;write the programname
    mov     al,crlf                     ;end of line
    call    Write.char
    call    Write.string
    cmp     rcx, 0                      ;are there arguments?
    je      .endOfArgs                  ;no arguments, nothing to show
.nextArg:
    pop     rsi
    call    Write.string
    cmp     rcx,1
    je      .endOfArgs
    mov     al,' '
    call    Write.char
.noSpace:
    loop    .nextArg

.endOfArgs:
    mov     al,crlf
    call    Write.char
Exit:
    mov     rbp,rsp
    ret

Write:
    ;write a stringz at rdi to stdout
.string:
;first calculate the length
    call    StringLength
    ret

    cld                                 ;make sure we count upwards in memory
    lodsb                               ;load byte from RSI:RAX in AL
    and     al,al                       ;if zero then end of ASCIIZ string
    je      .done
    mov     rdi,rax
    call    Write.char
    jmp     .string
    ;write a char in dil to stdout
.char:
    mov     rax,rdi
    push    rdi
    push    rsi
    push    rcx
    mov     rsi,buffer
    mov     byte [buffer],al
    syscall write,stdout,buffer,1
    xor     rdx, 1
    jnz     .done
    mov     byte[rsi],0
    pop     rcx
    pop     rsi                         ;restore used registers
    pop     rdi
.done:
    ret

hex2dec_ascii:
    mov     rax,rdi
    mov     byte[buffer+19],0
    mov     rsi,buffer+18
    mov     rbx,10
.repeat:
    xor     rdx,rdx                     ;the remainder
    div     rbx                         ;divide RAX by 10, remainder in RDX
    or      dl,0x30                     ;convert to ASCII
    mov     byte[rsi],dl                ;remainder in byte pointed to by RSI
    and     rax, rax                    ;quotient = 0?
    je      .done                       ;yes, stop converting
    dec     rsi
    jmp	    .repeat
.done:
    mov     rax,rsi
    ret

StringLength:
;calculates the length of an asciiz string at rdi, return length in rax
    push    rcx
    xor     al,al
    xor     rcx,rcx
    dec     rcx
    repne   scasb
    sub     rdi,rcx
    mov     rax,rdi
    pop     rcx
    ret
