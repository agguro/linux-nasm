%include "../includes/startup.inc"

     BITS 16
     
os_main:
     ; initialisation of kernel
     ; cs, ds, es, fs, gs and ss points to same segment (where kernel is loaded)
     ; sp points to last word of stacksegment
     cld
     mov       ax, cs                   ; Set all segments to match where kernel is loaded
     mov       ds, ax                   
     mov       es, ax                   
     mov       fs, ax                   
     mov       gs, ax
     cli                                ; Clear interrupts
     mov       ss, ax                   ; Set stack segment and pointer
     mov       sp, 0FFFEh
     sti                                ; Restore interrupts
     
     mov       ax, 0x4F02
     mov       bx, 0x107                ; <-1280x1024 256 = 107h colors
     mov       ax,0x4F02
     int       0x10
     
     ; print welcome screen
     mov       si, welcome
     call      print
     
osloop:

     hlt
     jmp       osloop

print:
     pusha
     mov       ah, 0Eh             ; int 10h teletype function
     mov       bx, 0x000F
.repeat:
     lodsb                         ; Get char from string
     cmp       al, 0
     je        .done               ; If char is zero, end of string
     int       10h                 ; Otherwise, print it
     jmp       .repeat             ; And move on to next char
.done:
     popa
     ret
     
welcome:       db   "Mini Kernel example by Agguro - Version 1.0.0 Beta", 10, 13, 0
     
