build:
 
    mkdir build
    cd build
    qmake ..
    make
    
output:

    -------- ConvertFtoC Results --------
      i: 0  f:    -459.67  c:    -273.15
      i: 1  f:        -40  c:        -40
      i: 2  f:          0  c:   -17.7778
      i: 3  f:         32  c:          0
      i: 4  f:         72  c:    22.2222
      i: 5  f:       98.6  c:         37
      i: 6  f:        212  c:        100
    
    -------- ConvertCtoF Results --------
      i: 0  c:    -273.15  f:    -459.67
      i: 1  c:        -40  f:        -40
      i: 2  c:   -17.7778  f:          0
      i: 3  c:          0  f:         32
      i: 4  c:         25  f:         77
      i: 5  c:         37  f:       98.6
      i: 6  c:        100  f:        212
