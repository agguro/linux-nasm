org 0x7c00
bits 16
; 512MB usb harddrive
; nasm -fbin usbboot.asm -o usbboot.bin -l usbboot.lst
; dd status=noxfer conv=notrunc count=1 if=usbboot.bin of=usbdisk.img
; qemu-system-i386 usbdisk.img

; bootstrap starts in memory at 0000:7C00
     xor ax,ax                  ; Zero out both the Accumulator and
     mov ss,ax                  ;    the Stack Segment register.
     mov sp,0x7c00              ; Set Stack Pointer to 0000:7C00
     sti                        ; enable interrupts
     push ax                    ; ax=0
     pop es                     ; zero out ES
     push ax                    ; ax = 0
     pop ds                     ; zero out DS
     cld                        ; clear Direction flag
     mov si,bootloader          ; 0x7c1b              ; copy from 0000:07CB1 
     mov di,0x61b               ; to 0x061B
     push ax                    ; push segment
     push di                    ; push offset
     mov cx,end-bootloader      ; 0x1e5               ; copy 0x01E5 bytes
     rep movsb                  ;
     retf                       ; jmp to bootloader at 0000:0x061B

bootloader:
     mov si,partition_entries   ;0x7be
     mov cl,0x4
label_0x20:
     cmp [si],ch
     jl label_0x2d
     jnz label_0x3b
     add si,byte +0x10        ; next partition entry
     loop label_0x20
     int 0x18
label_0x2d:
     mov dx,[si]
     mov bp,si
label_0x31:
     add si,byte +0x10
     dec cx
     jz label_0x4d
     cmp [si],ch
     jz label_0x31
label_0x3b:
     mov si,invalid_partition_table
label_0x3e:
     dec si
label_0x3f:
     lodsb
     cmp al,0x0
     jz label_0x3e
     mov bx,0x7
     mov ah,0xe
     int 0x10
label_0x4b:
     jmp short label_0x3f
label_0x4d:
     mov [bp+0x25],ax
     xchg ax,si
     mov al,[bp+0x4]
     mov ah,0x6
     cmp al,0xe
     jz label_0x6b
     mov ah,0xb
     cmp al,0xc
     jz label_0x65
     cmp al,ah
     jnz label_0x8f
     inc ax
label_0x65:
     mov byte [bp+0x25],0x6
     jnz label_0x8f
label_0x6b:
     mov bx,0x55aa
     push ax
     mov ah,0x41
     int 0x13
     pop ax
     jc label_0x8c
     cmp bx,0xaa55
     jnz label_0x8c
     test cl,0x1
     jz label_0x8c
     mov ah,al
     mov [bp+0x24],dl
     mov word [label_0xa1],0x1eeb                      ; jmp 0x06c1 = EB 1B opcodes
label_0x8c:
     mov [bp+0x4],ah
label_0x8f:
     mov di,0xa
label_0x92:
     mov ax,0x201
     mov bx,sp
     xor cx,cx
     cmp di,byte +0x5
     jg label_0xa1
     mov cx,[bp+0x25]
label_0xa1:
     add cx,[bp+0x2]            ; Normally, [BP+02] = Sector value.                                                       
                                                       ; But Can also be:  JMP 06C1 (if the test for Extended INT 13 above; is positive!)
     int 0x13
label_0xa6:
     jc label_0xd1
     mov si,missing_operating_system
     cmp word [magic_word],0xaa55
     jz label_0x10d
     sub di,byte +0x5
     jg label_0x92
label_0xb8:
     test si,si
     jnz label_0x3f
     mov si,error_loading_operating_system
     jmp short label_0x4b
     cbw                                          ; convert byte to word
     xchg ax,cx
     push dx
     cwd                                          ; convert word to dword
     add ax,[bp+0x8]
     adc dx,[bp+0xa]
     call word label_0xe0
     pop dx
     jmp short label_0xa6
label_0xd1:
     dec di
     jz label_0xb8
     xor ax,ax
     int 0x13
     jmp short label_0x92

; mystery bytes at offset 0x06DA
mystery_bytes:
     db 0,0,0,0,0,0

; subroutine at offset 0x060E
label_0xe0:
     push si
     xor si,si
     push si
     push si
     push dx
     push ax
     push es
     push bx
     push cx
     mov si,0x10
     push si
     mov si,sp
     push ax
     push dx
     mov ax,0x4200
     mov dl,[bp+0x24]
     int 0x13
     pop dx
     pop ax
     lea sp,[si+0x10]
     jc label_0x10b
label_0x101:
     inc ax
     jnz label_0x105
     inc dx
label_0x105:
     add bh,0x2
     loop label_0x101
     clc
label_0x10b:     
     pop si
     ret
label_0x10d:     
     jmp short lonely_code

; error messages
; start at 0x070F in memory
invalid_partition_table:
     db "Invalid partition table", 0
; at 0727
error_loading_operating_system:
     db "Error loading operating system", 0
; at 0746
missing_operating_system:
     db "Missing operating system", 0

     times 116-($-invalid_partition_table) db 0

; mystery bytes at offset 0x0783
lonely_code:
     mov       di, sp
     push      ds
     push      di
     mov       si,bp
     retf
end_lonely_code:

     times 59-(end_lonely_code-lonely_code) db 0

     ; partition tables start at offset 0x07BE
partition_entries:
     db 0x80,0x01,0x01,0x00,0x0E,0x0F,0x3F,0x0f,0x3F,0x00,0x00,0x00,0xC1,0xFE,0x0F,0x00
     db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
     db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
     db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
     times 510-($-$$) db 0   ; Pad remainder of boot sector with zeros
magic_word:     
     dw 0AA55h               ; Boot signature (DO NOT CHANGE!)
end: