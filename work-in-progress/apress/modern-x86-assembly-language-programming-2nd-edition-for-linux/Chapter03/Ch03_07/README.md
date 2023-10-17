build:
 
    mkdir build
    cd build
    qmake ..
    make
    
output:

    Test case: destination buffer size OK
      Original Strings
        i:0 One 
        i:1 Two 
        i:2 Three 
        i:3 Four
      Concatenated Result
        One Two Three Four
    
    Test case: destination buffer too small
      Original Strings
        i:0 Red 
        i:1 Green 
        i:2 Blue 
        i:3 Yellow 
      Concatenated Result
        Red Green Blue 
      Error - test string compare failed
    
    Test case: empty source string
      Original Strings
        i:0 Plane 
        i:1 Car 
        i:2 <empty string>
        i:3 Truck 
        i:4 Boat 
        i:5 Train 
        i:6 Bicycle 
      Concatenated Result
        Plane Car Truck Boat Train Bicycle 
    
    Test case: all strings empty
      Original Strings
        i:0 <empty string>
        i:1 <empty string>
        i:2 <empty string>
        i:3 <empty string>
      Concatenated Result
        <empty string>
    
    Test case: minimum des_size
      Original Strings
        i:0 1
        i:1 22
        i:2 333
        i:3 4444
      Concatenated Result
        1223334444
