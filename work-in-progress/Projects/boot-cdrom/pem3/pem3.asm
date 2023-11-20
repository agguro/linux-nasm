org 0
BITS 16

     jmp       start
pemloading:  db   'PEM3 loading, please wait....', 10, 13, 0
start:

     mov       si, pemloading

     call      Print
     retf

Print:
     pusha
     mov       ah, 0Eh        ; int 10h teletype function
.repeat:
     lodsb                    ; Get char from string
     cmp       al, 0
     je        .done          ; If char is zero, end of string
     int       10h            ; Otherwise, print it
     jmp       .repeat        ; And move on to next char
.done:
     popa
     ret
