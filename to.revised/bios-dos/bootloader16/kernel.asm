     BITS 16

os_main:
     cli                      ; Clear interrupts
     mov ax, 0
     mov ss, ax               ; Set stack segment and pointer
     mov sp, 0FFFFh
     sti                      ; Restore interrupts
     cld
     mov ax, 2000h            ; Set all segments to match where kernel is loaded
     mov ds, ax               ; After this, we don't need to bother with
     mov es, ax               ; segments ever again, as MikeOS and its programs
     mov fs, ax               ; live entirely in 64K
     mov gs, ax
     mov     si, welcome
     pusha

     mov ah, 0Eh              ; int 10h teletype function
.repeat:
     lodsb                    ; Get char from string
     cmp       al, 0
     je        .done          ; If char is zero, end of string
     int       10h            ; Otherwise, print it
     jmp       .repeat        ; And move on to next char
.done:
     popa               
.loop:        
     hlt
     jmp       .loop
        
welcome:  db   'Kernel example by Agguro - Version 1.0.0 Beta', 10, 13, 0