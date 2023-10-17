libfunctions.a: ftok.o pagesize.o leapyear.o daysinmonth.o quadrimester.o semester.o shiftedmonth.o trimester.o sleep.o
	rm -f libfunctions.a
	ar cqs libfunctions.a ftok.o pagesize.o leapyear.o daysinmonth.o quadrimester.o semester.o shiftedmonth.o trimester.o sleep.o


ftok.o: ../source/c/ftok.asm
	nasm -f elf64 -g -F dwarf -o ftok.o ../source/c/ftok.asm

pagesize.o: ../source/c/pagesize.asm
	nasm -f elf64 -g -F dwarf -o pagesize.o ../source/c/pagesize.asm
    
leapyear.o: ../source/datetime/leapyear.asm
	nasm -f elf64 -g -F dwarf -o leapyear.o ../source/datetime/leapyear.asm
    
daysinmonth.o: ../source/datetime/daysinmonth.asm	
	nasm -f elf64 -g -F dwarf -o daysinmonth.o ../source/datetime/daysinmonth.asm
    
quadrimester.o: ../source/datetime/quadrimester.asm
	nasm -f elf64 -g -F dwarf -o quadrimester.o ../source/datetime/quadrimester.asm

semester.o: ../source/datetime/semester.asm
	nasm -f elf64 -g -F dwarf -o semester.o ../source/datetime/semester.asm

shiftedmonth.o: ../source/datetime/shiftedmonth.asm
	nasm -f elf64 -g -F dwarf -o shiftedmonth.o ../source/datetime/shiftedmonth.asm

trimester.o: ../source/datetime/trimester.asm
	nasm -f elf64 -g -F dwarf -o trimester.o ../source/datetime/trimester.asm

sleep.o: ../source/system/sleep.asm
	nasm -f elf64 -g -F dwarf -o sleep.o ../source/system/sleep.asm
