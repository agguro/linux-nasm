;project:       Webservices
;name:          getallaccountsextended.rodata.inc
;description:   .rodata section for webservices getallaccountsextended


    host:       db      HOST,0
    request:    db      "POST /Webservices/V3?wsdl HTTP/1.1",EOL
                db      "Host: ",HOST ,EOL
                db      "Connection: close",EOL
                db      EOL
                db      '<?xml version="1.0" encoding="UTF-8"?>'
                db      '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" '
                db      'xmlns:ns1="https://sintguido.smartschool.be/Webservices/V3" '
                db      'xmlns:xsd="http://www.w3.org/2001/XMLSchema" '
                db      'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
                db      'xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" '
                db      'SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
                db      '<SOAP-ENV:Body>'
                db      '<ns1:getAllAccountsExtended>'
                db      '<accesscode xsi:type="xsd:string">ACCESSCODE</accesscode>'
                db      '<code xsi:type="xsd:string">CODE</code>'
                db      '<recursive xsi:type="xsd:string">RECURSIVE</recursive>'
                db      '</ns1:getAllAccountsExtended>'
                db      '</SOAP-ENV:Body>'
                db      '</SOAP-ENV:Envelope>'
    .len:       equ     $-request

    xml_version_str:    
                db      '<?xml version="1.0" encoding="UTF-8"?>'
    .length:    equ     $-xml_version_str


filename:       db  "allaccountsextended.xml",0
