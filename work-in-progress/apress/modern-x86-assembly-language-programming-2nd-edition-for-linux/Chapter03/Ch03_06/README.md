build:
 
    mkdir build
    cd build
    qmake ..
    make
    
output:

    Test string: Four score and seven seconds ago, ...
      SearchChar: s Count: 4
      SearchChar: o Count: 4
      SearchChar: z Count: 0
      SearchChar: F Count: 1
      SearchChar: . Count: 3
    
    Test string: Red Green Blue Cyan Magenta Yellow
      SearchChar: e Count: 6
      SearchChar: w Count: 1
      SearchChar: l Count: 3
      SearchChar: Q Count: 0
      SearchChar: n Count: 3
