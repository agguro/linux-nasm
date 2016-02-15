;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                  ;;
;; Project          :   smiddyOS (CD-ROM Booter)                                    ;;
;; Author           :   smiddy                                                      ;;
;; Website          :                                                               ;;
;; Date             :   November 13, 2011                                           ;;
;; Poop             :   Bootloader, read CD-ROM, load kernel (CD_ROM VIEWER)        ;;
;; Filename         :   cdboot1.asm                                                 ;;
;; Assembler Command:   Using FASMW IDE                                             ;;
;;                                                                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                  ;;
;; Useage: Using CDBOOT1.BIN as the boot loader from the created ISO from the       ;;
;;         CD-ROM creating CDROM.ASM from from within FASMW IDE.                    ;;
;;                                                                                  ;;
;;         See CDROM.ASM for further details.                                       ;;
;;                                                                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                  ;;
;; v1.00a - Alpha release; CD-ROM compatible booter; learning the CD/DVD/BD boot    ;;
;;          process. Fill in the blanks and get yourself moving. I am working the   ;;
;;          rest of the code out, now that it boots.                                ;;
;;                                                                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   format binary as "bin"               ; Tell FASM to make an BIN image

    ORG 0

BootSector:                             ; Label in order to determine size of code for
                                        ; padding at the end.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start Boot Procedure                                                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Begin:                                  ; Begining of instructions

    CLI                                 ; Turn off intterrupts
    MOV [CDDriveNumber],DL              ; Save boot drive
    mov ax,07C0h                        ; Boot Segment
    mov gs,ax
    mov ds,ax
    mov es,ax
    mov fs,ax

    STI                                 ; Turn interrupts back on

    MOV SI,WelcomeMessage               ; Save pointer to welcome message
    CALL PrintString                    ; Print the welcome message
    MOV SI,TheEndOfTheLine
    CALL PrintString

    MOV AL,[CDDriveNumber]
    MOV CL,8
    CALL ToHex

    MOV SI,DriveNumberReported
    CALL PrintString

    MOV SI,HexBuffer
    CALL PrintString

    MOV SI,AddTheHAtTheEnd
    CALL PrintString

    MOV SI,TheEndOfTheLine
    CALL PrintString

    MOV DL,[CDDriveNumber]              ; Prepare to read CD-ROM, load boot drive
    MOV AH,4Bh                          ; Use function 4Bh
    MOV AL,1
    MOV SI,DiskResultsBuffer            ; Results buffer to load
    INT 13h                             ; Call Check Extensions Present?

    JC Failure

    MOV SI,DiskResultsBufferMessage     ; Loading this one
    CALL PrintString

    MOV SI,SizeOfPacketInBytes
    CALL PrintString

    MOV AL,[DiskResultsBuffer]
    MOV CL,8
    CALL ToHex

    MOV SI,HexBuffer
    CALL PrintString

    MOV SI,AddTheHAtTheEnd
    CALL PrintString

    MOV SI,TheEndOfTheLine
    CALL PrintString

    MOV SI,BootMediaType
    CALL PrintString

    MOV AL,[DiskResultsBuffer+1]
    MOV CL,8
    CALL ToHex

    MOV SI,HexBuffer
    CALL PrintString

    MOV SI,AddTheHAtTheEnd
    CALL PrintString

    MOV SI,TheEndOfTheLine
    CALL PrintString

    MOV SI,DriveNumberFromPacket
    CALL PrintString

    MOV AL,[DiskResultsBuffer+2]
    MOV CL,8
    CALL ToHex

    MOV SI,HexBuffer
    CALL PrintString

    MOV SI,AddTheHAtTheEnd
    CALL PrintString

    MOV SI,TheEndOfTheLine
    CALL PrintString

    MOV DL,[DiskResultsBuffer+2]
    MOV [CDDriveNumber],DL

    MOV DL,[CDDriveNumber]              ; Prepare to read CD-ROM, load boot drive
    MOV AH,41h                          ; Use function 41h
    MOV BX,55AAh                        ; Signature?
    INT 13h                             ; Call Check Extensions Present?

    JC Failure                          ; Nope, get out of here...

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Need to save the return here:
    ;; AH = Major Version Number
    ;; BX = 0AA55h
    ;; CX = Interface support bitmask:
    ;;      1 - Device Access using packet structure (assumed by me)
    ;;      2 - Drive Locking and Ejecting
    ;;      4 - Enhanced Disk Drive Support
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    MOV AX,CX
    MOV CL,16
    CALL ToHex

    MOV SI,HexBuffer
    CALL PrintString

    MOV SI,AddTheHAtTheEnd
    CALL PrintString

    MOV SI,IsEqualToTheCX
    CALL PrintString

    MOV SI,MessageReadTheDrive
    call PrintString

    MOV DL,[CDDriveNumber]              ; Set it up again
    MOV AH,42h                          ; Read from drive function
    MOV SI,DiskAddressPacket            ; Load SI with address of the Disk Address
                                        ;    Packet
    INT 13h                             ; Call read sector from drive

    JC Failure                          ; Nope, hosed, get out

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Need to read sector information for the boot directory.
    ;; The Disk Address Packet starts with:
    ;; db 10h - Initial Volume Descriptor, which has the important data we need
    ;;          to get to the root directory where our OS is stored.
    ;; db  0  - Unused, should be zero
    ;; dw  1  - Number of sectors to read (initial one should be one)
    ;; dd 1000:0000 - Initial segment:offset where to load the read in sector(S)
    ;; dq 16  - Starting sector to read in, then we need to get to the root directory
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    MOV ES,[DiskAddressPacket.Segment]
    MOV DI,[DiskAddressPacket.Offset]

    MOV EAX,[ES:DI+158]                 ; LBA of root directory, where all things start.
    MOV CL,32
    CALL ToHex

    MOV SI,HexBuffer
    CALL PrintString

    MOV SI,AddTheHAtTheEnd
    CALL PrintString

    MOV SI,IsEqualToTheEAX
    CALL PrintString

    MOV SI,MessageReadTheDrive
    call PrintString


Failure:

    mov AL,AH                           ; Put the error into lowest bits
    mov cl,8                            ; only 8 bits
    call ToHex                          ; Get what is in the XX to display

    MOV SI,FailureMessage               ; reboot message
    CALL PrintString
    mov si,HexBuffer
    CALL PrintString
    MOV SI,AddTheHAtTheEnd
    CALL PrintString
    MOV SI,TheEndOfTheLine
    CALL PrintString
    mov SI,PressAnyKeyMessage
    CALL PrintString
    MOV AH,0                            ; Reboot on error
    INT 16h                             ; BIOS GetKey
    INT 19h                             ; BIOS Reboot



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PrintString                                                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintString:

    PUSHA                               ; Save Registers

.Loop:

    LODSB                               ; Load SI into AL, increment SI one byte
    OR AL,AL                            ; AL = 0?
    JZ .Done                            ; If yes, get out
    MOV AH,0Eh
    MOV BH,0
    MOV BL,7                            ; character attribute
    INT 10h                             ; Display character in AL
    JMP .Loop                           ; Do it again

.Done:

    POPA                                ; Replace registers

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PrintMyDot - Increments through the numbers in order to see the number of        ;;
;;              sectors that have been loaded.                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintMyDot:

    mov ah,0Eh
    mov al,[BootDotNumber]
    int 10h
    inc al
    cmp al,58
    jb  .PDExit
    mov al,'0'

.PDExit:

    mov [BootDotNumber],al

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ToHex
;; Loads HexBuffer with ASCII corresponding to 8, 16, or 32 bit interger in
;;    hex.
;; Requires interger in AL, AX, or EAX depending on bit size
;; Requires the number of bits in the CL
;; Returns a full buffer or an empty buffer on error
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ToHex:

        pusha

    MOV BX,0x0000               ; Load BX with pointer offset
    MOV [TheEAX],EAX            ; Save the EAX
    MOV [TheCL],CL              ; Save the CL 
    CMP CL,0x08                 ; Check for 8 bits
    JNE .Check16
    JMP .Loop1                  ; Start loading the buffer

.Check16:

    CMP CL,0x10                 ; Check for 16 bits
    JNE .Check32
    JMP .Loop1                  ; Start loading the buffer

.Check32:

    CMP CL,0x20                 ; Check for 32 bits
    JNE .ErrorBits

.Loop1:

    MOV EAX,[TheEAX]            ; Reload EAX with the converter
    SUB CL,0x04                 ; Lower bit count by 4 bits
    SHR EAX,CL

    AND AL,0x0F
    ADD AL,'0'
    CMP AL,'9'
    JBE .LoadBuff1
    ADD AL,'A'-'0'-10           ; Convert to "A" to "F"

    JMP .LoadBuff1

.Loop2:
    MOV EAX,[TheEAX]            ; Reload EAX again
    SUB CL,4                    ; Lower bit count by 8 bits
    SHR EAX,CL
    AND AL,0x0F
    ADD AL,'0'
    CMP AL,'9'
    JBE .LoadBuff2
    ADD AL,'A'-'0'-10           ; Convert A,B,C,D,E,F

    JMP .LoadBuff2

.LoadBuff1:

    MOV [HexBuffer+BX],AL       ; Load buffer with AL
    INC BX                      ; Increment buffer pointer
    JMP .Loop2                  ; Do next byte

.LoadBuff2:

    MOV [HexBuffer+BX],AL       ; Load buffer with AL
    INC BX                      ; Increment buffer pointer
    CMP CL,0x00                 ; Check if we're done
    JNE .Loop1                  ; Do next Byte 

.ErrorBits:

    MOV AL,0x00
    MOV [HexBuffer+BX],AL       ; End the string with a zero
    
    popa

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Program Data                                                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DataSector:               DW 0
CDDriveNumber:            db 0

absoluteSector:           DB 0
absoluteHead:             DB 0
absoluteTrack:            DB 0

BootDotNumber:            DB '1'

Cluster:                  DW 0
FileName:                 DB 'SMIDDYOS.SYS'                ; FAT Filename, 8.3, or 11 characters

DiskResultsBufferMessage: db 'Disk Buffer on in here...',13,10,0
IsEqualToTheCX            db ' = CX contents from INT 13h Function 41h.',13,10,0
IsEqualToTheEAX           db ' = EAX contents is the sector of the root directory contents.',13,10,0
WelcomeMessage:           DB 'smiddy OS CD boot v1.00a',13,10,0   ; Saving space.
MessageReadTheDrive:      db 'Read the Drive, free and clear, make it hap',"'",'n cap',"'",'n!',13,10,0
FailureMessage:           db 'Failure: ',0
DriveNumberReported:      db 'Drive number reported: ',0
PressAnyKeyMessage:       db 'Press any key to reboot...',13,10,0
AddTheHAtTheEnd:          db 'h',0
TheEndOfTheLine:          db 13,10,0                        ; Used to print the end of the line string
SizeOfPacketInBytes:      db 'The size of packet in bytes: ',0
BootMediaType:            db 'The boot media type: ',0
DriveNumberFromPacket:    db 'Drive number from packet: ',0


DiskAddressPacket:        db 16,0
                          dw 1
.Offset:                  dw 0                                ; Offset :0000
.Segment:                 dw 1000h                            ; Segment 1000:
.End:                     dq 16                               ; Sector 16 or 10h on CD-ROM

DiskResultsBuffer: times 30 db 0                              ; Return buffer from int 13h ah=48h
HexBuffer:                  DB 0,0,0,0,0,0,0,0,0              ; Buffer for hex text string
TheEAX:                     dd 0                              ; Saves EAX
TheCL:                      db 0



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 512 Byte Code Boot Signature                                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TIMES 2046-($-BootSector)   DB 0
                            DW 0AA55h           ; Bootloading sector signature (for CD/DVD/BD)