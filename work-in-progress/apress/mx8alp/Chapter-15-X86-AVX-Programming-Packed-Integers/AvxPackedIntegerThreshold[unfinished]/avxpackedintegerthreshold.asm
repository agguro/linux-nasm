; Name:     avxpackedintegerthreshold.asm
;
; Build:    nasm -f elf32 -o avxpackedintegerthreshold.o avxpackedintegerthreshold.asm
;
; Source:   Modern x86 Assembly Language Programming p. 425
;
; Remark:   Until ImageBuffer.cpp is converted, this example is of little use.

extern NUM_PIXELS_MAX
global AvxPiThreshold
global AvxPiCalcMean

; Image threshold data structure (see AvxPackedIntegerThreshold.h)
struc       ITD
    .PbSrc               resd   1
    .PbMask              resd   1
    .NumPixels           resd   1
    .Threshold           resb   1
    .Pad                 resb   3
    .NumMaskedPixels     resd   1
    .SumMaskedPixels     resd   1
    .MeanMaskedPixels    resq   1
endstruc

; Marco AvxPiCalcMeanUpdateSums
;
; Description:  The following macro updates sum_masked_pixels in ymm4.
;               It also resets any necessary intermediate values in
;               order to prevent an overflow condition.
;
; Register contents:
;   ymm3:ymm2 = packed word sum_masked_pixels
;   ymm4 = packed dword sum_masked_pixels
;   ymm7 = packed zero
;
; Temp registers:
;   ymm0, ymm1, ymm5, ymm6

%macro AvxPiCalcMeanUpdateSums 0

; Promote packed word sum_masked_pixels to dword
    vpunpcklwd ymm0,ymm2,ymm7
    vpunpcklwd ymm1,ymm3,ymm7
    vpunpckhwd ymm5,ymm2,ymm7
    vpunpckhwd ymm6,ymm3,ymm7

; Update packed dword sums in sum_masked_pixels
    vpaddd ymm0,ymm0,ymm1
    vpaddd ymm5,ymm5,ymm6
    vpaddd ymm4,ymm4,ymm0
    vpaddd ymm4,ymm4,ymm5

; Reset intermediate values
    xor    edx,edx                       ;reset update counter
    vpxor  ymm2,ymm2,ymm2                ;reset sum_masked_pixels lo
    vpxor  ymm3,ymm3,ymm3                ;reset sum_masked_pixels hi
%endmacro


; Custom segment for constant values
section .data

PixelScale      times 32 db 0           ;uint8 to int8 scale value
R8_MinusOne     dq -1.0                 ;invalid mean value

section .text

; extern "C" bool AvxPiThreshold(ITD* itd);
;
; Description:  The following function performs image thresholding
;               of an 8 bits-per-pixel grayscale image.
;
; Returns:      0 = invalid size or unaligned image buffer
;               1 = success
;
; Requires:     AVX2

AvxPiThreshold:
    push    ebp
    mov     ebp,esp
    push    esi
    push    edi

; Load and verify the argument values in ITD structure
    mov     edx,[ebp+8]                     ;edx = 'itd'
    xor     eax,eax                         ;set error return code
    mov     ecx,[edx+ITD.NumPixels]         ;ecx = NumPixels
    test    ecx,ecx
    jz      .done                           ;jump if num_pixels == 0
    cmp     ecx,[NUM_PIXELS_MAX]
    ja      .done                           ;jump if num_pixels too big
    test    ecx,1fh
    jnz     .done                           ;jump if num_pixels % 32 != 0
    shr     ecx,5                           ;ecx = number of packed pixels

    mov     esi,[edx+ITD.PbSrc]             ;esi = PbSrc
    test    esi,1fh
    jnz     .done                           ;jump if misaligned
    mov     edi,[edx+ITD.PbMask]            ;edi = PbMask
    test    edi,1fh
    jnz     .done                           ;jump if misaligned

; Initialize packed threshold
    vpbroadcastb ymm0,[edx+ITD.Threshold]   ;ymm0 = packed threshold
    vmovdqa  ymm7, [PixelScale]             ;ymm7 = uint8 to int8 SF
    vpsubb   ymm2,ymm0,ymm7                 ;ymm1 = scaled threshold

; Create the mask image
.@1:     
    vmovdqa  ymm0, [esi]                    ;load next packed pixel
    vpsubb   ymm1,ymm0,ymm7                 ;ymm1 = scaled image pixels
    vpcmpgtb ymm3,ymm1,ymm2                 ;compare against threshold
    vmovdqa  [edi],ymm3                     ;save packed threshold mask
 
    add     esi,32
    add     edi,32
    dec     ecx
    jnz     .@1                             ;repeat until done
    mov     eax,1                           ;set return code

.done:
    pop     edi
    pop     esi
    pop     ebp
    ret

; extern "C" bool AvxPiCalcMean(ITD* itd);
;
; Description:  The following function calculates the mean value all
;               above-threshold image pixels using the mask created by
;               function AvxPiThreshold_.
;
; Returns:      0 = invalid image size or unaligned image buffer
;               1 = success
;
; Requires:     AVX2, POPCNT

AvxPiCalcMean:
    push ebp
    mov ebp,esp
    push ebx
    push esi
    push edi

; Load and verify the argument values in ITD structure
    mov eax,[ebp+8]                     ;eax = 'itd'
    mov ecx,[eax+ITD.NumPixels]         ;ecx = NumPixels
    test ecx,ecx
    jz .error                            ;jump if num_pixels == 0
    cmp ecx,[NUM_PIXELS_MAX]
    ja .error                            ;jump if num_pixels too big
    test ecx,1fh
    jnz .error                           ;jump if num_pixels % 32 != 0
    shr ecx,5                           ;ecx = number of packed pixels

    mov edi,[eax+ITD.PbMask]            ;edi = PbMask
    test edi,1fh
    jnz .error                           ;jump if PbMask not aligned
    mov esi,[eax+ITD.PbSrc]             ;esi = PbSrc
    test esi,1fh
    jnz .error                           ;jump if PbSrc not aligned

; Initialize values for mean calculation
    xor edx,edx                 ;edx = update counter
    vpxor ymm7,ymm7,ymm7        ;ymm7 = packed zero
    vmovdqa ymm2,ymm7           ;ymm2 = sum_masked_pixels (16 words)
    vmovdqa ymm3,ymm7           ;ymm3 = sum_masked_pixels (16 words)
    vmovdqa ymm4,ymm7           ;ymm4 = sum_masked_pixels (8 dwords)
    xor ebx,ebx                 ;ebx = num_masked_pixels (1 dword)

; Register usage for processing loop
; esi = PbSrc, edi = PbMask, eax = scratch register
; ebx = num_pixels_masked, ecx = NumPixels / 32, edx = update counter
;
; ymm0 = packed pixel, ymm1 = packed mask
; ymm3:ymm2 = sum_masked_pixels (32 words)
; ymm4 = sum_masked_pixels (8 dwords)
; ymm5 = scratch register
; ymm6 = scratch register
; ymm7 = packed zero

.@1:
    vmovdqa     ymm0, [esi]      ;load next packed pixel
    vmovdqa     ymm1, [edi]      ;load next packed mask

; Update mum_masked_pixels
    vpmovmskb   eax,ymm1
    popcnt      eax,eax
    add         ebx,eax

; Update sum_masked_pixels (word values)
    vpand      ymm6,ymm0,ymm1            ;set non-masked pixels to zero
    vpunpcklbw ymm0,ymm6,ymm7
    vpunpckhbw ymm1,ymm6,ymm7       ;ymm1:ymm0 = masked pixels (words)
    vpaddw     ymm2,ymm2,ymm0
    vpaddw     ymm3,ymm3,ymm1           ;ymm3:ymm2 = sum_masked_pixels

; Check and see if it's necessary to update the dword sum_masked_pixels
; in xmm4 and num_masked_pixels in ebx
    inc     edx
    cmp     edx,255
    jb      .noUpdate

    AvxPiCalcMeanUpdateSums

.noUpdate:
    add     esi,32
    add     edi,32
    dec     ecx
    jnz     .@1                              ;repeat loop until done

; Main processing loop is finished. If necessary, perform final update
; of sum_masked_pixels in xmm4 & num_masked_pixels in ebx.
    test    edx,edx
    jz      .@2
    
    AvxPiCalcMeanUpdateSums

; Compute and save final sum_masked_pixels & num_masked_pixels
.@2:     
    vextracti128 xmm0,ymm4,1
    vpaddd       xmm1,xmm0,xmm4
    vphaddd      xmm2,xmm1,xmm7
    vphaddd      xmm3,xmm2,xmm7
    vmovd        edx,xmm3                      ;edx = final sum_mask_pixels

    mov     eax,[ebp+8]                     ;eax = 'itd'
    mov     [eax+ITD.SumMaskedPixels],edx   ;save final sum_masked_pixels
    mov     [eax+ITD.NumMaskedPixels],ebx   ;save final num_masked_pixels

; Compute mean of masked pixels
    test    ebx,ebx                        ;is num_mask_pixels zero?
    jz      .noMean                           ;if yes, skip calc of mean
    vcvtsi2sd xmm0,xmm0,edx             ;xmm0 = sum_masked_pixels
    vcvtsi2sd xmm1,xmm1,ebx             ;xmm1 = num_masked_pixels
    vdivsd    xmm0,xmm0,xmm1               ;xmm0 = mean_masked_pixels
    jmp       .@3
.noMean:
    vmovsd  xmm0,[R8_MinusOne]               ;use -1.0 for no mean
.@3:
    vmovsd  [eax+ITD.MeanMaskedPixels],xmm0  ;save mean
    mov     eax,1                               ;set return code
    vzeroupper
.done:
    pop     edi
    pop     esi
    pop     ebx
    pop     ebp
    ret
.error:
    xor     eax,eax                         ;set error return code
    jmp     .done
