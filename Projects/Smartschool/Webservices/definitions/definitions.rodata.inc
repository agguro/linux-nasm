;project:       Webservices
;name:          definitions.rodata.inc
;description:   .rodata section for webservices definitions


    host:       db      HOST,0
    request:    db      "POST /Webservices/V3?wsdl HTTP/1.1",EOL
                db      "Host: ",HOST ,EOL
                db      "Connection: close",EOL
                db      EOL
    .len:       equ     $-request

    xml_version_str:    
                db      '<?xml version="1.0" encoding="UTF-8"?>'
    .length:    equ     $-xml_version_str


filename:       db  "definitions.xml",0
