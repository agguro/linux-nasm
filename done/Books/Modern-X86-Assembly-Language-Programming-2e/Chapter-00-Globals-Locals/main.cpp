// main.cpp
// example of external and global declarations with assembly language

#include <iostream>

using namespace std;

//globals from assembly language declared here extern
extern "C" int get_variable_from_asm_();
extern "C" int get_variable_from_c_();
extern "C" void run_c_function_(void(*function)());
extern "C" void* function_from_asm_();
extern "C" int variable_from_asm_;

void function_from_c();
void run_asm_function(void* function());
int variable_from_c = 12345;

int main()
{
    cout << "Variable directly from asm                     : " << variable_from_asm_ << endl;
    cout << "Variable from asm via function                 : " << get_variable_from_asm_() << endl;
    cout << "Variable directly from C++                     : " << variable_from_c << endl;
    cout << "variable from C++ passed to asm and returned   : " << get_variable_from_c_() << endl;
    cout << "Executing C/C++ function via asm...            : ";
    run_c_function_(function_from_c);
    //try to remove std::flush in the next line :)
    cout << "Executing asm function via C/C++ using pointer : " << std::flush;
    run_asm_function(function_from_asm_);

    return 0;
}

void function_from_c()
{
    cout << "this output came from a C fynction ran in asm" << endl;
}

void run_asm_function(void* function())
{
    function();
}
