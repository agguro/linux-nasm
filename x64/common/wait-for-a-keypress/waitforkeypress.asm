; Name:         waitforkeypress
; Build:        see makefile
; Run:          ./waitforkeypress
; Description: 
;       Displays a message, in this case "press any key to exit..." and wait until the user hits
;       a key. With a buffer, large enough and wich you erases entirely after hitting a key
;       or key sequence (like ALT-[somekey], the remains of a hotkey aren't displayed neither.
;       The program works on most keys however CTRL, SUPER or ALT doesn't give the desired effect.
;       For a solution on that we must use the scancode of a key.
;       A better message should be, press any key except CTRL, SUPER or ALT

BITS 64

[list -]
    %include "unistd.inc"
    %include "termio.inc"
[list +]


section .bss
    buffer:     resb     5                                 ; one byte isn't enough on my system ...
    .length:    equ      $-buffer                          ; (reason are often the hotkey sequences)
                                           
section .data

    TERMIOS termios             ; termios structure
    
    message:   db   "Press any key to exit..."
    .length:   equ  $-message

section .text
    global _start

_start:

    ; first write a message to STDOUT
    mov        rsi, message
    mov        rdx, message.length
    mov        rdi, STDOUT
    mov        rax, SYS_WRITE
    syscall
    
    call    TermIOS.Canonical.OFF      ; switch canonical mode off
    call    TermIOS.Echo.OFF           ; no echo

ReadKey:
    mov     rsi, buffer
    mov     rdx, buffer.length
    mov     rdi, STDIN
    mov     rax, SYS_READ
    syscall
    
    ; clear the buffer
    mov     QWORD[rsi], 10

    mov     rsi, buffer
    mov     rdx, buffer.length
    mov     rdi, STDOUT
    mov     rax, SYS_WRITE
    syscall

    ; Don't forget to switch canonical mode on
    call    TermIOS.Canonical.ON       ; switch canonical mode back on
    call    TermIOS.Echo.ON            ; restore echo

    xor        rdi, rdi
    mov        rax, SYS_EXIT
    syscall
    
; **********************************************************************************************    
; TERMIOS functions:
; TermIOS.Canonical.ON        : switch canonical mode on
; TermIOS.Canonical.OFF       : switch canonical mode off
; TermIOS.Echo.ON             : switch echo mode on
; TermIOS.Echo.OFF            : switch echo mode off
; TermIOS.LocalModeFlag.SET   : set the localmode flag described in RAX
; TermIOS.LocalModeFlag.CLEAR : clear the localmode flag described in RAX 
; TermIOS.STDIN.Read          : Read the TERMIO flags
; TermIOS.STDIN.Write         : Write the TERMIO flags
; TermIOS.IOCTL               : Read or write the localmode flags to or from TERMIOS
; **********************************************************************************************

TermIOS.Canonical:
.ON:
    mov     rax, ICANON
    jmp     TermIOS.LocalModeFlag.SET

.OFF:
    mov     rax,ICANON
    jmp     TermIOS.LocalModeFlag.CLEAR

TermIOS.Echo:
.ON:
    mov     rax,ECHO
    jmp     TermIOS.LocalModeFlag.SET

.OFF:
    mov     rax,ECHO
    jmp     TermIOS.LocalModeFlag.CLEAR

TermIOS.LocalModeFlag:
.SET:
    call    TermIOS.STDIN.READ
    or      dword [termios.c_lflag], eax
    call    TermIOS.STDIN.WRITE
    ret

.CLEAR:
    call    TermIOS.STDIN.READ
    not     eax
    and     [termios.c_lflag], eax
    call    TermIOS.STDIN.WRITE
    ret

; subroutine for all TCGETS operation on the syscall IOCTL
; the original value of RCX is restored on exit
TermIOS.STDIN:
.READ:
    mov     rsi, TCGETS
    jmp     TermIOS.IOCTL

; subroutine for all TCSETS operation on the syscall IOCTL
; the original value of RCX is restored on exit
.WRITE:
    mov     rsi, TCSETS

; subroutine for operations on the syscall IOCTL for STDIN
; all registers are restored to their original values on exit of the subroutine
TermIOS.IOCTL:
    push    rax             ; we need to store RAX or TermIOS.LocalFlag functions fail
    mov     rax, SYS_IOCTL
    mov     rdi, STDIN
    mov     rdx, termios
    syscall
    pop     rax
    ret