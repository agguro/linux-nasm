org 0
bits 16

bootcat:
     dd   1
     db   "Phoenix Technologies LTD4"
     db   0xE4
     db   0x55, 0xAA                              ; must be last
times 2048-($-bootcat)   db 0