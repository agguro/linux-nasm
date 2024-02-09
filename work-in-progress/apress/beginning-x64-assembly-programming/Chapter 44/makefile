all: inline1.exe inline2.exe
inline1.exe: inline1.c 
	gcc -no-pie -o inline1 inline1.c -masm=intel
inline2.exe: inline2.c 
	gcc -no-pie -o inline2 inline2.c -masm=intel
