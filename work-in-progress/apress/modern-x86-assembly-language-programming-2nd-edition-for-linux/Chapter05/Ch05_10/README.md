build:
 
    mkdir build
    cd build
    qmake ..
    make
    
output:

    i:      0   a:      2   b:      3
    i:      1   a:     -2   b:      5
    i:      2   a:     -6   b:     -7
    i:      3   a:      7   b:      8
    i:      4   a:     12   b:      4
    i:      5   a:      5   b:      9
    
    sum_a =      18   sum_b =      22
    prod_a =  10080   prod_b = -30240
