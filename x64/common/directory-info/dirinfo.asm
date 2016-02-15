; Name:         dirinfo.asm
; Build:        see makefile
; Run:          ./dirinfo
; Description:  displays directory entries information of the current working directory
; To-do:        - the files and directories aren't sorted
;               - better layout
;               - integers display in decimal
;               - list directory entries from directory on command line

BITS 64

[list -]
      %include "unistd.inc"
      %include "sys/dirent.inc"
      %include "sys/stat.inc"
[list +]

section .bss
      buffer:   resb    1024
      .length:  equ     $-buffer
     
section .data

      DIRENT64 dirent                   ; dirent structure

      path:          db "."
      fd:            dq 0
      nread:         dq 0
      spacer0:       db "            ", 0
      spacer:        db "  |  ", 0
      line:          db "----------------------------------------------------------------------------------------------------------", 10, 0
      tableheader:   db "     inode        |    next entry      |    record length   |        filetype             |    filename  |", 10, 0
      totallength:   db "                          Total length |  ", 0
                    
section .text
      global _start

_start:
     
      mov         rsi, O_RDONLY | O_DIRECTORY             ; open path in readonly and as directory otherwise fail
      mov         rdi, path
      mov         rax, SYS_OPEN
      syscall
      and         rax, rax
      js          Exit                            ; there was an error, just exit
      mov         QWORD[fd], rax                  ; save filedescriptor
      
      mov         rdi, QWORD[fd]
      mov         rsi, buffer
      mov         rdx, buffer.length
      mov         rax, SYS_GETDENTS64
      syscall
      and         rax, rax
      jle         Close                           ; if RAX = 0 : no entries, if RAX < 0 : error
      
      mov         QWORD[nread], rax
      
      mov         rsi, line
      call        String.ToSTDOUT
      mov         rsi, tableheader
      call        String.ToSTDOUT
      mov         rsi, line
      call        String.ToSTDOUT
      
      xor         rdx, rdx                        ; position in buffer
.repeat:     
      mov         rbx, buffer                     ; buffer start
      add         rbx, rdx                        ; buffer + position = entry
      
      ; next entry
      xor         rcx, rcx                        ; length of entry
      mov         rsi, rbx                        ; this entry
      add         rbx, 16                         ; address of length of entry
      mov         cx, WORD[rbx]                   ; put in rcx
      mov         rdi, dirent                     ; dirent structure pointer in RDI
      cld
      rep         movsb                           ; copy RCX bytes from RSI to RDI (into structure)
      
      ; read the entry record
      
      push        rdx

      mov         rax, QWORD[dirent.d_ino]
      call        Register.64bitsToHex
      mov         rsi, rax                        ; pointer to buffer in RSI
      call        String.ToSTDOUT
      
      mov         rsi, spacer
      call        String.ToSTDOUT
      
      ; 
      mov         rax, QWORD[dirent.d_off]
      call        Register.64bitsToHex
      mov         rsi, rax
      call        String.ToSTDOUT
      
      mov         rsi, spacer
      call        String.ToSTDOUT

      mov         rsi, spacer0
      call        String.ToSTDOUT
      
      mov         ax, WORD[dirent.d_reclen]
      call        Register.16bitsToHex
      mov         rsi, rax
      call        String.ToSTDOUT
      
      mov         rsi, spacer
      call        String.ToSTDOUT
      
      mov         al, BYTE[dirent.d_type]
      call        Register.8bitsToHex
      mov         rsi, rax
      call        String.ToSTDOUT
      
      mov         rsi, spacer
      call        String.ToSTDOUT
      
      mov         al, BYTE[dirent.d_type]
      call        Entry.GetType
      mov         rsi, QWORD[rax]
      call        String.ToSTDOUT
      
      mov         rsi, spacer
      call        String.ToSTDOUT
      
      mov         rsi, dirent.d_name              ; name of entry
      call        String.ToSTDOUT
      
      mov         al, 0x0A
      call        Character.ToSTDOUT
      
      pop         rdx
      ; prepare to read next entry
      add         dx, WORD[dirent.d_reclen]
      mov         rax, QWORD[nread]
      cmp         rdx, rax
      jl          .repeat
      
      mov         rsi, line
      call        String.ToSTDOUT
      
      mov         rsi, totallength
      call        String.ToSTDOUT
      
      mov         rax, QWORD[nread]
      call        Register.64bitsToHex
      mov         rsi, rax
      call        String.ToSTDOUT
      
      mov         al, 10                          ; end of line
      call        Character.ToSTDOUT
     
Close:     
      mov         rdi, fd                         ; fd in RDI
      mov         rax, SYS_CLOSE                  ; close file descriptor
      syscall
     
Exit:     
      xor         rdi, rdi
      mov         rax, SYS_EXIT
      syscall
    
Entry:
.GetType:
      section     .data
      FileType:
        .Unknown:      db "unknown           ",0
        .Fifo:         db "named pipe        ",0
        .Character:    db "character device  ",0
        .Directory:    db "directory         ",0
        .Block:        db "block device      ",0
        .Regular:      db "regular file      ",0
        .Link:         db "symbolic link     ",0
        .Socket:       db "unix domain socket",0
        .Without:      db "without type      ",0
        .Table:        dq   .Unknown, .Regular, .Directory, .Socket, .Character, .Link, .Block, .Without, .Fifo, 
      
      ; with the values defined for the different file types, the algorithm to find the apropriate string will be a bit to
      ; long for me.  By arranging the bits a bit and put the pointers to the strings in the right place, we have a shorter algorithm.
      ; (it's even easier)
      ;
      ; change all bits of place, the MSBit become the LSBit and vice versa
      ; Filetype  binary   becomes  decimal
      ; --------  ------   -------  -------
      ;     0     0000      0000      0
      ;     1     0001      1000      8
      ;     2     0010      0100      4
      ;     4     0100      0010      2
      ;     6     0110      0110      6
      ;     8     1000      0001      1
      ;    10     1010      0101      5
      ;    12     1100      0011      3
      ;    14     1110      0111      7
      ; If we order the results ascending, we got the following
      ;
      ; decimal    FileType   Name of file type
      ; -------    --------   -----------------
      ;    0          0       unknown
      ;    1          8       regular file
      ;    2          4       directory
      ;    3         12       unix socket
      ;    4          2       character
      ;    5         10       symbolic link
      ;    6          6       block device
      ;    7         14       without filetype
      ;    8          1       named pipe
      ;
      ; The algorithm
      
      section     .text
      
      and         rax, 0Fh                ; delete unnecessary bits
      xor         rdx, rdx                ; erase contents of RDX
      clc                                 ; clear carry bit
      rcr         al, 1                   ; move bits from old position to new position
      rcl         dl, 1
      rcr         al, 1
      rcl         dl, 1
      rcr         al, 1
      rcl         dl, 1
      rcr         al, 1
      rcl         dl, 1
      mov         rax, FileType.Table
      shl         rdx, 3                  ; 8 bytes for 64 bit pointer
      add         rax, rdx                ; pointer to filetype name from table in RAX
      ret

Register:

      section     .bss
      
      .@@hexbuffer:       resb    16
      .@@dummy:           resb    1               ; end of string
      
      section     .text
    
.64bitsToHex:    
      mov         rcx, 16                         ; 16 nibbles x 4 bits/nibble = 64 bits
      mov         rdi, .@@hexbuffer
      jmp         .@@convert
.16bitsToHex:
      mov         rcx, 4
      mov         rdi, .@@hexbuffer+24
      and         rax, 0FFFFh
      ror         rax, 16                         ; move word bits to upper registry bits
      jmp         .@@convert
.8bitsToHex:
      mov         rcx, 2
      mov         rdi, .@@hexbuffer+30
      and         rax, 0FFh
      ror         rax, 8                          ; move byte bits to upper registry bits
      jmp         .@@convert
    
.@@convert:
      push        rdi                             ; save buffer
      ; convert RAX to ASCII hexadecimal
      mov         rdx, rax
      xor         rax, rax
      cld
.@@repeat:    
      rol         rdx, 4                          ; start with most significant nibble first
      mov         al, dl
      and         al, 0Fh
      cmp         al, 9
      jbe         .@@toascii
      add         al, 7
.@@toascii:
      add         al, "0"
      stosb                                       ; store AL in hexbuffer
      loop        .@@repeat
      pop         rax                             ; start of buffer in RAX
      ret
    
String:
.ToSTDOUT:
      cld
.@@repeat:     
      lodsb
      and        al, al
      jz         .@@done
      push       rsi
      call       Character.ToSTDOUT
      pop        rsi
      jmp        .@@repeat
.@@done:
      ret

Character:
      section     .bss  
      
      .@@charbuffer:         resb    1
      
      section     .text
      
.ToSTDOUT:
      mov        BYTE[.@@charbuffer], al
      mov        rsi, .@@charbuffer
      mov        rdx, 1
      mov        rdi, STDOUT
      mov        rax, SYS_WRITE
      syscall
      ret