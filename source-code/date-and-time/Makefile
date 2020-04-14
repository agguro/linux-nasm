BIN=daysinmonth leapyear trimester quadrimester semester shiftedmonth sleep
NASM=/usr/bin/nasm
NASMOPTS=-felf64
NASMDBG=-Fdwarf
LIBNAME=libdatetime

.PHONY: all clean

all: $(BIN)

clean:
	rm -rf $(BIN).o $(BIN).dev.o $(BIN)

%: %.asm
	$(NASM) $(NASMOPTS) -o $@.o $<
	$(NASM) $(NASMOPTS) $(NASMDBG) -o $@-dev.o $<
	ar rcs $(LIBNAME).a $@.o $<
	ar rcs $(LIBNAME)-dev.a $@-dev.o $<
