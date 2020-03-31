ORG 0
BITS 16

BootCat:
     DD   1
     DB   "Phoenix Technologies LTD4"
     DB   0xE4
     DB   0x55, 0xAA                              ; must be last
TIMES 2048-($-BootCat)   DB 0