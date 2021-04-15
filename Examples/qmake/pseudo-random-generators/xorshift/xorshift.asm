;name: xorshift.asm
;
;description: Create pseudo random number x in an interval [a,b] using the
;             XorShift pseudo random generator from George Marsaglia
;             http://en.wikipedia.org/wiki/Xorshift
;             at the end a list of generated numbers is shown
;
;example:
;3,1,9,8,2,9,9,5,3,1,6,5,9,3,2,8,7,4,4,1,2,4,6,6,6,3,8,3,8,7,9,
;4,3,4,6,6,5,2,4,1,6,5,8,3,1,3,4,9,6,4,4,4,5,4,8,8,9,5,5,8,2,9,
;3,2,4,2,4,8,1,9,8,2,5,6,3,8,7,5,9,9,7,3,9,3,3,3,3,2,3,7,3,5,7,
;4,9,9,5,8,7,2,2,6,3,3,9,8,9,7,9,2,1,8,8,9,5,9,7,8,6,5,4,8,4,2,
;2,7,7,3,9,5,3,8,5,6,4,5,5,9,3,5,4,3,4,3,8,8,2,2,8,2,5,9,3,4,4,
;1,1,9,6,8,1,8,3,8,7,6,9,2,4,5,1,6,5,3,3,9,3,2,3,9,2,4,1,5,7,3,
;1,1,7,2,5,2,8,4,5,1,5,5,4,8,5,1,3,4,5,2,7,9,2,7,1,9,8,7,6,6,2,
;1,7,8,3,8,5,4,7,8,7,1,5,7,1,2,6,7,6,8,7,6,9,4,2,4,1,2,3,9,9,2,
;1,3,1,8,8,3,8
;number of generated 1's : 23
;number of generated 2's : 29
;number of generated 3's : 36
;number of generated 4's : 29
;number of generated 5's : 30
;number of generated 6's : 20
;number of generated 7's : 23
;number of generated 8's : 34
;number of generated 9's : 31

bits 64

%include "../xorshift/xorshift.inc"

global main

section .bss
;uninitialized read-write data 
    buffer: resb 1

section .data
;initialized read-write data

    random:         db  "0"
    .len:           equ $-random
    ; the array to store the frequency of each individual number
    table:          times 9 db 0
    tableline1:     db  "number of generated "
    .len:           equ $-tableline1
    tableline2:     db  "'s : "
    .len:           equ $-tableline2

section .rodata
;read-only data

section .text

main:
    push    rbp
    mov     rbp,rsp
    mov     rcx,MAXNUMBERS                  ;initialize outer-loop counter
.repeat:
    push    rcx
    mov     rdi,random                      ;bufferaddress in RDI
    ;generate numbers in the interval [1,9]
    mov     rax,1                           ;lower boundary of interval
    mov     rdx,9                           ;higher boundary of interval
    call    generateRandom
    ;adjust table with counts for each generated number
    mov     rdx,rax                         ;number in RDX
    mov     rsi,table
    add     rsi,rdx                         ;point to the right place in the table
    dec     rsi
    inc     byte[rsi]                       ;increment position in table
    ;convert the number to ASCII
    ;depending the number length needed we convert the number of needed bits in ASCII hexadecimal
    ;in this example I only use the lowest nibble of RAX since the interval is [1,9]
    call    nibble2hexascii
    cld
    stosb
    syscall write,stdout,random,random.len
    pop     rcx                             ;restore outer-loop counter
    dec     rcx
    and     rcx, rcx
    jz      .printStatistics
    push    rcx                             ;syscall changes RCX !!
    mov     al, ","
    call    writeChar
    pop     rcx
    jmp     .repeat
.printStatistics:
    mov     al,LF
    call    writeChar
    mov     rcx,9
    mov     rsi,table
.nextLine:
    push    rsi
    mov     rsi,tableline1
    mov     rdx,tableline1.len
    call    writeLine
    mov     rax,10
    sub     rax,rcx
    call    byte2decascii
    call    writeDecimal
    mov     rsi,tableline2
    mov     rdx,tableline2.len
    call    writeLine
    pop     rsi
    xor     rax,rax
    lodsb
    call    byte2decascii
    call    writeDecimal
    mov     al,LF
    call    writeChar
    loop    .nextLine
    xor     rax,rax             ;return error code
    mov     rsp,rbp
    pop     rbp
    ret                         ;exit is handled by compiler

generateRandom:
    push    rbx
    push    rdx
;in rax : lower boundary of interval
;   rdx : higher boundary of interval
    ;calculate interval len
    dec     rax             ;minus one so we can have value for lower boundary too
    push    rax             ;save lower boundary
    clc
    sub     rdx,rax         ;calculate interval len
    mov     rbx,rdx         ;put in RBX
    ; generate seed
    rdtsc                   ;read cpu time stamp counter
    rol     rdx,32          ;mov EDX in high 32 bits of RAX
    or      rax,rdx         ;RAX = seed
    call    xorShift        ;get a pseudo random number from seed
    ; create random number rax <= number <= rdx
    xor     rdx,rdx
    idiv    rbx             ;rax = rax \ rbx
    cmp     rdx,0
    jnz     .skip
    add     rdx,rbx
.skip:
    pop     rax             ;restore lower boundary
    add     rdx,rax         ;add lower boundary to random number
    mov     rax,rdx         ;rax is number in interval [rax,rdx]
    pop     rdx
    pop     rbx
    ret

;XORSHIFT algorithm
xorShift:
    push    rdx
    mov     rdx,rax
    shl     rax,13
    xor     rax,rdx
    mov     rdx,rax
    shr     rax,17
    xor     rax,rdx
    mov     rdx,rax
    shl     rax,5
    xor     rax,rdx         ;rax random 64 bit value
    pop     rdx
    ret

;write a decimal in eax to STDOUT
writeDecimal:
    push    rax
    ror     eax,16
    and     al,al
    jz      gettenthts
    call    writeChar
gettenthts:
    rol     eax,8
    and     al, al
    jz      getdigits
    call    writeChar
getdigits:
    rol     eax,8
    call    writeChar
    pop     rax
    ret

;write a character in al to stdout
writeChar:
    push    rdx
    push    rsi
    mov     byte[buffer],al
    mov     rdx,1
    mov     rsi,buffer
    call     writeLine
    pop     rsi
    pop     rdx
    ret

;write a string pointed by rsi with len rdx to stdout
writeLine:
    push    rdx
    push    rsi
    push    rdi
    push    rcx
    push    rax
    syscall write, stdout
    pop     rax
    pop     rcx
    pop     rdi
    pop     rsi
    pop     rdx
    ret

;convert a byte in AL to its decimalk ASCII equivalent in EAX
byte2decascii:
;in  :: AL  = BYTE or 8 bits
;out :: EAX = lowest 24 bits are Decimal ASCII of BYTE
    push    rbx
    push    rcx
    push    rdx
    push    r8
    xor     rcx,rcx
    xor     r8,r8
    mov     rbx,10
.l1:
    xor     rdx,rdx
    idiv    rbx
    or      dl,"0"
    shrd    r8,rdx,8
    inc     rcx
    and     al,al
    jnz     .l1
    shl     rcx,3
    shld    rax,r8,cl
    pop     r8
    pop     rdx
    pop     rcx
    pop     rbx
    ret

;convert a nibble in AL to its hexadecimal ASCII equivalent in AL
nibble2hexascii:
;in  :: AL = NIBBLE or 4 bits (least significant)
;out :: AL = Hexadecimal ASCII of NIBBLE
    and     al,0x0F
    or      al,"0"
    cmp     al,"9"
    jbe     .l1
    add     al,7
.l1:
    ret
