; Name:         Palindrome
; Build:        see makefile
; Description:  The program checks if a given string is a palindrome. If no string is passed on
;               the commandline a brief message is displayed on how to use the program.
;               The string can be any charactersequence and is case sensitive thus Aa is a
;               palindrome of aA but not of aa.
; Usage:        ./palindrome string1 string2 .... stringn

BITS 64

[list -]
     %include "unistd.inc"
[list +]

section .data

      usage:
        .start:  db "Palindrome by Agguro.",10
                 db "usage: palindrome string1 string2 ...",10
        .length: equ $-usage.start
        
      palindrome:
        .start:  db " is "
        .not:    times 4 db 0
                 db "a palindrome.", 10
        .length: equ $-palindrome.start
  
section .text
        global  _start
_start:
        pop     rcx                     ; argc in RCX
        cmp     rcx, 2                  ; is there an argument?
        jl      .noArguments
        pop     rax                     ; pointer to command      
        dec     rcx                     ; argc - 1 because of command
.repeat:
        pop     rsi                     ; get pointer to string
        call    String.length           ; get length of string
        mov     rdx, rax                ; lenght in rdx
        call    String.write
        
        call    Palindrome.check
        
        jnc     .isPalindrome
        mov     eax, "not "
        mov     rdi, palindrome.not
        mov     DWORD[rdi], eax
.isPalindrome:
        mov     rsi, palindrome
        mov     rdx, palindrome.length
        call    String.write
.until:
        mov     rdi, palindrome.not
        mov     DWORD[rdi], 0
        loop    .repeat
        jmp     Exit
.noArguments:    
        mov     rsi, usage
        mov     rdx, usage.length
        call    String.write
        jmp     Exit
Exit:
        xor     rdi, rdi
        mov     rax, SYS_EXIT
        syscall
    
Palindrome:
.check:
        ; RSI has the pointer to a zero terminated string. If the string is a palindrome then the
        ; subroutine returns with the carryflag cleared, otherwise the carryflag is set.

        push    rsi
        push    rdi
        push    rax
        push    rcx  
        ; get length of stringz pointed by RSI
        call    String.length
        ; pointer to last character of string
        mov     rdi, rsi
        add     rdi, rax                ; calculate pointer to last character in string
        dec     rdi
        ; calculate middle of string
        shr     rax, 1                  ; divide rax by 2
        mov     rcx, rax                ; integer part of division in rcx
.repeat:    
        mov     al, BYTE [rsi]          ; read byte RCX from begin of string
        mov     ah, BYTE [rdi]          ; read byte RCX from end of string
        cmp     al, ah      
        jne     .noPalindrome
        inc     rsi                     ; move pointer to next byte position
        dec     rdi                     ; move pointer to previous byte position
        dec     rcx                     ; adjust counter
        jnz     .repeat
        clc                             ; string is palindrome
        jmp     .done
.noPalindrome:
        stc
.done:
        pop     rcx
        pop     rax
        pop     rdi
        pop     rsi
        ret
    
String:
.length:
        ; RSI has the pointer to a zero terminated string
        ; the length will be returned in RAX, all registers except RAX are restored
        push    rsi                     ; store used registers
        push    rcx     
        xor     rcx, rcx                ; bytecounter
.repeat:    
        lodsb                           ; byte in AL
        cmp     al, 0                   ; if 0 then end of string
        je      .done
        inc     rcx                     ; else increment byte counter
        jmp     .repeat
.done:    
        mov     rax, rcx                ; string length in RAX
        pop     rcx                     ; restore used registers
        pop     rsi
        ret
    
.write:
        ; show a string pointed by RSI and length RDX on STDOUT
        ; all registers are restored
        push    rcx
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall
        pop     rcx
        ret