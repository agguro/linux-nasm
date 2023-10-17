build:
 
    mkdir build
    cd build
    qmake ..
    make
    
output:

    Results for CompareVCOMISS
    ------------------------------------------------------------------------
    a = 120, b = 130
    UO=false  LT=true   LE=true   EQ=false  NE=true   GT=false  GE=false  
    
    a = 250, b = 240
    UO=false  LT=false  LE=false  EQ=false  NE=true   GT=true   GE=true   
    
    a = 300, b = 300
    UO=false  LT=false  LE=true   EQ=true   NE=false  GT=false  GE=true   
    
    a = -18, b = 32
    UO=false  LT=true   LE=true   EQ=false  NE=true   GT=false  GE=false  
    
    a = -81, b = -100
    UO=false  LT=false  LE=false  EQ=false  NE=true   GT=true   GE=true   
    
    a = 42, b = nan
    UO=true   LT=false  LE=false  EQ=false  NE=false  GT=false  GE=false  
    
    
    Results for CompareVCOMISD
    ------------------------------------------------------------------------
    a = 120, b = 130
    UO=false  LT=true   LE=true   EQ=false  NE=true   GT=false  GE=false  
    
    a = 250, b = 240
    UO=false  LT=false  LE=false  EQ=false  NE=true   GT=true   GE=true   
    
    a = 300, b = 300
    UO=false  LT=false  LE=true   EQ=true   NE=false  GT=false  GE=true   
    
    a = -18, b = 32
    UO=false  LT=true   LE=true   EQ=false  NE=true   GT=false  GE=false  
    
    a = -81, b = -100
    UO=false  LT=false  LE=false  EQ=false  NE=true   GT=true   GE=true   
    
    a = 42, b = nan
    UO=true   LT=false  LE=false  EQ=false  NE=false  GT=false  GE=false
