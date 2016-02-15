	BITS 16

start:
        mov     ax, 07C0h               ; 4K stack
        add     ax, (4096+512)/16       ; 
        cli                             ; no interrupts now
        mov     ss, ax
        mov     sp, 4096
        sti
        
        mov     ax, 07C0h
        mov     ds, ax
        
        mov     ax, 04F00h
        int     10h
        cmp     al, 04Fh
        jne     indefiniteLoop
        
        mov     si, msgWelcome
        
        mov     ah, 0Eh
        .repeat:
        lodsb
        and     al, al
        jz      .done
        int     10h
        jmp     .repeat
        .done:
indefiniteLoop:        
        jmp     $                       ; infinite loop
        
msgWelcome:     db      "This is my cool new OS", 10, 13 ,0

times   510-($-$$)      db 0
                        dw 0AA55h