;Name:        ip2hex.asm
;Build:       nasm "-felf64" ip2hex.asm -l ip2hex.lst -o ip2hex.o
;             ld -s -melf_x86_64 -o ip2hex ip2hex.oIP2Hex
;Description: convert IP address to hexadecimal and display it in little- and big endian notation.
;License:     https://www.gnu.org/licenses/gpl-3.0.txt

bits 64

[list -]
    %include "unistd.inc"
[list +]

section .bss
    buffer:     resb 1

section .data
      
    usageMsg:   db "usage: ip2hex ipaddress", 10
                db "where ipaddress is xxx.xxx.xxx.xxx", 10
                db "and xxx must be in the range 000-255 decimal.",10
                db "license: https://www.gnu.org/licenses/gpl-3.0.txt",10
    .length:    equ $-usageMsg
    htondMsg:   db "Host byte order (little endian): "
    .length:    equ $-htondMsg
    ntohdMsg:   db "Network byte order (big endian): "
    .length:    equ $-ntohdMsg
    lf:         db 10
      
section .text
    global  _start

_start:
    pop     rax                     ;get numer of argument
    cmp     rax,2
    jne     usage
    pop     rax                     ;get the command
    pop     rsi                     ;get the IP address
    mov     rdi,rsi                 ;save IP address
    call    ParseIP                 ;rax = IP address or errorcode
    and     rax,rax
    jl      usage
    mov     r15,rax
    syscall write,stdout,ntohdMsg,ntohdMsg.length
    mov     rax,r15
    call    PrintHex32              ;print the result 
    ;rax = hexadecimal IP address
    mov     r15,rax                 ;save rax
    syscall write,stdout,lf,1
    syscall write,stdout,htondMsg,htondMsg.length
    mov     rax,r15                 ;restore rax
    call    htond
    call    PrintHex32
    syscall write,stdout,lf,1
    jmp     exit      
usage:
    syscall write,stdout,usageMsg,usageMsg.length
exit:
    syscall exit,0

ParseIP:      
;ParseIP:Convert the IP address pointed by RSI to hexadecimal notation
;input:
;rsi:pointer to a zero terminated IP address string terminated
;     this string must be of the form xxx.xxx.xxx.xxx
;return:
;rax:hexadecimal equivalent of the IP address
;    if RAX = -1 : an error occured

    call    StringLength
    mov     r9,rax                  ;length in r9
    cmp     rax,15                  ;check maximum length
    jg      .error
    cmp     rax,7                   ;check minimum length
    jl      .error
    mov     rdi,rsi                 ;restore string pointer
    ; check the digit groups separately
    ; put a dot at the end of the string (in place of the trailing zero)
    add     rdi,r9
    mov     al,"."
    stosb
    mov     rdi,rsi                 ;restore pointer to ip address    
    ; we now read the number of dots in the ipaddress string which cannot be more than 4
    ; AL has already the byte to search for
    xor     r8,r8                   ;help register
    mov     r12,4                   ;four groups of numbers
.nextgroup:
    xor     rcx,rcx
    not     rcx
    mov     al,"."
    cld
    repne   scasb
    mov     rbx,rcx
    neg     rbx
    dec     rbx                     ;length of first group
    dec     rbx
    cmp     rbx,3
    jg      .error
    cmp     rbx,1
    jl      .error
    add     r8,rbx      
    ; the group is checked, now check the digits in the group
    xor     rdx,rdx
    xor     rax,rax
.nextbyte:
    lodsb                           ;digit from rsi in AL
    cmp     al,"."
    je      .done
    mov     rbx,rdx
    shl     rbx,3
    shl     rdx,1
    add     rdx,rbx
    cmp     al,"0"
    jb      .error
    cmp     al,"9"
    ja      .error
    and     al,0x0F                 ;un-ascii
    add     rdx,rax                 ;rdx = rdx + rax = rdx * 10
    jmp     .nextbyte
.done:
    cmp     rdx,0xFF                ;if bigger than 0xFF then error
    jg      .error
    shl     r10,8
    or      r10,rdx
    dec     r12
    cmp     r12,0
    jne     .nextgroup
    ; end of check and conversion
    add     r8,3                    ;the three dots
    cmp     r9,r8
    jne     .error
    mov     rax,r10                 ;return hexadecimal IP address in rax
    ret
.error:      
    xor     rax,rax
    inc     rax
    neg     rax
    ret
    
StringLength:
;Length of the IP address string.
;in:
;rsi:pointer to a zero terminated string
;out:
;rax:the length of the string
    xor     rcx,rcx
    not     rcx
    xor     rax,rax
    cld
    repnz   scasb
    neg     rcx
    sub     rcx,2                   ;minus2 for trailing zero and the place behind
    mov     rax,rcx
    ret

; keep the next two lines together      
htond:
ntohd:
;Convert the host byte order to the network byte order and vice versa of a 32 bit integer.
;in:
;eax:the 32 bit value
;out:
;eax:host or network byte order of the value
    rol     ax,8
    rol     eax,16
    rol     ax,8
    ret
      
PrintHex32:
;Print 32 bits hexadecimal to stdout
;in:
;eax:32 bit hexadecimal value
    mov     r10,rax                 ;save rax
    rol     rax,32
    mov     r12,8                   ;8 nibbles to STDOUT
.nibble:
    rol     rax,4
    mov     r8,rax
    xor     r8w,r8w
    or      al,"0"                  ;make ASCII
    cmp     al,"9"
    jbe     .printnibble
    add     al,7
.printnibble:
    mov     byte[buffer],al
    syscall write,stdout,buffer,1
    mov     rax,r8
    dec     r12
    cmp     r12,0
    jne     .nibble
    mov     rax,r10                 ;restore rax
    ret