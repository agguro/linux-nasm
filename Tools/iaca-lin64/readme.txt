Assembly (x86)

IACA's markers are magic byte patterns injected at the correct location within the code. When using iacaMarks.h in C or C++, the compiler handles inserting the magic bytes specified by the header at the correct location. In assembly, however, you must manually insert these marks. Thus, one must do the following:

    ; NASM usage of IACA

    mov ebx, 111          ; Start marker bytes
    db 0x64, 0x67, 0x90   ; Start marker bytes

.innermostlooplabel:
    ; Loop body
    ; ...
    jne .innermostlooplabel ; Conditional branch backwards to top of loop

    mov ebx, 222          ; End marker bytes
    db 0x64, 0x67, 0x90   ; End marker bytes

It is critical for C/C++ programmers that the compiler achieve this same pattern.
What it outputs:

As an example, let us analyze the following assembler example on the Haswell architecture:

.L2:
    vmovaps         ymm1, [rdi+rax] ;L2
    vfmadd231ps     ymm1, ymm2, [rsi+rax] ;L2
    vmovaps         [rdx+rax], ymm1 ; S1
    add             rax, 32         ; ADD
    jne             .L2             ; JMP

We add immediately before the .L2 label the start marker and immediately after jne the end marker. We then rebuild the software, and invoke IACA thus (On Linux, assumes the bin/ directory to be in the path, and foo to be an ELF64 object containing the IACA marks):

iaca.sh -64 -arch HSW -graph insndeps.dot foo

, thus producing an analysis report of the 64-bit binary foo when run on a Haswell processor, and a graph of the instruction dependencies viewable with Graphviz.

The report is printed to standard output (though it may be directed to a file with a -o switch). The report given for the above snippet is:

Intel(R) Architecture Code Analyzer Version - 2.1
Analyzed File - ../../../tests_fma
Binary Format - 64Bit
Architecture  - HSW
Analysis Type - Throughput

Throughput Analysis Report
--------------------------
Block Throughput: 1.55 Cycles       Throughput Bottleneck: FrontEnd, PORT2_AGU, PORT3_AGU

Port Binding In Cycles Per Iteration:
---------------------------------------------------------------------------------------
|  Port  |  0   -  DV  |  1   |  2   -  D   |  3   -  D   |  4   |  5   |  6   |  7   |
---------------------------------------------------------------------------------------
| Cycles | 0.5    0.0  | 0.5  | 1.5    1.0  | 1.5    1.0  | 1.0  | 0.0  | 1.0  | 0.0  |
---------------------------------------------------------------------------------------

N - port number or number of cycles resource conflict caused delay, DV - Divider pipe (on port 0)
D - Data fetch pipe (on ports 2 and 3), CP - on a critical path
F - Macro Fusion with the previous instruction occurred
* - instruction micro-ops not bound to a port
^ - Micro Fusion happened
# - ESP Tracking sync uop was issued
@ - SSE instruction followed an AVX256 instruction, dozens of cycles penalty is expected
! - instruction not supported, was not accounted in Analysis

| Num Of |                    Ports pressure in cycles                     |    |
|  Uops  |  0  - DV  |  1  |  2  -  D  |  3  -  D  |  4  |  5  |  6  |  7  |    |
---------------------------------------------------------------------------------
|   1    |           |     | 1.0   1.0 |           |     |     |     |     | CP | vmovaps ymm1, ymmword ptr [rdi+rax*1]
|   2    | 0.5       | 0.5 |           | 1.0   1.0 |     |     |     |     | CP | vfmadd231ps ymm1, ymm2, ymmword ptr [rsi+rax*1]
|   2    |           |     | 0.5       | 0.5       | 1.0 |     |     |     | CP | vmovaps ymmword ptr [rdx+rax*1], ymm1
|   1    |           |     |           |           |     |     | 1.0 |     |    | add rax, 0x20
|   0F   |           |     |           |           |     |     |     |     |    | jnz 0xffffffffffffffec
Total Num Of Uops: 6

The tool helpfully points out that currently, the bottleneck is the Haswell frontend and Port 2 and 3's AGU. This example allows us to diagnose the problem as the store not being processed by Port 7, and take remedial action.
Limitations:

IACA does not support a certain few instructions, which are ignored in the analysis. It does not support processors older than Nehalem and does not support non-innermost loops in throughput mode (having no ability to guess which branch is taken how often and in what pattern).
