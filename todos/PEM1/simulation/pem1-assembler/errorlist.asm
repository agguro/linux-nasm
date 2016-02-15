; custom errors must begin with number -134
%define ESHOWUSAGE      -134
%define EILEGALOPTION   -135
%define EFILEEXISTS     -136
%define ENOTUSING       -137
%define EILEGALCHAR     -138

; the errors messages list
errorList:
    dq      EPERMerr,ENOENTerr,ESRCHerr,EINTRerr,EIOerr,ENXIOerr,E2BIGerr
    dq      ENOEXECerr,EBADFerr,ECHILDerr,EAGAINerr,ENOMEMerr,EACCESerr
    dq      EFAULTerr,ENOTBLKerr,EBUSYerr,EEXISTerr,EXDEVerr,ENODEVerr
    dq      ENOTDIRerr,EISDIRerr,EINVALerr,ENFILEerr,EMFILEerr,ENOTTYerr
    dq      ETXTBSYerr,EFBIGerr,ENOSPCerr,ESPIPEerr,EROFSerr,EMLINKerr
    dq      EPIPEerr,EDOMerr,ERANGEerr,EDEADLKerr,ENAMETOOLONGerr,ENOLCKerr
    dq      ENOSYSerr,ENOTEMPTYerr,ELOOPerr,EWOULDBLOCKerr,ENOMSGerr
    dq      EIDRMerr,ECHRNGerr,EL2NSYNCerr,EL3HLTerr,EL3RSTerr,ELNRNGerr
    dq      EUNATCHerr,ENOCSIerr,EL2HLTerr,EBADEerr,EBADRerr,EXFULLerr
    dq      ENOANOerr,EBADRQCerr,EBADSLTerr,EDEADLOCKerr,EBFONTerr,ENOSTRerr
    dq      ENODATAerr,ETIMEerr,ENOSRerr,ENONETerr,ENOPKGerr,EREMOTEerr
    dq      ENOLINKerr,EADVerr,ESRMNTerr,ECOMMerr,EPROTOerr,EMULTIHOPerr
    dq      EDOTDOTerr,EBADMSGerr,EOVERFLOWerr,ENOTUNIQerr,EBADFDerr,EREMCHGerr
    dq      ELIBACCerr,ELIBBADerr,ELIBSCNerr,ELIBMAXerr,ELIBEXECerr,EILSEQerr
    dq      ERESTARTerr,ESTRPIPEerr,EUSERSerr,ENOTSOCKerr,EDESTADDRREQerr
    dq      EMSGSIZEerr,EPROTOTYPEerr,ENOPROTOOPTerr,EPROTONOSUPPORTerr
    dq      ESOCKTNOSUPPORTerr,EOPNOTSUPPerr,EPFNOSUPPORTerr,EAFNOSUPPORTerr
    dq      EADDRINUSEerr,EADDRNOTAVAILerr,ENETDOWNerr,ENETUNREACHerr,ENETRESETerr
    dq      ECONNABORTEDerr,ECONNRESETerr,ENOBUFSerr,EISCONNerr,ENOTCONNerr
    dq      ESHUTDOWNerr,ETOOMANYREFSerr,ETIMEDOUTerr,ECONNREFUSEDerr,EHOSTDOWNerr,
    dq      EHOSTUNREACHerr,EALREADYerr,EINPROGRESSerr,ESTALEerr,EUCLEANerr,
    dq      ENOTNAMerr,ENAVAILerr,EISNAMerr,EREMOTEIOerr,EDQUOTerr,ENOMEDIUMerr
    dq      EMEDIUMTYPEerr,ECANCELEDerr,ENOKEYerr,EKEYEXPIREDerr,EKEYREVOKEDerr
    dq      EKEYREJECTEDerr,EOWNERDEADerr,ENOTRECOVERABLEerr,ERFKILLerr,EHWPOISONerr
    
    ; custom errors must begin with number -134
    dq      ESHOWUSAGEerr,EILEGALOPTIONerr,EFILEEXISTSerr,ENOTUSINGerr,EILEGALCHARerr

    EPERMerr:               db      EPERMmsg,10,0
    ENOENTerr:              db      ENOENTmsg,10,0
    ESRCHerr:               db      ESRCHmsg,10,0
    EINTRerr:               db      EINTRmsg,10,0
    EIOerr:                 db      EIOmsg,10,0
    ENXIOerr:               db      ENXIOmsg,10,0
    E2BIGerr:               db      E2BIGmsg,10,0
    ENOEXECerr:             db      ENOEXECmsg,10,0
    EBADFerr:               db      EBADFmsg,10,0
    ECHILDerr:              db      ECHILDmsg,10,0
    EAGAINerr:              db      EAGAINmsg,10,0
    ENOMEMerr:              db      ENOMEMmsg,10,0
    EACCESerr:              db      EACCESmsg,10,0
    EFAULTerr:              db      EFAULTmsg,10,0
    ENOTBLKerr:             db      ENOTBLKmsg,10,0
    EBUSYerr:               db      EBUSYmsg,10,0
    EEXISTerr:              db      EEXISTmsg,10,0
    EXDEVerr:               db      EXDEVmsg,10,0
    ENODEVerr:              db      ENODEVmsg,10,0
    ENOTDIRerr:             db      ENOTDIRmsg,10,0
    EISDIRerr:              db      EISDIRmsg,10,0
    EINVALerr:              db      EINVALmsg,10,0
    ENFILEerr:              db      ENFILEmsg,10,0
    EMFILEerr:              db      EMFILEmsg,10,0
    ENOTTYerr:              db      ENOTTYmsg,10,0
    ETXTBSYerr:             db      ETXTBSYmsg,10,0
    EFBIGerr:               db      EFBIGmsg,10,0
    ENOSPCerr:              db      ENOSPCmsg,10,0
    ESPIPEerr:              db      ESPIPEmsg,10,0
    EROFSerr:               db      EROFSmsg,10,0
    EMLINKerr:              db      EMLINKmsg,10,0
    EPIPEerr:               db      EPIPEmsg,10,0
    EDOMerr:                db      EDOMmsg,10,0
    ERANGEerr:              db      ERANGEmsg,10,0
    EDEADLKerr:             db      EDEADLKmsg,10,0
    ENAMETOOLONGerr:        db      ENAMETOOLONGmsg,10,0
    ENOLCKerr:              db      ENOLCKmsg,10,0
    ENOSYSerr:              db      ENOSYSmsg,10,0
    ENOTEMPTYerr:           db      ENOTEMPTYmsg,10,0
    ELOOPerr:               db      ELOOPmsg,10,0
    EWOULDBLOCKerr:         db      EWOULDBLOCKmsg,10,0
    ENOMSGerr:              db      ENOMSGmsg,10,0
    EIDRMerr:               db      EIDRMmsg,10,0
    ECHRNGerr:              db      ECHRNGmsg,10,0
    EL2NSYNCerr:            db      EL2NSYNCmsg,10,0
    EL3HLTerr:              db      EL3HLTmsg,10,0
    EL3RSTerr:              db      EL3RSTmsg,10,0
    ELNRNGerr:              db      ELNRNGmsg,10,0
    EUNATCHerr:             db      EUNATCHmsg,10,0
    ENOCSIerr:              db      ENOCSImsg,10,0
    EL2HLTerr:              db      EL2HLTmsg,10,0
    EBADEerr:               db      EBADEmsg,10,0
    EBADRerr:               db      EBADRmsg,10,0
    EXFULLerr:              db      EXFULLmsg,10,0
    ENOANOerr:              db      ENOANOmsg,10,0
    EBADRQCerr:             db      EBADRQCmsg,10,0
    EBADSLTerr:             db      EBADSLTmsg,10,0
    EDEADLOCKerr:           db      EDEADLOCKmsg,10,0
    EBFONTerr:              db      EBFONTmsg,10,0
    ENOSTRerr:              db      ENOSTRmsg,10,0
    ENODATAerr:             db      ENODATAmsg,10,0
    ETIMEerr:               db      ETIMEmsg,10,0
    ENOSRerr:               db      ENOSRmsg,10,0
    ENONETerr:              db      ENONETmsg,10,0
    ENOPKGerr:              db      ENOPKGmsg,10,0
    EREMOTEerr:             db      EREMOTEmsg,10,0
    ENOLINKerr:             db      ENOLINKmsg,10,0
    EADVerr:                db      EADVmsg,10,0
    ESRMNTerr:              db      ESRMNTmsg,10,0
    ECOMMerr:               db      ECOMMmsg,10,0
    EPROTOerr:              db      EPROTOmsg,10,0
    EMULTIHOPerr:           db      EMULTIHOPmsg,10,0
    EDOTDOTerr:             db      EDOTDOTmsg,10,0
    EBADMSGerr:             db      EBADMSG,10,0
    EOVERFLOWerr:           db      EOVERFLOWmsg,10,0
    ENOTUNIQerr:            db      ENOTUNIQmsg,10,0
    EBADFDerr:              db      EBADFDmsg,10,0
    EREMCHGerr:             db      EREMCHGmsg,10,0
    ELIBACCerr:             db      ELIBACCmsg,10,0
    ELIBBADerr:             db      ELIBBADmsg,10,0
    ELIBSCNerr:             db      ELIBSCNmsg,10,0
    ELIBMAXerr:             db      ELIBMAXmsg,10,0
    ELIBEXECerr:            db      ELIBEXECmsg,10,0
    EILSEQerr:              db      EILSEQmsg,10,0
    ERESTARTerr:            db      ERESTARTmsg,10,0
    ESTRPIPEerr:            db      ESTRPIPEmsg,10,0
    EUSERSerr:              db      EUSERSmsg,10,0
    ENOTSOCKerr:            db      ENOTSOCKmsg,10,0
    EDESTADDRREQerr:        db      EDESTADDRREQmsg,10,0
    EMSGSIZEerr:            db      EMSGSIZEmsg,10,0
    EPROTOTYPEerr:          db      EPROTOTYPEmsg,10,0
    ENOPROTOOPTerr:         db      ENOPROTOOPTmsg,10,0
    EPROTONOSUPPORTerr:     db      EPROTONOSUPPORTmsg,10,0
    ESOCKTNOSUPPORTerr:     db      ESOCKTNOSUPPORTmsg,10,0
    EOPNOTSUPPerr:          db      EOPNOTSUPPmsg,10,0
    EPFNOSUPPORTerr:        db      EPFNOSUPPORTmsg,10,0
    EAFNOSUPPORTerr:        db      EAFNOSUPPORTmsg,10,0
    EADDRINUSEerr:          db      EADDRINUSEmsg,10,0
    EADDRNOTAVAILerr:       db      EADDRNOTAVAILmsg,10,0
    ENETDOWNerr:            db      ENETDOWNmsg,10,0
    ENETUNREACHerr:         db      ENETUNREACHmsg,10,0
    ENETRESETerr:           db      ENETRESETmsg,10,0
    ECONNABORTEDerr:        db      ECONNABORTEDmsg,10,0
    ECONNRESETerr:          db      ECONNRESETmsg,10,0
    ENOBUFSerr:             db      ENOBUFSmsg,10,0
    EISCONNerr:             db      EISCONNmsg,10,0
    ENOTCONNerr:            db      ENOTCONNmsg,10,0
    ESHUTDOWNerr:           db      ESHUTDOWNmsg,10,0
    ETOOMANYREFSerr:        db      ETOOMANYREFSmsg,10,0
    ETIMEDOUTerr:           db      ETIMEDOUTmsg,10,0
    ECONNREFUSEDerr:        db      ECONNREFUSEDmsg,10,0
    EHOSTDOWNerr:           db      EHOSTDOWNmsg,10,0
    EHOSTUNREACHerr:        db      EHOSTUNREACHmsg,10,0
    EALREADYerr:            db      EALREADYmsg,10,0
    EINPROGRESSerr:         db      EINPROGRESSmsg,10,0
    ESTALEerr:              db      ESTALEmsg,10,0
    EUCLEANerr:             db      EUCLEANmsg,10,0
    ENOTNAMerr:             db      ENOTNAMmsg,10,0
    ENAVAILerr:             db      ENAVAILmsg,10,0
    EISNAMerr:              db      EISNAMmsg,10,0
    EREMOTEIOerr:           db      EREMOTEIOmsg,10,0
    EDQUOTerr:              db      EDQUOTmsg,10,0
    ENOMEDIUMerr:           db      ENOMEDIUMmsg,10,0
    EMEDIUMTYPEerr:         db      EMEDIUMTYPEmsg,10,0
    ECANCELEDerr:           db      ECANCELEDmsg,10,0
    ENOKEYerr:              db      ENOKEYmsg,10,0
    EKEYEXPIREDerr:         db      EKEYEXPIREDmsg,10,0
    EKEYREVOKEDerr:         db      EKEYREVOKEDmsg,10,0
    EKEYREJECTEDerr:        db      EKEYREJECTEDmsg,10,0
    EOWNERDEADerr:          db      EOWNERDEADmsg,10,0
    ENOTRECOVERABLEerr:     db      ENOTRECOVERABLEmsg,10,0
    ERFKILLerr:             db      ERFKILLmsg,10,0
    EHWPOISONerr:           db      EHWPOISONmsg,10,0

    ; custom error messages
    ESHOWUSAGEerr:          db "usage: pem1asm sourcefile -o binaryfile",10,0
    EILEGALOPTIONerr:       db "illegal option, use -o for destination file",10,0
    EFILEEXISTSerr:         db "File exists, overwrite? [Y/n] ",0
    ENOTUSINGerr:           db "Not using destination file name as requested, exiting.",10,0
    EILEGALCHARerr:         db "Illegal character in source ",0
    