; Name:         keyfilter
; Build:        see makefile
; Description:  The program displays the ASCII code in hexadecimal of the pressed key.
; Remark:       On terminals with escape key sequences binded to keys (like the cursor keys) the
;               program exits after pressing those (since ESCAPE sequences starts with the ESC key)
; Sources:      11.7 Writing UNIX® Filters - FreeBSD Developers’ Handbook
  
BITS 64

[list -]
    %include "unistd.inc"
    %include "termio.inc"
[list +]

section .bss
    buffer:  resq   8
    .length: equ    $-buffer
    
section .data
    output:     db  0,0," "
    .length:    equ $-output
    
    intro:      db  "filter - by Agguro 2011 source:  FreeBSD Developers’ Handbook.", 10
                db  "The program shows the ASCII codes of the pressed keys. ESC terminates the "
                db  "program.", 10
                db  "start typing >> "
     .length:   equ $-intro      
    
    EOL:
      .start:   db  "1B", 10      ; print the ASCII code for ESC to be complete
      .end:
    
      TERMIOS termios             ; termios structure
      
section .text
        global  _start
_start:
  
    mov     rsi, intro
    mov     rdx, intro.length
    call    Write
    call    termios_canonical_mode_off      ; switch canonical mode off
    call    termios_echo_mode_off           ; no echo

getKeyStroke:
    mov     rax,SYS_READ
    mov     rdi,STDIN
    mov     rsi,buffer
    mov     rdx,buffer.length
    syscall  
    cmp     BYTE[buffer], 0x1B          ; if ESC pressed
    je      Exit
    mov     al, BYTE[buffer]
  
toASCII:
    shl     rax, 4                       ; most significant nibble in AH
    shr     al, 4                        ; least significant nibble in AL
    or      ax, 3030h                    ; attempt to convert both to ASCII
    cmp     al, "9"                      ; is AL = ascii 9 ?
    jle     .highNibble
    add     al, 7
.highNibble:
    cmp     ah, "9"
    jle     .done
    add     ah, 7
.done:
    ror     ax, 8                        ; little ENDIAN notation
    mov     WORD[output],ax              ; ASCII in buffer to print
    mov     rsi, output
    mov     rdx, output.length
    call    Write
    jmp     getKeyStroke
  
Exit:
    mov     rsi,EOL
    mov     rdx,EOL.end-EOL.start
    call    Write     
    call    termios_canonical_mode_on   ; switch canonical mode back on
    call    termios_echo_mode_on        ; restore echo
    xor     rdi, rdi
    mov     rax,SYS_EXIT
    syscall

; write to STDOUT
Write:
    push    rcx
    push    rax
    push    rdi
    mov     rax,SYS_WRITE
    mov     rdi,STDOUT
    syscall
    pop     rdi
    pop     rax
    pop     rcx
    ret

; subroutine to switch canonical mode on
; RAX is unchanged on exit
termios_canonical_mode_on:
    push    rax
    mov     rax,ICANON
    jmp     termios_set_localmode_flag
  
; subroutine to switch echo mode on
; RAX is unchanged on exit
termios_echo_mode_on:
    push    rax
    mov     rax,ECHO
    jmp     termios_set_localmode_flag
  
; subroutine to set the bits in the c_lflag stored in EAX
; RAX is unchanged on exit
termios_set_localmode_flag:
    push    rax
    call    termios_stdin_read
    or      DWORD [termios.c_lflag], eax
    call    termios_stdin_write
    pop     rax
    pop     rax
    ret
  
; subroutine to switch canonical mode off
; RAX is unchanged on exit
termios_canonical_mode_off:
    push    rax
    mov     rax,ICANON
    jmp     termios_clear_localmode_flag
  
; subroutine to switch echo mode off
; RAX is unchanged on exit
termios_echo_mode_off:
    push    rax
    mov     rax,ECHO
    jmp     termios_clear_localmode_flag
  
; subroutine to clear the bits in the c_lflag stored in EAX
; RAX is unchanged on exit
termios_clear_localmode_flag:
    push    rax
    call    termios_stdin_read
    not     eax
    and     [termios.c_lflag], eax
    call    termios_stdin_write
    pop     rax
    pop     rax
    ret
  
; subroutine for all TCGETS operation on the syscall IOCTL
; the original value of RCX is restored on exit
termios_stdin_read:
    push    rsi
    mov     rsi,TCGETS
    jmp     termios_stdin_syscall
  
; subroutine for all TCSETS operation on the syscall IOCTL
; the original value of RCX is restored on exit
termios_stdin_write:
    push    rsi
    mov     rsi,TCSETS
    jmp     termios_stdin_syscall
    
; subroutine for operations on the syscall IOCTL for STDIN
; all registers are restored to their original values on exit of the subroutine
termios_stdin_syscall:
    push    rax
    push    rdi
    push    rdx
    mov     rax,SYS_IOCTL
    mov     rdi,STDIN
    mov     rdx,termios
    syscall
    pop     rdx
    pop     rdi
    pop     rax
    pop     rsi
    ret