build:
 
    mkdir build
    cd build
    qmake ..
    make
    
output:

Results for CompareArrays_ - array_size = 10000

    Test using invalid array size
      expected = -1  actual = -1
    
    Test using first element mismatch
      expected = 0  actual = 0
    
    Test using middle element mismatch
      expected = 5000  actual = 5000
    
    Test using last element mismatch
      expected = 9999  actual = 9999
    
    Test with identical elements in each array
      expected = 10000  actual = 10000

