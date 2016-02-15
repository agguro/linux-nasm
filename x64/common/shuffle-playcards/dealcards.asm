; Name:     dealcards.asm
;
; Purpose:  Create a set of shuffled cards.
;           This demo creates 20 sets of dealed cards

%define TOTAL_CARDS             52              ; no more than 52 cards (except if you like to wait for output)
%define LOOPS                   20              ; depending the loops you want, no more than MAX 64 bits UINT

%if TOTAL_CARDS > 52
     %error "TOTAL_CARDS exceed the maximum for this program (99)"
%elif     

[list -]
     %include "unistd.inc"
[list +]

BITS 64
    
section .data
     
     shuffledcards:     times TOTAL_CARDS db 0
     buffer:            times 2 db 0
     spacer:            db " "
     eol:               db 0x0A

section .text
        global _start
_start:

      xor       r9, r9
.repeatloop:
      mov       rdi, shuffledcards              ; pointer to buffer for the shuffled cards
      mov       rsi, TOTAL_CARDS                ; total cards to shuffle
      call      Shuffle                         ; shuffle the cards
      mov       rdi, shuffledcards              ; pointer to the cards
      mov       rsi, TOTAL_CARDS                ; number of cards to show
      call      ShowCards                       ; show the cards
      mov       rsi, eol
      mov       rdx, 1
      call      WriteString                     ; print end of line
      mov       rdi, shuffledcards
      mov       rsi, TOTAL_CARDS
      call      ClearBuffer                     ; clear the card buffer for a new set of shuffled cards
     
      inc       r9                              ; increment counter for a new set of shuffled cards
      cmp       r9, LOOPS                       ; loops done?
      jne       .repeatloop                     ; not yet

Exit:     
      xor       rdi, rdi                        ; exit program
      mov       rax, SYS_EXIT
      syscall
;----------------------------------------------------------------------------------------
; ClearBuffer
; RDI : pointer to the buffer
; RSI : length of the buffer
;----------------------------------------------------------------------------------------
ClearBuffer:
      mov       rcx, rsi
      xor       al, al
      rep       stosb
      ret
;----------------------------------------------------------------------------------------
; ShowCards
; RDI : pointer to buffer with cards to show
; RSI : number of cards to show
;----------------------------------------------------------------------------------------
ShowCards:
      mov       rcx, rsi                        ; number of cards to show in rcx
      mov       rsi, rdi                        ; pointer to card buffer in rdi
      xor       rax, rax
.next:     
      lodsb
      mov       rbx, 10
      xor       rdx, rdx
      idiv      rbx
      or        dl, "0"
      mov       BYTE[buffer+1], dl
      mov       rdx, 2                          ; length of output
      or        al, "0"
      mov       BYTE[buffer], al
      push      rcx
      push      rsi
      mov       rsi, buffer
      mov       rdx, 3
      call      WriteString
      pop       rsi
      pop       rcx
      loopnz    .next
      ret
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
; WriteString
; RSI : pointer to the string
; RDX : length of the string
;----------------------------------------------------------------------------------------
WriteString:
      mov       rdi, STDOUT
      mov       rax, SYS_WRITE
      syscall
      ret
;----------------------------------------------------------------------------------------    
;----------------------------------------------------------------------------------------
; Shuffle
; RDI : pointer to buffer where the cards must be stored
; RSI : total cards in a deck
;----------------------------------------------------------------------------------------
Shuffle:
     mov        rbx, rsi                        ; TOTAL_CARDS in bl
     xor        r8, r8
.newcard:
     inc        r8                              ; increment counter
     cmp        r8, rbx                         ; TOTAL_CARDS reached?
     jg         .endshuffling
.tryagain:
     rdtsc                                      ; read the time stamp counter
     shr        rax, 3                          ; divide by 8, this an empirical value, without, the algorithm takes a long time for cards = 52, 20
                                                ; still don't know why
     xor        ah, ah
     idiv       bl                              ; tsc divided by TOTAL_OF_CARDS, modulo in RDX
     cmp        ah, 0
     jne        .check
     mov        ah, bl                          ; if remainder is zero, then remainder is the highest card
     ; loop through shuffledcards to check if card is already choosen
.check:     
     mov        rsi, rdi
     mov        rcx, r8
.checknext:     
     lodsb                                      ; AL has the card
     and        al, al
     je         .storecard
     cmp        al, ah
     je         .tryagain
     loop       .checknext
.storecard:     
     dec        rsi
     mov        BYTE[rsi], ah
     jmp        .newcard
.endshuffling:
     ret
;----------------------------------------------------------------------------------------

%endif     