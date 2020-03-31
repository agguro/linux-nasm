%ifndef _ASM_BOCHS_EXTENSIONS_
%define _ASM_BOCHS_EXTENSIONS_

; http://wiki.osdev.org/Bochs_VBE_Extensions

; write registers
%define   VBE_DISPI_INDEX_ID          0
%define   VBE_DISPI_INDEX_XRES        1
%define   VBE_DISPI_INDEX_YRES        2
%define   VBE_DISPI_INDEX_BPP         3
%define   VBE_DISPI_INDEX_ENABLE      4
%define   VBE_DISPI_INDEX_BANK        5
%define   VBE_DISPI_INDEX_VIRT_WIDTH  6
%define   VBE_DISPI_INDEX_VIRT_HEIGHT 7
%define   VBE_DISPI_INDEX_X_OFFSET    8
%define   VBE_DISPI_INDEX_Y_OFFSET    9 

; read registers
%define   VBE_DISPI_IOPORT_INDEX 0x01CE
%define   VBE_DISPI_IOPORT_DATA  0x01CF

; values
%define   VBE_DISPI_ID5 (0xB0C5) ; the latest version of the BGA is present

; display resolution and bit depth
%define   VBE_DISPI_BPP_4  0x04
%define   VBE_DISPI_BPP_8  0x08
%define   VBE_DISPI_BPP_15 0x0F
%define   VBE_DISPI_BPP_16 0x10
%define   VBE_DISPI_BPP_24 0x18
%define   VBE_DISPI_BPP_32 0x20

%endif