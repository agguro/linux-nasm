BIN=bytebcd2bin bytebin2bcd bytebin2hexascii bytebcd2ascii \
nibblebcd2bin nibblebin2bcd nibblebin2hexascii nibblebcd2ascii \
wordbcd2bin wordbin2hexascii wordbcd2ascii wordbin2bcd \
fpubcd2hex fpuhex2bcd \
qwordbcd2bin qwordbin2hexascii qwordbin2bcd qwordbcd2ascii \
dwordbcd2bin dwordbin2bcd dwordbin2hexascii dwordbcd2ascii \
tolower switchcase toupper

NASM=/usr/bin/nasm
NASMOPTS=-felf64
NASMDBG=-Fdwarf
LIBNAME=libconversions

.PHONY: all clean

all: $(BIN)

clean:
	rm -rf $(LIBNAME).a $(LIBNAME)-dev.a *.o *-dev.o

%: %.asm
	$(NASM) $(NASMOPTS) -o $@.o $<
	$(NASM) $(NASMOPTS) $(NASMDBG) -o $@-dev.o $<
	ar rcs $(LIBNAME).a $@.o $<
	ar rcs $(LIBNAME)-dev.a $@-dev.o $<
