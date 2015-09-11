; Name:         arguments
; Build:        see makefile
; Run:          ./arguments arg1, arg2, arg3, ...
; Description:  Read the number of arguments and if any write it to the STDOUT device.
;
; Comment:
; When a program loads the arguments passed to the program are stored on the stack.
; cfr: C program with argc and argv.
; In assembly language it's easy to get those parameters by popping them from the stack before we do anything else with the stack.
; In more serious programs we should have to deal with the stack adjustment, unless you don't need the arguments anymore. For this
; example we just pop the arguments.
; To preserve some registervalues on stack we need to build a stackframe, push our registervalues on stack and get the argc and argv
; values of the stack.  In this example I don't use a stackframe, just to show how you can get the argc and argv values the easy way.
;
;                   -------------------
; RSP               |     argc + 1    | <-- state of RSP right after program load
;                   |-----------------|
; RSP+8             |   programname   | <-- the programname
;                   |-----------------|
; RSP+16+(n * 8)    |     argv[n]     | <-- pointers to argv[]
;                   |-----------------|
;
; Execution:    ./arguments 10 25 "hallo" test12 'test' ?
;
; Output:
; argc        : 7
; programname : ./arguments
; argv[]      : 10 25 hallo test12 test ?


bits 64

[list -]
     %include "unistd.inc"
[list +]

     EOL       equ  10

section .bss

     buffer    resb 20                       ; reserve 20 bytes as a buffer
        
section .data
        
     msgArgc   db   "argc        : ",0
     msgProg   db   "Programname : ",0
     msgArgv   db   "argv[]      : ",0
        
section .text
        global _start
_start:
     ; write message and argc as unsigned integer to STDOUT
     mov       rsi, msgArgc                  ; write first line
     call      Write.string

     ; convert the value of argc in unsigned integer ASCII
     pop       rax                           ; get argc of stack
     dec       rax                           ; number of arguments is rax minus one
     mov       rcx, rax                      ; initialize RCX as counter (argc)
     call      Convert                       ; convert RAX into unsigned integer ASCII
     call      Write.string                  ; write the unsigned integer

     mov       al,EOL                        ; end of line
     call      Write.char

     ; write message and the programname to STDOUT
     mov       rsi, msgProg                  ; write second line
     call      Write.string       
     pop       rsi                           ; get programname from stack
     call      Write.string                  ; write the programname
     mov       al,EOL                        ; end of line
     call      Write.char
     ; write message and all arguments to STDOUT
     mov       rsi, msgArgv
     call      Write.string
     cmp       rcx, 0                        ; are there arguments?
     je        .endOfArgs                    ; no arguments, nothing to show
.nextArg:
     pop       rsi
     call      Write.string
     cmp       rcx,1
     je        .endOfArgs
     mov       al,' '
     call      Write.char
.noSpace:       
     loop      .nextArg

.endOfArgs:     
     mov       al,EOL
     call      Write.char
Exit:
     xor       rdi, rdi
     mov       rax, SYS_EXIT
     syscall

Write:
.string:
     cld                                     ; make sure we count upwards in memory
     lodsb                                   ; load byte from RSI:RAX in AL
     cmp       al, 0                         ; if zero then end of ASCIIZ string
     je        .done
     call      Write.char
     jmp       .string
.char:
     push      rsi
     push      rcx
     mov       rsi,buffer
     mov       byte [buffer],al
     mov       rdx, 1
     mov       rsi, buffer
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     xor       rdx, 1
     jnz       .done
     mov       byte [rsi],0
     pop       rcx
     pop       rsi                           ; restore used registers
.done:
     ret

Convert:
     mov       rsi,buffer+19
     mov       rbx,10
.repeat:
     xor       rdx,rdx                       ; the remainder
     div       rbx                           ; divide RAX by 10, remainder in RDX
     or        dl,0x30                       ; convert to ASCII
     mov       byte [rsi],dl                 ; remainder in byte pointed to by RSI
     and       rax, rax                      ; quotient = 0? 
     je        .done                         ; yes, stop converting
     dec       rsi
     jmp       .repeat
.done:
     ret