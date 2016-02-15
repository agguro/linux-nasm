%ifndef _ASM_ERRNO_INC_
%define _ASM_ERRNO_INC_

  %define   EPERM           	  -1       ; Operation not permitted 
  %define   ENOENT          	  -2       ; No such file or directory 
  %define   ESRCH           	  -3       ; No such process 
  %define   EINTR           	  -4       ; Interrupted system call 
  %define   EIO             	  -5       ; I/O error 
  %define   ENXIO           	  -6       ; No such device or address 
  %define   E2BIG           	  -7       ; Argument list too long 
  %define   ENOEXEC         	  -8       ; Exec format error 
  %define   EBADF           	  -9       ; Bad file number 
  %define   ECHILD         		 -10       ; No child processes 
  %define   EAGAIN         		 -11       ; Try again 
  %define   ENOMEM         		 -12       ; Out of memory 
  %define   EACCES         		 -13       ; Permission denied 
  %define   EFAULT         		 -14       ; Bad address 
  %define   ENOTBLK        		 -15       ; Block device required 
  %define   EBUSY          		 -16       ; Device or resource busy 
  %define   EEXIST         		 -17       ; File exists 
  %define   EXDEV          		 -18       ; Cross-device link 
  %define   ENODEV         		 -19       ; No such device 
  %define   ENOTDIR        		 -20       ; Not a directory 
  %define   EISDIR         		 -21       ; Is a directory 
  %define   EINVAL         		 -22       ; Invalid argument 
  %define   ENFILE         		 -23       ; File table overflow 
  %define   EMFILE         		 -24       ; Too many open files 
  %define   ENOTTY         		 -25       ; Not a typewriter 
  %define   ETXTBSY        		 -26       ; Text file busy 
  %define   EFBIG          		 -27       ; File too large 
  %define   ENOSPC         		 -28       ; No space left on device 
  %define   ESPIPE         		 -29       ; Illegal seek 
  %define   EROFS          		 -30       ; Read-only file system 
  %define   EMLINK        		 -31       ; Too many links 
  %define   EPIPE         		 -32       ; Broken pipe 
  %define   EDOM          		 -33       ; Math argument out of domain of func 
  %define   ERANGE        		 -34       ; Math result not representable 
  %define   EDEADLK       		 -35       ; Resource deadlock would occur
  %define   ENAMETOOLONG  		 -36       ; File name too long
  %define   ENOLCK         		 -37       ; No record locks available
  %define   ENOSYS        		 -38       ; Function not implemented
  %define   ENOTEMPTY     		 -39       ; Directory not empty
  %define   ELOOP         		 -40       ; Too many symbolic links encountered
  %define   EWOULDBLOCK   		 -41       ; Operation would block, same as EAGAIN
  %define   ENOMSG        		 -42       ; No message of desired type
  %define   EIDRM         		 -43       ; Identifier removed
  %define   ECHRNG        		 -44       ; Channel number out of range
  %define   EL2NSYNC      		 -45       ; Level 2 not synchronized
  %define   EL3HLT        		 -46       ; Level 3 halted
  %define   EL3RST        		 -47       ; Level 3 reset
  %define   ELNRNG        		 -48       ; Link number out of range
  %define   EUNATCH       		 -49       ; Protocol driver not attached
  %define   ENOCSI        		 -50       ; No CSI structure available
  %define   EL2HLT        		 -51       ; Level 2 halted
  %define   EBADE         		 -52       ; Invalid exchange
  %define   EBADR         		 -53       ; Invalid request descriptor
  %define   EXFULL        		 -54       ; Exchange full
  %define   ENOANO        		 -55       ; No anode
  %define   EBADRQC       		 -56       ; Invalid request code
  %define   EBADSLT       		 -57       ; Invalid slot
  %define   EDEADLOCK     		 -35       ; Resource deadlock would occur, same as EDEADLK
  %define   EBFONT        		 -59       ; Bad font file format
  %define   ENOSTR        		 -60       ; Device not a stream
  %define   ENODATA       		 -61       ; No data available
  %define   ETIME         		 -62       ; Timer expired
  %define   ENOSR         		 -63       ; Out of streams resources
  %define   ENONET        		 -64       ; Machine is not on the network
  %define   ENOPKG        		 -65       ; Package not installed
  %define   EREMOTE       		 -66       ; Object is remote
  %define   ENOLINK       		 -67       ; Link has been severed
  %define   EADV          		 -68       ; Advertise error
  %define   ESRMNT       		 -69       ; Srmount error
  %define   ECOMM        	 	 -70       ; Communication error on send
  %define   EPROTO        		 -71       ; Protocol error
  %define   EMULTIHOP            -72       ; Multihop attempted
  %define   EDOTDOT       		 -73       ; RFS specific error
  %define   EBADMSG       		 -74       ; Not a data message
  %define   EOVERFLOW     		 -75       ; Value too large for defined data type
  %define   ENOTUNIQ      		 -76       ; Name not unique on network
  %define   EBADFD        		 -77       ; File descriptor in bad state
  %define   EREMCHG       		 -78       ; Remote address changed
  %define   ELIBACC       		 -79       ; Can not access a needed shared library
  %define   ELIBBAD       		 -80       ; Accessing a corrupted shared library
  %define   ELIBSCN       		 -81       ; .lib section in a.out corrupted
  %define   ELIBMAX       		 -82       ; Attempting to link in too many shared libraries
  %define   ELIBEXEC      		 -83       ; Cannot exec a shared library directly
  %define   EILSEQ        		 -84       ; Illegal byte sequence
  %define   ERESTART      		 -85       ; Interrupted system call should be restarted
  %define   ESTRPIPE      		 -86       ; Streams pipe error
  %define   EUSERS        		 -87       ; Too many users
  %define   ENOTSOCK       		 -88       ; Socket operation on non-socket
  %define   EDESTADDRREQ	     -89       ; Destination address required
  %define   EMSGSIZE       		 -90       ; Message too long
  %define   EPROTOTYPE     		 -91       ; Protocol wrong type for socket
  %define   ENOPROTOOPT    		 -92       ; Protocol not available
  %define   EPROTONOSUPPORT      -93       ; Protocol not supported
  %define   ESOCKTNOSUPPORT      -94       ; Socket type not supported
  %define   EOPNOTSUPP     		 -95       ; Operation not supported on transport endpoint
  %define   EPFNOSUPPORT   		 -96       ; Protocol family not supported
  %define   EAFNOSUPPORT   		 -97       ; Address family not supported by protocol
  %define   EADDRINUSE     		 -98       ; Address already in use
  %define   EADDRNOTAVAIL  		 -99       ; Cannot assign requested address
  %define   ENETDOWN       		-100       ; Network is down
  %define   ENETUNREACH    		-101       ; Network is unreachable
  %define   ENETRESET      		-102       ; Network dropped connection because of reset
  %define   ECONNABORTED   		-103       ; Software caused connection abort
  %define   ECONNRESET     		-104       ; Connection reset by peer
  %define   ENOBUFS        		-105       ; No buffer space available
  %define   EISCONN        		-106       ; Transport endpoint is already connected
  %define   ENOTCONN       		-107       ; Transport endpoint is not connected
  %define   ESHUTDOWN      		-108       ; Cannot send after transport endpoint shutdown
  %define   ETOOMANYREFS   		-109       ; Too many references: cannot splice
  %define   ETIMEDOUT      		-110       ; Connection timed out
  %define   ECONNREFUSED   		-111       ; Connection refused
  %define   EHOSTDOWN      		-112       ; Host is down
  %define   EHOSTUNREACH   		-113       ; No route to host
  %define   EALREADY       		-114       ; Operation already in progress
  %define   EINPROGRESS    		-115       ; Operation now in progress
  %define   ESTALE         		-116       ; Stale NFS file handle
  %define   EUCLEAN        		-117       ; Structure needs cleaning
  %define   ENOTNAM        		-118       ; Not a XENIX named type file
  %define   ENAVAIL        		-119       ; No XENIX semaphores available
  %define   EISNAM         		-120       ; Is a named type file
  %define   EREMOTEIO      		-121       ; Remote I/O error
  %define   EDQUOT         		-122       ; Quota exceeded
  %define   ENOMEDIUM      		-123       ; No medium found
  %define   EMEDIUMTYPE    		-124       ; Wrong medium type
  %define   ECANCELED      		-125       ; Operation Canceled
  %define   ENOKEY         		-126       ; Required key not available
  %define   EKEYEXPIRED    		-127       ; Key has expired
  %define   EKEYREVOKED    		-128       ; Key has been revoked
  %define   EKEYREJECTED   		-129       ; Key was rejected by service
  %define   EOWNERDEAD          -130       ; Owner died
  %define   ENOTRECOVERABLE     -131  	   ; State not recoverable
  %define   ERFKILL             -132 	   ; Operation not possible due to RF-kill
  %define   EHWPOISON           -133       ; Memory page has hardware error
  
  ; error text messages
  
  %define   EPERMmsg    		"Operation not permitted"
  %define   ENOENTmsg   		"No such file or directory"
  %define   ESRCHmsg    		"No such process"
  %define   EINTRmsg    		"Interrupted system call"
  %define   EIOmsg      		"I/O error"
  %define   ENXIOmsg			"No such device or address"
  %define   E2BIGmsg			"Argument list too long"
  %define   ENOEXECmsg  		"Exec format error"
  %define   EBADFmsg			"Bad file number"
  %define   ECHILDmsg			"No child processes"
  %define   EAGAINmsg			"Try again"
  %define   ENOMEMmsg			"Out of memory"
  %define   EACCESmsg			"Permission denied"
  %define   EFAULTmsg			"Bad address"
  %define   ENOTBLKmsg			"Block device required"
  %define   EBUSYmsg			"Device or resource busy"
  %define   EEXISTmsg			"File exists"
  %define   EXDEVmsg			"Cross-device link"
  %define   ENODEVmsg			"No such device"
  %define   ENOTDIRmsg			"Not a directory"
  %define   EISDIRmsg			"Is a directory"
  %define   EINVALmsg			"Invalid argument"
  %define   ENFILEmsg			"File table overflow"
  %define   EMFILEmsg			"Too many open files"
  %define   ENOTTYmsg			"Not a typewriter"
  %define   ETXTBSYmsg			"Text file busy"
  %define   EFBIGmsg			"File too large"
  %define   ENOSPCmsg			"No space left on device"
  %define   ESPIPEmsg			"Illegal seek"
  %define   EROFSmsg			"Read-only file system"
  %define   EMLINKmsg			"Too many links"
  %define   EPIPEmsg			"Broken pipe"
  %define   EDOMmsg				"Math argument out of domain of func"
  %define   ERANGEmsg			"Math result not representable"
  %define   EDEADLKmsg			"Resource deadlock would occur"
  %define   ENAMETOOLONGmsg     "File name too long"
  %define   ENOLCKmsg           "No record locks available"
  %define   ENOSYSmsg			"Function not implemented"
  %define   ENOTEMPTYmsg		"Directory not empty"
  %define   ELOOPmsg			"Too many symbolic links encountered"
  %define   EWOULDBLOCKmsg		"Operation would block"			; same as EAGAIN"
  %define   ENOMSGmsg			"No message of desired type"
  %define   EIDRMmsg			"Identifier removed"
  %define   ECHRNGmsg			"Channel number out of range"
  %define   EL2NSYNCmsg			"Level 2 not synchronized"
  %define   EL3HLTmsg			"Level 3 halted"
  %define   EL3RSTmsg			"Level 3 reset"
  %define   ELNRNGmsg			"Link number out of range"
  %define   EUNATCHmsg			"Protocol driver not attached"
  %define   ENOCSImsg			"No CSI structure available"
  %define   EL2HLTmsg			"Level 2 halted"
  %define   EBADEmsg			"Invalid exchange"
  %define   EBADRmsg			"Invalid request descriptor"
  %define   EXFULLmsg			"Exchange full"
  %define   ENOANOmsg			"No anode"
  %define   EBADRQCmsg			"Invalid request code"
  %define   EBADSLTmsg			"Invalid slot"
  %define   EDEADLOCKmsg		"Resource deadlock would occur"  ; same as EDEADLK
  %define   EBFONTmsg			"Bad font file format"
  %define   ENOSTRmsg			"Device not a stream"
  %define   ENODATAmsg			"No data available"
  %define   ETIMEmsg			"Timer expired"
  %define   ENOSRmsg			"Out of streams resources"
  %define   ENONETmsg			"Machine is not on the network"
  %define   ENOPKGmsg			"Package not installed"
  %define   EREMOTEmsg			"Object is remote"
  %define   ENOLINKmsg			"Link has been severed"
  %define   EADVmsg				"Advertise error"
  %define   ESRMNTmsg			"Srmount error"
  %define   ECOMMmsg			"Communication error on send"
  %define   EPROTOmsg			"Protocol error"
  %define   EMULTIHOPmsg		"Multihop attempted"
  %define   EDOTDOTmsg			"RFS specific error"
  %define   EBADMSG				"Not a data message"
  %define   EOVERFLOWmsg		"Value too large for defined data type"
  %define   ENOTUNIQmsg			"Name not unique on network"
  %define   EBADFDmsg			"File descriptor in bad state"
  %define   EREMCHGmsg			"Remote address changed"
  %define   ELIBACCmsg			"Can not access a needed shared library"
  %define   ELIBBADmsg			"Accessing a corrupted shared library"
  %define   ELIBSCNmsg			".lib section in a.out corrupted"
  %define   ELIBMAXmsg			"Attempting to link in too many shared libraries"
  %define   ELIBEXECmsg			"Cannot exec a shared library directly"
  %define   EILSEQmsg			"Illegal byte sequence"
  %define   ERESTARTmsg			"Interrupted system call should be restarted"
  %define   ESTRPIPEmsg			"Streams pipe error"
  %define   EUSERSmsg			"Too many users"
  %define   ENOTSOCKmsg			"Socket operation on non-socket"
  %define   EDESTADDRREQmsg		"Destination address required"
  %define   EMSGSIZEmsg			"Message too long"
  %define   EPROTOTYPEmsg		"Protocol wrong type for socket"
  %define   ENOPROTOOPTmsg		"Protocol not available"
  %define   EPROTONOSUPPORTmsg	"Protocol not supported"
  %define   ESOCKTNOSUPPORTmsg	"Socket type not supported"
  %define   EOPNOTSUPPmsg		"Operation not supported on transport endpoint"
  %define   EPFNOSUPPORTmsg		"Protocol family not supported"
  %define   EAFNOSUPPORTmsg		"Address family not supported by protocol"
  %define   EADDRINUSEmsg		"Address already in use"
  %define   EADDRNOTAVAILmsg	"Cannot assign requested address"
  %define   ENETDOWNmsg			"Network is down"
  %define   ENETUNREACHmsg		"Network is unreachable"
  %define   ENETRESETmsg		"Network dropped connection because of reset"
  %define   ECONNABORTEDmsg		"Software caused connection abort"
  %define   ECONNRESETmsg		"Connection reset by peer"
  %define   ENOBUFSmsg			"No buffer space available"
  %define   EISCONNmsg			"Transport endpoint is already connected"
  %define   ENOTCONNmsg			"Transport endpoint is not connected"
  %define   ESHUTDOWNmsg		"Cannot send after transport endpoint shutdown"
  %define   ETOOMANYREFSmsg		"Too many references: cannot splice"
  %define   ETIMEDOUTmsg		"Connection timed out"
  %define   ECONNREFUSEDmsg		"Connection refused"
  %define   EHOSTDOWNmsg		"Host is down"
  %define   EHOSTUNREACHmsg		"No route to host"
  %define   EALREADYmsg			"Operation already in progress"
  %define   EINPROGRESSmsg		"Operation now in progress"
  %define   ESTALEmsg			"Stale NFS file handle"
  %define   EUCLEANmsg			"Structure needs cleaning"
  %define   ENOTNAMmsg			"Not a XENIX named type file"
  %define   ENAVAILmsg			"No XENIX semaphores available"
  %define   EISNAMmsg			"Is a named type file"
  %define   EREMOTEIOmsg		"Remote I/O error"
  %define   EDQUOTmsg			"Quota exceeded"
  %define   ENOMEDIUMmsg		"No medium found"
  %define   EMEDIUMTYPEmsg		"Wrong medium type"
  %define   ECANCELEDmsg		"Operation Canceled"
  %define   ENOKEYmsg			"Required key not available"
  %define   EKEYEXPIREDmsg		"Key has expired"
  %define   EKEYREVOKEDmsg		"Key has been revoked"
  %define   EKEYREJECTEDmsg		"Key was rejected by service"

  ; for robust mutexes
  %define   EOWNERDEADmsg		"Owner died"
  %define   ENOTRECOVERABLEmsg	"State not recoverable"
  %define   ERFKILLmsg			"Operation not possible due to RF-kill"
  %define   EHWPOISONmsg		"Memory page has hardware error"

%elif
  %warning "errors.inc already included" 
%endif
