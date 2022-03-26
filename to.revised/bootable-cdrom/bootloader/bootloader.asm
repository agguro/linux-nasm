%include "../includes/startup.inc"

org 0x7C00
bits 16

global start

start:

     jmp     0x0000:flushCS                 ;force system to run from cs:ip = 0000:7C00 instead of 07C0:0000
     
     bootdrive:               db 0
     pressAnyKey:             db 'Press any key to reboot...',13,10,0
     fileName:                db 'KERNEL.BIN',0
     directoryEntrySize:      db   0
     fileSector:              dd   0
     fileSize:                dd   0
     fileNameLength:          db   0
     fileNameEntry:           TIMES 255 db ' '     
     fileEntryNumber:         db   0     
     SPECIFICATION_PACKET     specificationPacket
     DISK_ADDRESS_PACKET      diskAddressPacket,KERNELSTARTCS,KERNELSTARTIP
             
flushCS:
     ;set segment registers same as codesegment
     cli                                                              ;turn off intterrupts
     mov       ax, cs                                                 ;boot Segment
     mov       ds, ax
     mov       es, ax
     mov       ss, ax
     mov       sp, 0xFFFF                                             ;set stackpointer at end of current segment
     sti                                                              ;turn on interrupts
     mov       byte[bootdrive], dl                                    ;save boot drive
     and       dl, dl
     jz        notbootable                                            ;if result is zero then failure
     ;Call Check Extensions Present?
     mov       dl, byte[bootdrive]                                    ;prepare to read CD-ROM, load boot drive
     mov       ah, 0x41
     mov       bx, 0x55AA                                             ;signature?
     int       0x13                                         
     jc        notbootable                                            ;disk is not bootable
     ;get status: 
     mov       dl, byte[bootdrive]                                    ;prepare to read CD-ROM, load boot drive
     mov       ax, 0x4B01
     mov       si, specificationPacket               
     int       0x13
     ;DL still holds the bootdrive
     and       dl, byte[specificationPacket.drive_number]            ;Load resultant drive information
     jz        notbootable                                           ;if result not zero then failure
     mov       dl, byte[bootdrive]                                   ;Set it up again
     mov       ah, 0x42                                              ;read from drive function
     mov       si, diskAddressPacket                                 ;load SI with address of the Disk Address Packet
     int       0x13                                                  ;call read sector from drive
     jc        notbootable
     mov       es, word[diskAddressPacket.segment]
     mov       di, word[diskAddressPacket.offset]
     mov       eax, dword[es:di+158]                                 ;LBA of root directory, where all things start.
     mov       dword[diskAddressPacket.start_absolute_sector], eax   ;load packet with new address on CD of the root directory
     mov       dl, byte[bootdrive]                                   ;set it up again
     mov       ah, 0x42                                              ;read from drive function
     mov       si, diskAddressPacket                                 ;load SI with address of DAP
     int       0x13
     jnc       searchbootfile
notbootable:
     mov       si, pressAnyKey
     ;print message
     cld
.nextbyte:
     lodsb                                                           ;Load SI into AL, increment SI one byte
     and       al, al
     jnz       .printbyte
     xor       ah, ah
     int       0x16                                                  ;wait for key press
     int       0x19                                                  ;reboot system
.printbyte:     
     mov       ah, 0x0E
     mov       bx, 0x0007
     int       0x10                                                  ;display character in AL
     jmp       .nextbyte                                             ;repeat for next byte
searchbootfile:     
.nextdirentry:
     mov       al, byte[es:di]                                       ;length of the current directory entry
     mov       byte[directoryEntrySize],al
     mov       eax, dword[es:di+2]                                   ;starting sector of directory entry
     mov       dword[fileSector], eax
     mov       eax, dword[es:di+10]                                  ;size of file on CD/DVD/BD
     mov       dword[fileSize], eax
     mov       al, byte[es:di+32]                                    ;file's name length (see El Torito of ISO:9660 or CDROM.ASM)
     dec       al                                                    ;for trailing ;
     dec       al                                                    ;for trailing 1
     mov       byte[fileNameLength], al
     xor       bx, bx
     xor       cx, cx
     mov       si, di
     add       si, 33
     mov       bx, fileNameEntry
     mov       al, byte[fileNameLength]
.LoopFileNameEntry:
     mov       al, byte[es:si]
     mov       byte[ds:bx], al
     inc       bx
     inc       cx
     inc       si
     xor       ax, ax
     mov       al, byte[fileNameLength]
     cmp       cx, ax
     jne        .LoopFileNameEntry

     mov       byte[ds:bx],0

     mov       si, fileNameEntry
     push      di
     mov       di, fileName
    
.CompareLoop:
     mov       al, byte[si]                                          ;grab byte from ESI
     mov       bl, byte[di]                                          ;grab byte from EDI
     cmp       al, bl                                                ;compare if they are equal
     jne       .notequal                                             ;they aren't equal
     and       al, al                                                ;both bytes are null
     jz        .compareDone
     inc       di                                                    ;increment EDI
     inc       si                                                    ;increment ESI
     jmp       .CompareLoop                                          ;start looping
.notequal:
     stc                                                             ;set the carry flag to indicate failure
     jmp       .compareEnd
.compareDone:
     clc                                                             ;clear the carry flag to indicate success
.compareEnd:
     pop       di
     jnc       .nextsector
     xor       cx, cx                                                ;prepare CX to do math for DI
     mov       cl, byte[directoryEntrySize]                          ;get the size of the directory entry
     add       di, cx                                                ;add that size to the DI to get to the next record
     cmp       byte[es:di],0                                         ;is the next entry = 0?
     je        notbootable                                           ;if so, we're at the end of the directory, move on
     xor       cx, cx
     mov       bx, fileNameEntry
.clearFileNameEntry:
     mov       byte[ds:bx],0                                         ;erase the begining
     inc       bx
     inc       cx
     cmp       cx, 254
     jb        .clearFileNameEntry
     mov       byte[ds:bx],0
     jmp       searchbootfile.nextdirentry    
.nextsector:     
     mov       eax, dword[fileSector]
     mov       dword[diskAddressPacket.start_absolute_sector], eax   ;save the starting sector into DAP
     mov       eax, dword[fileSize]
     xor       edx, edx
     mov       ebx, 2048
     div       ebx
     inc       eax
     mov       [diskAddressPacket.sectors_to_read],AX                ;save number of sectors to read
     mov       dl, byte[bootdrive]                                   ;set it up again
     mov       ah,0x42                                               ;read from drive function
     mov       si,diskAddressPacket                                  ;load SI with address of the Disk Address Packet
     int       0x13                                                  ;call read sector from drive
     jc        notbootable                                           ;nope, hosed, get out
     mov       dl,byte[bootdrive]                                    ;drive into DL for booting
     jmp       KERNELSTARTCS:KERNELSTARTIP