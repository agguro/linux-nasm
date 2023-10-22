%include "unistd.inc"

global _start
extern tbytehex2bcd

section .data
    fpuval1:    dq  1234567890
    fpuval2:    dq  -123456789012345678
    fpuval3:    dq  45
    fpuval4:    dq  -2562

    bcdval:    times 10 db 0
    
    cr:             db  10

    asciinumber:    times 21 db 0
    
section .text

_start:

    mov     rdi,fpuval1
    mov     rsi,bcdval
    call    tbytehex2bcd
    mov     rdi,bcdval
    mov     rsi,asciinumber
    call    bcd2asc
    syscall write,stdout,asciinumber,rax
    syscall write,stdout,cr,1

    mov     rdi,fpuval2
    mov     rsi,bcdval
    call    tbytehex2bcd
    mov     rdi,bcdval
    mov     rsi,asciinumber
    call    bcd2asc
    syscall write,stdout,asciinumber,rax
    syscall write,stdout,cr,1

    mov     rdi,fpuval3
    mov     rsi,bcdval
    call    tbytehex2bcd
    mov     rdi,bcdval
    mov     rsi,asciinumber
    call    bcd2asc
    syscall write,stdout,asciinumber,rax
    syscall write,stdout,cr,1

    mov     rdi,fpuval4
    mov     rsi,bcdval
    call    tbytehex2bcd
    mov     rdi,bcdval
    mov     rsi,asciinumber
    call    bcd2asc
    syscall write,stdout,asciinumber,rax
    syscall write,stdout,cr,1

	syscall exit,0

bcd2asc:
    ;clear output buffer
    xor     rax,rax
    mov     qword[rsi],rax          ;clear the buffer
    mov     word[rsi+8],ax
    mov     r8,rsi
    ;load BCD
    mov     rax,qword[rdi+2]
    mov     dx,word[rdi]
    ;move last bytes in place
    shl     edx,8
    ;first byte in AL and + in [RSI]
    rol     rax,8
    mov     byte[rsi],"+"
    rol     al,2                    ;adjustment for -
    add     byte[rsi],al
    xor     al,al                   ;clear AL
    xor     rcx,rcx                 ;set count to zero  
.leadingzero:
    inc     rcx                     ;count + 1    
    cmp     rcx,5                   ;2 digits processed?
    jne     .skip1                  ;no, skip copy of DL to AL
    or      rax,rdx                 ;last digits in RAX
.skip1:
    cmp     rcx,19                  ;all digits processed?
    je      .exit                   ;yes stop processing
    rol     rax,4
    cmp     al,0
    je      .leadingzero
.significant:
    inc     rsi                     ;move to next position in buffer
    or      al,"0"
    mov     byte[rsi],al
    xor     al,al
    inc     rcx                     ;count + 1    
    cmp     rcx,5                   ;2 digits processed?
    jne     .skip2                  ;no, skip copy of DL to AL
    or      rax,rdx                 ;last digits in RAX
.skip2:
    cmp     rcx,19                  ;all digits processed?
    je      .exit                   ;yes stop processing
    rol     rax,4
    jmp     .significant
.exit:
    inc     rsi                     ;subtract last position
    sub     rsi,r8
    mov     rax,rsi
    
    ret


