build:
 
    mkdir build
    cd build
    qmake ..
    make
    
output:

    Results for CompareVCMPSD
    ----------------------------------------
    a = 120   b = 130
    cmp_eq:     false   cmp_neq:    true  
    cmp_lt:     true    cmp_le:     true  
    cmp_gt:     false   cmp_ge:     false 
    cmp_ord:    true    cmp_unord:  false 
    
    a = 250   b = 240
    cmp_eq:     false   cmp_neq:    true  
    cmp_lt:     false   cmp_le:     false 
    cmp_gt:     true    cmp_ge:     true  
    cmp_ord:    true    cmp_unord:  false 
    
    a = 300   b = 300
    cmp_eq:     true    cmp_neq:    false 
    cmp_lt:     false   cmp_le:     true  
    cmp_gt:     false   cmp_ge:     true  
    cmp_ord:    true    cmp_unord:  false 
    
    a = -18   b = 32
    cmp_eq:     false   cmp_neq:    true  
    cmp_lt:     true    cmp_le:     true  
    cmp_gt:     false   cmp_ge:     false 
    cmp_ord:    true    cmp_unord:  false 
    
    a = -81   b = -100
    cmp_eq:     false   cmp_neq:    true  
    cmp_lt:     false   cmp_le:     false 
    cmp_gt:     true    cmp_ge:     true  
    cmp_ord:    true    cmp_unord:  false 
    
    a = 42   b = nan
    cmp_eq:     false   cmp_neq:    true  
    cmp_lt:     false   cmp_le:     false 
    cmp_gt:     false   cmp_ge:     false 
    cmp_ord:    false   cmp_unord:  true  
