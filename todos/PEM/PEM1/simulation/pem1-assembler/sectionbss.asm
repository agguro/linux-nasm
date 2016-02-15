section .bss
    fdsource:           resq    1
    fddestination:      resq    1
    ptrSourceFile:      resq    1
    ptrDestinationFile: resq    1
    buffer:             resb    1
    ; flags
    sourcelines:        resq    1
    ignoreLine:         resb    1
    firstCharInLine:    resb    1
    charInLine:         resq    1
    decbuffer:          resb    39
    .length:            equ     $-decbuffer