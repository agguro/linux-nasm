ORG     0
BITS    16

     mov       ax, 0x4F02
     mov       bx, 0x107              ; <-1280x1024 256 = 107h colors
     int       0x10
      mov     si, msg1
      mov     bl, 0x04        ; red
      call    WriteStringWithAttributeMode19
retf
      
; ---------------------------
msg1: db      'Hola mi hombre', 13, 10, 0
; ---------------------------
; IN (bl,ds:si) OUT ()
WriteStringWithAttributeMode19:
      pusha
      mov     bh, 0           ; Display page 0
      mov     bp, bx
      jmp    .d
.a:   cmp     al, 9
      je      .Tab
      cmp     al, 13
      ja      .b
      mov     cx, 1101_1010_0111_1111b
      bt      cx, ax
      jnc     .c              ; 7,8,10,13 don't need the color

.b:   mov     bx, bp
      mov     dl, bl
      shr     dl, 4           ; Get background color (high nibble)
      and     bl, 15          ; Get foreground color (low nibble)
      xor     bl, dl
      mov     ah, 0Eh
      int     10h             ; BIOS.Teletype
      mov     ah, 03h
      int     10h             ; BIOS.GetCursor -> CX DX
      dec     dl              ; Column is [0,39]
      jns     .1
      mov     dl, 39
      dec     dh
.1:   movzx   cx, dl          ; Column -> X
      shl     cx, 3
      movzx   dx, dh          ; Row -> Y
      shl     dx, 3

      mov     bx, bp
      shr     bl, 4           ; Get background color (high nibble)
.2:   mov     ah, 0Dh         ; BIOS.ReadPixel
      int     10h             ; -> AL
      xor     al, bl
      mov     ah, 0Ch         ; BIOS.WritePixel
      int     10h
      inc     cx              ; X++
      test    cx, 7
      jnz     .2
      sub     cx, 8
      inc     dx              ; Y++
      test    dx, 7
      jnz     .2
      jmp     .d

.c:   mov     ah, 0Eh
      int     10h             ; BIOS.Teletype
.d:   lodsb
      test    al, al
      jnz     .a
      popa
      ret
.Tab: mov     cx, 1           ; Start displaying colored space(s)
      mov     bx, bp
      shr     bl, 4           ; Get background color
      mov     ax, 0EDBh       ; ASCII DBh is full block character
      int     10h             ; BIOS.Teletype
      mov     ah, 03h
      int     10h             ; BIOS.GetCursor -> CX DX
      test    dl, 7
      jnz     .Tab            ; Column not yet multiple of 8
      jmp    .d
; ----------------------------
