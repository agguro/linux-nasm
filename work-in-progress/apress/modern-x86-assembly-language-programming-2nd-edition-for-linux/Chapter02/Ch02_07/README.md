build:

    mkdir build
    cd build
    qmake ..
    make

output:

    SignedMinA(   2,   15,    8) =    2
    SignedMinB(   2,   15,    8) =    2
    
    SignedMinA(  -3,  -22,   28) =  -22
    SignedMinB(  -3,  -22,   28) =  -22
    
    SignedMinA(  17,   37,  -11) =  -11
    SignedMinB(  17,   37,  -11) =  -11
    
    SignedMaxA(  10,    5,    3) =   10
    SignedMaxB(  10,    5,    3) =   10
    
    SignedMaxA(  -3,   28,   15) =   28
    SignedMaxB(  -3,   28,   15) =   28
    
    SignedMaxA( -25,  -37,  -17) =  -17
    SignedMaxB( -25,  -37,  -17) =  -17
