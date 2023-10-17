build:

    mkdir build
    cd build
    qmake ..
    make

output:

    Variable directly from asm                     : 54321
    Variable from asm via function                 : 54321
    Variable directly from C++                     : 12345
    variable from C++ passed to asm and returned   : 12345
    Executing C/C++ function via asm...            : this output came from a C fynction ran in asm
    Executing asm function via C/C++ using pointer : this output came from a asm function ran in C/C++ using his pointer
