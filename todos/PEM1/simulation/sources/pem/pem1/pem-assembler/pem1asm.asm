;Name:          pem1asm.asm
;Build:         see makefile
;Run:           ./pem1asm sourcefile -o binaryfile
;description:   Simple assembler for PEM1
;               -o creates binary file for PEM1 program.  This program cannot be run from any commandline!

BITS 64

[list -]
    %include "pem1asm.inc"
[list +]

; maximum argument count
%define ARGC 4
; custom errors must begin with number -134
%define ESHOWUSAGE 		-134
%define EILEGALOPTION 	-135
%define EFILEEXISTS		-136
%define ENOTUSING		-137
%define EILEGALCHAR		-138

section .bss
    fdsource:           resq    1
    fddestination:      resq    1
    ptrSourceFile:      resq    1
    ptrDestinationFile: resq    1
    charcount:			resq	1
    ;buffer: 			resq	1
    databytes:			resq	1
    ; flags
    sourcelines:		resq	1
    ignoreLine:			resb	1
    firstCharInLine:	resb	1
    
section .data

buffer	db 0,0,0,0,0,0,0,0

; the errors messages list
errorList:
	dq	EPERMerr,ENOENTerr,ESRCHerr,EINTRerr,EIOerr,ENXIOerr,E2BIGerr
	dq	ENOEXECerr,EBADFerr,ECHILDerr,EAGAINerr,ENOMEMerr,EACCESerr
	dq	EFAULTerr,ENOTBLKerr,EBUSYerr,EEXISTerr,EXDEVerr,ENODEVerr
	dq	ENOTDIRerr,EISDIRerr,EINVALerr,ENFILEerr,EMFILEerr,ENOTTYerr
	dq	ETXTBSYerr,EFBIGerr,ENOSPCerr,ESPIPEerr,EROFSerr,EMLINKerr
	dq	EPIPEerr,EDOMerr,ERANGEerr,EDEADLKerr,ENAMETOOLONGerr,ENOLCKerr
	dq	ENOSYSerr,ENOTEMPTYerr,ELOOPerr,EWOULDBLOCKerr,ENOMSGerr
	dq	EIDRMerr,ECHRNGerr,EL2NSYNCerr,EL3HLTerr,EL3RSTerr,ELNRNGerr
	dq	EUNATCHerr,ENOCSIerr,EL2HLTerr,EBADEerr,EBADRerr,EXFULLerr
	dq	ENOANOerr,EBADRQCerr,EBADSLTerr,EDEADLOCKerr,EBFONTerr,ENOSTRerr
	dq	ENODATAerr,ETIMEerr,ENOSRerr,ENONETerr,ENOPKGerr,EREMOTEerr
	dq	ENOLINKerr,EADVerr,ESRMNTerr,ECOMMerr,EPROTOerr,EMULTIHOPerr
	dq	EDOTDOTerr,EBADMSGerr,EOVERFLOWerr,ENOTUNIQerr,EBADFDerr,EREMCHGerr
	dq	ELIBACCerr,ELIBBADerr,ELIBSCNerr,ELIBMAXerr,ELIBEXECerr,EILSEQerr
	dq	ERESTARTerr,ESTRPIPEerr,EUSERSerr,ENOTSOCKerr,EDESTADDRREQerr
	dq	EMSGSIZEerr,EPROTOTYPEerr,ENOPROTOOPTerr,EPROTONOSUPPORTerr
	dq	ESOCKTNOSUPPORTerr,EOPNOTSUPPerr,EPFNOSUPPORTerr,EAFNOSUPPORTerr
	dq	EADDRINUSEerr,EADDRNOTAVAILerr,ENETDOWNerr,ENETUNREACHerr,ENETRESETerr
	dq	ECONNABORTEDerr,ECONNRESETerr,ENOBUFSerr,EISCONNerr,ENOTCONNerr
	dq	ESHUTDOWNerr,ETOOMANYREFSerr,ETIMEDOUTerr,ECONNREFUSEDerr,EHOSTDOWNerr,
	dq	EHOSTUNREACHerr,EALREADYerr,EINPROGRESSerr,ESTALEerr,EUCLEANerr,
	dq	ENOTNAMerr,ENAVAILerr,EISNAMerr,EREMOTEIOerr,EDQUOTerr,ENOMEDIUMerr
	dq	EMEDIUMTYPEerr,ECANCELEDerr,ENOKEYerr,EKEYEXPIREDerr,EKEYREVOKEDerr
	dq	EKEYREJECTEDerr,EOWNERDEADerr,ENOTRECOVERABLEerr,ERFKILLerr,EHWPOISONerr
	; custom errors must begin with number -134
	dq	ESHOWUSAGEerr,EILEGALOPTIONerr,EFILEEXISTSerr,ENOTUSINGerr,EILEGALCHARerr

	EPERMerr:			db	EPERMmsg,10,0
	ENOENTerr:			db	ENOENTmsg,10,0
	ESRCHerr:			db	ESRCHmsg,10,0
	EINTRerr:			db	EINTRmsg,10,0
	EIOerr:				db	EIOmsg,10,0
	ENXIOerr:			db	ENXIOmsg,10,0
	E2BIGerr:			db	E2BIGmsg,10,0
	ENOEXECerr:			db	ENOEXECmsg,10,0
	EBADFerr:			db	EBADFmsg,10,0
	ECHILDerr:			db	ECHILDmsg,10,0
	EAGAINerr:			db	EAGAINmsg,10,0
	ENOMEMerr:			db	ENOMEMmsg,10,0
	EACCESerr:			db	EACCESmsg,10,0
	EFAULTerr:			db	EFAULTmsg,10,0
	ENOTBLKerr:			db	ENOTBLKmsg,10,0
	EBUSYerr:			db	EBUSYmsg,10,0
	EEXISTerr:			db	EEXISTmsg,10,0
	EXDEVerr:			db	EXDEVmsg,10,0
	ENODEVerr:			db	ENODEVmsg,10,0
	ENOTDIRerr:			db	ENOTDIRmsg,10,0
	EISDIRerr:			db	EISDIRmsg,10,0
	EINVALerr:			db	EINVALmsg,10,0
	ENFILEerr:			db	ENFILEmsg,10,0
	EMFILEerr:			db	EMFILEmsg,10,0
	ENOTTYerr:			db	ENOTTYmsg,10,0
	ETXTBSYerr:			db	ETXTBSYmsg,10,0
	EFBIGerr:			db	EFBIGmsg,10,0
	ENOSPCerr:			db	ENOSPCmsg,10,0
	ESPIPEerr:			db	ESPIPEmsg,10,0
	EROFSerr:			db	EROFSmsg,10,0
	EMLINKerr:			db	EMLINKmsg,10,0
	EPIPEerr:			db	EPIPEmsg,10,0
	EDOMerr:			db	EDOMmsg,10,0
	ERANGEerr:			db	ERANGEmsg,10,0
	EDEADLKerr:			db	EDEADLKmsg,10,0
	ENAMETOOLONGerr:	db	ENAMETOOLONGmsg,10,0
	ENOLCKerr:			db	ENOLCKmsg,10,0
	ENOSYSerr:			db	ENOSYSmsg,10,0
	ENOTEMPTYerr:		db	ENOTEMPTYmsg,10,0
	ELOOPerr:			db	ELOOPmsg,10,0
	EWOULDBLOCKerr:		db	EWOULDBLOCKmsg,10,0
	ENOMSGerr:			db	ENOMSGmsg,10,0
	EIDRMerr:			db	EIDRMmsg,10,0
	ECHRNGerr:			db	ECHRNGmsg,10,0
	EL2NSYNCerr:		db	EL2NSYNCmsg,10,0
	EL3HLTerr:			db	EL3HLTmsg,10,0
	EL3RSTerr:			db	EL3RSTmsg,10,0
	ELNRNGerr:			db	ELNRNGmsg,10,0
	EUNATCHerr:			db	EUNATCHmsg,10,0
	ENOCSIerr:			db	ENOCSImsg,10,0
	EL2HLTerr:			db	EL2HLTmsg,10,0
	EBADEerr:			db	EBADEmsg,10,0
	EBADRerr:			db	EBADRmsg,10,0
	EXFULLerr:			db	EXFULLmsg,10,0
	ENOANOerr:			db	ENOANOmsg,10,0
	EBADRQCerr:			db	EBADRQCmsg,10,0
	EBADSLTerr:			db	EBADSLTmsg,10,0
	EDEADLOCKerr:		db	EDEADLOCKmsg,10,0
	EBFONTerr:			db	EBFONTmsg,10,0
	ENOSTRerr:			db	ENOSTRmsg,10,0
	ENODATAerr:			db	ENODATAmsg,10,0
	ETIMEerr:			db	ETIMEmsg,10,0
	ENOSRerr:			db	ENOSRmsg,10,0
	ENONETerr:			db	ENONETmsg,10,0
	ENOPKGerr:			db	ENOPKGmsg,10,0
	EREMOTEerr:			db	EREMOTEmsg,10,0
	ENOLINKerr:			db	ENOLINKmsg,10,0
	EADVerr:			db	EADVmsg,10,0
	ESRMNTerr:			db	ESRMNTmsg,10,0
	ECOMMerr:			db	ECOMMmsg,10,0
	EPROTOerr:			db	EPROTOmsg,10,0
	EMULTIHOPerr:		db	EMULTIHOPmsg,10,0
	EDOTDOTerr:			db	EDOTDOTmsg,10,0
	EBADMSGerr:			db	EBADMSG,10,0
	EOVERFLOWerr:		db	EOVERFLOWmsg,10,0
	ENOTUNIQerr:		db	ENOTUNIQmsg,10,0
	EBADFDerr:			db	EBADFDmsg,10,0
	EREMCHGerr:			db	EREMCHGmsg,10,0
	ELIBACCerr:			db	ELIBACCmsg,10,0
	ELIBBADerr:			db	ELIBBADmsg,10,0
	ELIBSCNerr:			db	ELIBSCNmsg,10,0
	ELIBMAXerr:			db	ELIBMAXmsg,10,0
	ELIBEXECerr:		db	ELIBEXECmsg,10,0
	EILSEQerr:			db	EILSEQmsg,10,0
	ERESTARTerr:		db	ERESTARTmsg,10,0
	ESTRPIPEerr:		db	ESTRPIPEmsg,10,0
	EUSERSerr:			db	EUSERSmsg,10,0
	ENOTSOCKerr:		db	ENOTSOCKmsg,10,0
	EDESTADDRREQerr:	db	EDESTADDRREQmsg,10,0
	EMSGSIZEerr:		db	EMSGSIZEmsg,10,0
	EPROTOTYPEerr:		db	EPROTOTYPEmsg,10,0
	ENOPROTOOPTerr:		db	ENOPROTOOPTmsg,10,0
	EPROTONOSUPPORTerr:	db	EPROTONOSUPPORTmsg,10,0
	ESOCKTNOSUPPORTerr:	db	ESOCKTNOSUPPORTmsg,10,0
	EOPNOTSUPPerr:		db	EOPNOTSUPPmsg,10,0
	EPFNOSUPPORTerr:	db	EPFNOSUPPORTmsg,10,0
	EAFNOSUPPORTerr:	db	EAFNOSUPPORTmsg,10,0
	EADDRINUSEerr:		db	EADDRINUSEmsg,10,0
	EADDRNOTAVAILerr:	db	EADDRNOTAVAILmsg,10,0
	ENETDOWNerr:		db	ENETDOWNmsg,10,0
	ENETUNREACHerr:		db	ENETUNREACHmsg,10,0
	ENETRESETerr:		db	ENETRESETmsg,10,0
	ECONNABORTEDerr:	db	ECONNABORTEDmsg,10,0
	ECONNRESETerr:		db	ECONNRESETmsg,10,0
	ENOBUFSerr:			db	ENOBUFSmsg,10,0
	EISCONNerr:			db	EISCONNmsg,10,0
	ENOTCONNerr:		db	ENOTCONNmsg,10,0
	ESHUTDOWNerr:		db	ESHUTDOWNmsg,10,0
	ETOOMANYREFSerr:	db	ETOOMANYREFSmsg,10,0
	ETIMEDOUTerr:		db	ETIMEDOUTmsg,10,0
	ECONNREFUSEDerr:	db	ECONNREFUSEDmsg,10,0
	EHOSTDOWNerr:		db	EHOSTDOWNmsg,10,0
	EHOSTUNREACHerr:	db	EHOSTUNREACHmsg,10,0
	EALREADYerr:		db	EALREADYmsg,10,0
	EINPROGRESSerr:		db	EINPROGRESSmsg,10,0
	ESTALEerr:			db	ESTALEmsg,10,0
	EUCLEANerr:			db	EUCLEANmsg,10,0
	ENOTNAMerr:			db	ENOTNAMmsg,10,0
	ENAVAILerr:			db	ENAVAILmsg,10,0
	EISNAMerr:			db	EISNAMmsg,10,0
	EREMOTEIOerr:		db	EREMOTEIOmsg,10,0
	EDQUOTerr:			db	EDQUOTmsg,10,0
	ENOMEDIUMerr:		db	ENOMEDIUMmsg,10,0
	EMEDIUMTYPEerr:		db	EMEDIUMTYPEmsg,10,0
	ECANCELEDerr:		db	ECANCELEDmsg,10,0
	ENOKEYerr:			db	ENOKEYmsg,10,0
	EKEYEXPIREDerr:		db	EKEYEXPIREDmsg,10,0
	EKEYREVOKEDerr:		db	EKEYREVOKEDmsg,10,0
	EKEYREJECTEDerr:	db	EKEYREJECTEDmsg,10,0
	EOWNERDEADerr:		db	EOWNERDEADmsg,10,0
	ENOTRECOVERABLEerr:	db	ENOTRECOVERABLEmsg,10,0
	ERFKILLerr:			db	ERFKILLmsg,10,0
	EHWPOISONerr:		db	EHWPOISONmsg,10,0
	; custom error messages
    ESHOWUSAGEerr:      db  "usage: pem1asm sourcefile -o binaryfile",10,0
    EILEGALOPTIONerr:	db	"ilegal option, use -o for destination file",10,0
    EFILEEXISTSerr:		db  "File exists, overwrite? [Y/n] ",0
    ENOTUSINGerr:		db	"Not using destination file name as requested, exiting.",10,0
    EILEGALCHARerr:		db	"- Illegal character in sourceline ",10,0
    
    COLONmsg:			db	": "
    COLONmsg.length:	equ	$-COLONmsg
    CRLFmsg:			db	10
    CRLFmsg.length:		equ $-CRLFmsg
    
    addresses:			db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    binary:             db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0			;db		"TEST BINARY FILE",10
    binary.length:		equ		$-binary
        
    ; stat structure
    STAT stat
	TERMIOS termios
	
section .text

global _start
_start:

    pop     rax             	; argc
    cmp     rax, ARGC
    je      parseCommandLine	; argumentcount is correct
    jmp		usage
parseCommandLine:    
    pop     rax					; pointer to programname
    pop     rsi					; pointer to sourcefilename
    pop     rax					; read option -o
    pop		rdi					; pointer to destination file
    mov     ax, WORD[rax]
    cmp     ax, "-o"			; option -o?
    je      checkFiles
    mov		rax, EILEGALOPTION
    call	getError
    call	PrintSTDERR
usage:
    mov		rax, ESHOWUSAGE
    call	getError
    call	PrintSTDERR
    jmp		exit

checkFiles:
    ; RSI has the pointer to the sourcefile
    ; RDI has the pointer to the destinationfile
    
    mov     QWORD[ptrSourceFile], rsi
    mov     QWORD[ptrDestinationFile], rdi
    
    ; Open the source file
    mov     rdi, QWORD [ptrSourceFile]
    mov     rsi, O_RDONLY
    mov     rax, SYS_OPEN
    syscall
    cmp     rax, 0
    jg      gotfdsource							; we got a filedescriptor
    mov		rsi, QWORD [ptrSourceFile]
    call	PrintFileError
    jmp		exit
gotfdsource:
	; save the descriptor for later use
    mov     [fdsource], rax
    
    ; try to open the destination file
    mov     rdi, QWORD[ptrDestinationFile]
    mov     rsi, O_RDWR							; open in read/write mode
    mov     rax, SYS_OPEN
    syscall
    cmp     rax, 0              				; file exists?
    jl      createfile          				; file doesn't exists, create it
    
    mov		QWORD[fddestination], rax			; save fd
    mov		rsi, QWORD [ptrDestinationFile]
    mov		rax, EFILEEXISTS		
    call	PrintFileError
    
continueWaiting:
    call	WaitForKeyPress
    cmp		al,"Y"
    je		gotAnswer
    cmp		al,"n"
    jne		continueWaiting      
gotAnswer:
	push	rax						; save the answer
	; print the users answer
	mov		rsi, buffer
	mov		rdx, 1
	call	Print
	mov		rsi, CRLFmsg
	call	Print
    pop		rax						; retrieve the answer
    cmp		al,"Y"
    je		startAssembling
    
    ; we may not use the existing destination file,
    ; inform user and quit
    mov		rsi, QWORD[ptrDestinationFile]
    mov		rax, ENOTUSING
    call	PrintFileError
    jmp		closeDestinationFile
    
createfile:
    ; file doesn't exists, create the file with permissions 644 octal,
    ; taking umask in consideration
    mov     rdi, QWORD [ptrDestinationFile]
    mov     rsi, 644q              ; access mode
    mov     rax, SYS_CREAT
    syscall
    ; if we got a file descriptor then the file is created
    cmp     rax, 0
    jge     savefddestination
    ; we got an error creating the file, inform user and close fd source
    mov		rsi, QWORD [ptrDestinationFile]
    call	PrintFileError
    jmp		closeSourceFile
    
savefddestination:
    mov		QWORD[fddestination], rax
    
    ; START OF ASSEMBLING
    
startAssembling:

; read the length of the source file
	mov		rdi, QWORD[fdsource]
	mov		rsi, stat
	mov		rax, SYS_FSTAT
	syscall
	cmp		rax, 0
	jl		fileStatError
            
readFileSize:
	mov   	rcx, QWORD [stat.st_size]   	; get the file size
	mov		BYTE[firstCharInLine], 1		; set first char in line true
	mov		BYTE[ignoreLine], 0				; set ignore line false
	; start reading file contents
      
readFileContents:
	    
	; for all bytes in file do
	push  	rcx
	mov   	rsi, buffer
	mov   	rdx, 1          				; read one char at the time
	mov   	rax, SYS_READ
	syscall
	cmp		rax, 0
	jle		fileStatError					; in case of an error treat it as a file status error
      
	; no read error, start parsing
	mov		al, BYTE[buffer]
	cmp		al, 0x0A
	je		eol
	cmp		al, 0x0D  
	jne		noeol
eol:
	add		QWORD[sourcelines],1
	mov		QWORD[charcount],1
	mov		BYTE[ignoreLine], 0				; if EOL in remark line set ignore line false
	jmp		readNextByte     
noeol:
	cmp		al, '#'							; if remark, ignore all following chars until 0x0A is met
	jne		nocomment						; else try interpreting
	mov		BYTE[ignoreLine], 1				; set ignore line true
	jmp		readNextByte
		  
nocomment:
	cmp		BYTE[ignoreLine],1
	je		readNextByte					; if ignore line true then don't parse
											; else start interpreting									
	cmp		al, ' '							
	je		readNextByte					; if a space is met, read the next byte

	cmp		al, 0x09						
	je		readNextByte					; if a tab is met, read the next byte

position1:
	; must be 'R' followed by hexadecimal digit
	cmp		QWORD[charcount],1
	jne		position2
	cmp		al, 'R'
	jne		illegalChar
	inc		QWORD[charcount]
	call	PrintChar
	jmp		readNextByte

position2:
	; must be hexadecimal digit
	cmp 	QWORD[charcount],2
	jne		position3
	call	checkHexDigit
	jc		illegalChar
	inc		QWORD[charcount]
	; check the bytes in addresses for R, if already set, print a warning
	
	call	PrintChar
	jmp		readNextByte
			
position3:
	; read rest of mnemonic
	cmp		QWORD[charcount], 3
	jne		position4
	pop		rcx
	sub		rcx, 2
	push	rcx
	mov		rdx, 2
	mov		rsi, buffer+1
	mov		rax, SYS_READ
	syscall
	cmp		rax, 0
	jle		fileStatError					; in case of an error treat it as a file status error
	mov		rax, QWORD[buffer]
	cmp		rax, 'LDA'
	je		legalMnemonic
	cmp		rax, 'ADD'
	je		legalMnemonic
	cmp		rax, 'SUB'
	je		legalMnemonic
	cmp		rax, 'OUT'
	je		legalMnemonic
	cmp		rax, 'HLT'
	je		legalMnemonic
	; beside an mnemonic, the memory address can contain only data, this must be an 8 bit binary number
	; preseeded with the .DB or .db directive
	cmp		rax, '.DB'
	jne		illegalChar
	mov		QWORD[databytes],1
			
legalMnemonic:
	add		QWORD[charcount],1
	call	PrintMnemonic
	jmp		readNextByte

position4:
	; must be hexadecimal digit
	cmp 	QWORD[charcount],4
	jne		position5			
	call	checkHexDigit
	jc		illegalChar
	inc		QWORD[charcount]
	call	PrintChar
	jmp		readNextByte
		
position5:
	cmp		QWORD[databytes], 1
	jne		illegalChar
	cmp 	QWORD[charcount], 5
	jne		illegalChar
	call	checkHexDigit
	jc		illegalChar		
	inc		QWORD[charcount]
	call	PrintChar
	jmp		readNextByte

; we may never get here
illegalChar:
	mov		rax, EILEGALCHAR
	call	getError
	call	PrintSTDOUT
	jmp   	closeDestinationFile  

readNextByte:	  
	pop		rcx
	dec		rcx
	cmp		rcx, 0
	jne		readFileContents  


; END OF ASSEMBLING
		
endAssembling:
    ; save the assembled binary
    mov		rdi, QWORD[fddestination]
    mov		rsi, binary
    mov		rdx, binary.length
    mov		rax, SYS_WRITE
    syscall
	jmp		closeDestinationFile
	
fileStatError:
	mov		rsi, QWORD[ptrSourceFile]
	call	PrintFileError
	
deleteDestinationFile:	
	mov		rdi, QWORD[ptrDestinationFile]
	mov		rax, SYS_UNLINK
	syscall
	cmp		rax, 0
	jge		closeDestinationFile
	mov		rsi, QWORD[ptrDestinationFile]
	call	PrintFileError

closeDestinationFile:
	mov		rdi, QWORD[fddestination]
	mov		rax, SYS_CLOSE
	syscall
closeSourceFile:	
	mov		rdi, QWORD[fdsource]
	mov		rax, SYS_CLOSE
	syscall
	   
exit:        
    mov     rdi, 0
    mov     rax, SYS_EXIT
    syscall
;*********************************************
; END PROGRAM
;*********************************************

; SUBROUTINES

checkHexDigit:
	; AL has the number, on return if Carry is set the digit isn't a hexdigit
	stc							; assume wrong digit
	cmp		al, '0'
	jl		.illegal
	cmp		al,	'9'
	jbe		.isdigit
	and		al, 4Fh				; make capital A...F
	cmp		al, 'A'
	jl		.illegal
	cmp		al, 'F'
	ja		.illegal
.isdigit:
	clc
.illegal:
	ret
	
getError:
	; RAX has the error number
	neg		rax						; get positive value
	dec		rax						; decrement to adjust in list
	shl		rax, 3					; multiplicate with 8 (8 bytes = 64 bits)
	mov		rsi, [errorList+rax] 	; load the error message pointer
	call	getStringLength
	ret
	
getStringLength:
	; RSI has the pointer to the string	
	push	rax
	push	rcx
	push	rdi
	mov		rdi, rsi
	mov     rcx, -1					; calculate the length
    xor     al, al            		; search for terminating 0
    repne   scasb
    neg     rcx
    dec     rcx
    mov		rdx, rcx				; length in RDX
    pop		rdi
    pop		rcx
    pop		rax
	ret

PrintFileError:
	; RAX has the errornumber
	; RSI has the pointer to the filename
	push	rsi
	push	rax
	push	rax	      
    call	getStringLength
    call	PrintSTDERR
    mov		rsi, COLONmsg
    mov		rdx, COLONmsg.length
    call	PrintSTDERR
    pop		rax
    call	getError
    call	PrintSTDERR
	pop		rax
	pop		rsi
	ret

PrintChar:
	  mov   rdx, 1
	  call	PrintBuffer
	  ret
	  
PrintMnemonic:
	  mov   rdx, 3
	  call	PrintBuffer
	  ret
	  	  
PrintBuffer:	  
	  push	rcx
	  push	rsi
	  push	rdx
	  mov	rsi, buffer
	  call	PrintSTDOUT
	  pop	rdx
	  pop	rsi
	  pop	rcx
	  ret

PrintSTDERR:
	  ; RSI has the pointer to the string
	  ; RDX has the length to the string
	  push	rdi
	  mov	rdi, STDERR
	  call	Print
	  pop	rdi
	  ret
      
PrintSTDOUT:
	  push	rdi
	  mov	rdi, STDOUT
	  call	Print
	  pop	rdi
	  ret
	  
Print:	  
      push  rax
      push  rcx
      mov   rax, SYS_WRITE
      syscall
      pop   rcx
      pop   rax
      ret		

WaitForKeyPress:
	; read a key without echoing it back and put the key in a buffer
	; the buffer is 1 byte long
	call    TermIOS.Canonical.OFF      ; switch canonical mode off
    call    TermIOS.Echo.OFF           ; no echo
    mov     rsi, buffer
    mov     rdx, 1
    mov     rdi, STDIN
    mov     rax, SYS_READ
    syscall
    ; Don't forget to switch canonical mode en echo back on
    call    TermIOS.Canonical.ON       ; switch canonical mode back on
    call    TermIOS.Echo.ON            ; echo on
    mov		al, BYTE[buffer]
    ret
    
; **********************************************************************************************    
; TERMIOS functions:
; TermIOS.Canonical.ON        : switch canonical mode on
; TermIOS.Canonical.OFF       : switch canonical mode off
; TermIOS.Echo.ON             : switch echo mode on
; TermIOS.Echo.OFF            : switch echo mode off
; TermIOS.LocalModeFlag.SET   : set the localmode flag described in RAX
; TermIOS.LocalModeFlag.CLEAR : clear the localmode flag described in RAX 
; TermIOS.STDIN.Read          : Read the TERMIO flags
; TermIOS.STDIN.Write         : Write the TERMIO flags
; TermIOS.IOCTL               : Read or write the localmode flags to or from TERMIOS
; **********************************************************************************************

TermIOS.Canonical:
.ON:
    mov     rax, ICANON
    jmp     TermIOS.LocalModeFlag.SET
.OFF:
    mov     rax,ICANON
    jmp     TermIOS.LocalModeFlag.CLEAR
TermIOS.Echo:
.ON:
    mov     rax,ECHO
    jmp     TermIOS.LocalModeFlag.SET
.OFF:
    mov     rax,ECHO
    jmp     TermIOS.LocalModeFlag.CLEAR
TermIOS.LocalModeFlag:
.SET:
    call    TermIOS.STDIN.READ
    or      dword [termios.c_lflag], eax
    call    TermIOS.STDIN.WRITE
    ret
.CLEAR:
    call    TermIOS.STDIN.READ
    not     eax
    and     [termios.c_lflag], eax
    call    TermIOS.STDIN.WRITE
    ret
; subroutine for all TCGETS operation on the syscall IOCTL
; the original value of RCX is restored on exit
TermIOS.STDIN:
.READ:
    mov     rsi, TCGETS
    jmp     TermIOS.IOCTL
; subroutine for all TCSETS operation on the syscall IOCTL
; the original value of RCX is restored on exit
.WRITE:
    mov     rsi, TCSETS
; subroutine for operations on the syscall IOCTL for STDIN
; all registers are restored to their original values on exit of the subroutine
TermIOS.IOCTL:
    push    rax             ; we need to store RAX or TermIOS.LocalFlag functions fail
    mov     rax, SYS_IOCTL
    mov     rdi, STDIN
    mov     rdx, termios
    syscall
    pop     rax
    ret
