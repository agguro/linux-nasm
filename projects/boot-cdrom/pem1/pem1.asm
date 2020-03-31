org 0
BITS 16

     jmp       start
pemloading:  db   'PEM1 loading, please wait....', 10, 13, 0
videomode:   dw   0

start:
%define FIRSTBANK  0
%define STARTBANK 10
%define LASTBANK  79
%define ENDBANK   LASTBANK
%define LINES_PER_BANK 13
%define PIXELS_PER_LINE 1280
%define SCAN_LINES 1240
%define DISPLACEMENT 256
; 1280 * 1024 = 1310720 pixels / screen
; 13 * 1280 = 16640 pixels per bank
; 1310720 / 16640 = 78,7 banks per screen (79)

mov ax, 0xA000
mov es:ax
mov ds:ax

mov cx, STARTBANK                                              ; banknumber
nextbank:
; switch bank
 mov ax, 0x4F05
 mov bx, 0
 mov dx, cx                                            ; switch to banknumber in cx
 int 0x10
 ; draw again
 mov ax, DISPLACEMENT                                            ; banknr * displacement 256
 mov bx, cx
 mul bx
 mov di, ax
 mov dl, 00000100b                                       
 push cx                                                 ; save banknumber
 mov cx, PIXELS_PER_LINE*LINES_PER_BANK
 push cx
 repeat:
 pop  cx
 lodsb
 or al, dl
 stosb
 dec cx
 and cx, cx
 push cx
 jnz repeat
 pop cx
 pop cx                                                ; restore banknumber
 inc cx
 cmp cx, ENDBANK
 jne nextbank
 
mov ax, 0x4F05
 mov bx, 0
 mov dx, FIRSTBANK                                            ; switch to banknumber in cx
 int 0x10

 ;%define BANK 10
 ;string:
 ;mov  ax, 0x4f05
 ;mov  bx, 0
 ;mov  dx, BANK
 ;int  0x10
 
 ;mov ax, 0xA000
 ;mov es, ax
 ;mov di, BANK*256
 ;mov al, 255
 ;mov cx, 1280*13
 ;rep movsb
 
 
 ;mov  ax, 0x4f05
 ;mov  bx, 0
 ;mov  dx, 0
 ;int  0x10
     mov       ax, cs
     mov       es, ax
     mov       ds, ax
     mov       si, pemloading
     ; test if stack behaves
     push      si
     xor       si, si
     pop       si
     call      Print
     retf

Print:
     pusha
     mov       ah, 0Eh              ; int 10h teletype function
     mov       bx, 0x000F
.repeat:
     lodsb                    ; Get char from string
     cmp       al, 0
     je        .done          ; If char is zero, end of string
     int       10h            ; Otherwise, print it
     jmp       .repeat        ; And move on to next char
.done:
     popa
     ret
     
     
;0 = black               8 = dark grey
;1 = dark blue           9 = bright blue
;2 = dark green          a = bright green
;3 = dark cyan           b = bright cyan
;4 = dark red            c = bright red
;5 = dark purple         d = bright purple
;6 = brown               e = yellow
;7 = light grey          f = white     