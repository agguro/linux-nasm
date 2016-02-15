; Name:     winsize
; Build:    see makefile
; Run:      ./winsize
; description:
;   Shows the screen dimension of a terminal in rows/columns.

BITS 64

[list -]
    %include "unistd.inc"
    %include "termio.inc"
[list +]

section .bss
    buffer:    resb 5
    .end:
    .length:   equ  $-buffer
    lf:        resb 1

section .data

    WINSIZE winsize
  
               ; keep the lengths the same or the 'array' construction will fail!
    array:     db   "rows    : "
               db   "columns : "
               db   "xpixels : "
               db   "ypixels : "
    .length:   equ  $-array
    .items:    equ  4
    .itemsize: equ  array.length / array.items

section .text
     global _start
     
_start:
     mov     BYTE[lf], 10                    ; end of line in byte after buffer
     ; fetch the winsize structure data
     mov     rsi, TIOCGWINSZ
     mov     rdi, STDOUT
     mov     rdx, winsize                    ; pointer to structure to store result
     mov     rax, SYS_IOCTL
     syscall
     ; initialize pointers and used variables
     mov     rsi, array                 ; pointer to array of strings
     mov     rcx, array.items              ; items in array
.nextVariable:    
     ; print the text associated with the winsize variable
     push    rcx                        ; save remaining strings to process
     push    rdx                        ; save winsize pointer
     mov     rdx, array.itemsize
     mov     rdi, STDOUT
     mov     rax, SYS_WRITE
     syscall
     pop     rax                        ; restore winsize pointer
     push    rax                        ; save winsize pointer
     ; convert variable to decimal
     mov     ax,  WORD[rax]                  ; get value form winsize structure
     mov     rdi, buffer.end-1
.repeat:    
     xor     rbx, rbx                   ; convert value in decimal
     mov     bx, 10
     xor     rdx, rdx
     div     bx
     xchg    rax, rdx
     or      al, "0"
     std
     stosb
     xchg    rax, rdx
     cmp     al, 0
     jnz     .repeat
     push    rsi                        ; save pointer to text

     ; print the variable value    
     mov     rsi, rdi
     mov     rdx, buffer.end                 ; length of variable
     sub     rdx, rsi
     inc     rsi
     mov     rdi, STDOUT
     mov     rax, SYS_WRITE
     syscall
     pop     rsi
     pop     rdx
     ; calculate pointer to next variable value in winsize
     add     rdx, 2
     ; calculate pointer to next string in strings
     add     rsi, array.itemsize
     ; if all strings processed
     pop     rcx                        ; remaining arrayitems
     loop     .nextVariable
     ; exit the program
     mov     rdi, 0
     mov     rax, SYS_EXIT
     syscall