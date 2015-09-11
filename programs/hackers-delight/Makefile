PROGRAMS = 3valcomp absolute average irob isign krobstzco ktobsrzco nlz ntz parity pop sign signext snoob srsfu torcob torob torobsa torzb torzbca totob totobsa totzb totzbca

all: $(PROGRAMS)

% : %.asm
	nasm -felf64 -o $@.o -l $@.lst $@.asm
	ld -m elf_x86_64 $@.o -o $@

3valcomp : 3valcomp.asm
absolute : absolute.asm
average : average.asm
irob	: irob.asm		# isolate rightmost one bit
isign : isign.asm
krobstzco : krobstzco.asm	# keep rightmost one bit, set trailing zero bits, clear all other bits
ktobsrzco : ktobsrzco.asm	# keep trailing one bits, set rightmost zero bit, clear all other bits
nlz : nlz.asm # number of leading zeros
ntz : ntz.asm # number of trailing zeros
parity : parity.asm # paritybit
pop : pop.asm # number of one bits
sign : sign.asm # sign bit
signext : signext.asm # sign extension
snoob : snoob.asm
srsfu : srsfu.asm
torcob	: torcob.asm		# turn off the rightmost contigious string of one bits
torob	: torob.asm		# turn off rightmost one bit
torobsa	: torobsa.asm		# turn off rightmost one bit, set all other bits
torzb	: torzb.asm		# turn on rightmost zero bit
torzbca : torzbca.asm		# turn on rightmost zero bit, clear all other bits
totob	: totob.asm		# turn off trailing one bits
totobsa : totobsa.asm		# turn off trailing one bits, set all other bits
totzb	: totzb.asm		# turn on trailing zero bits
totzbca : totzbca.asm		# turn on trailing zero bits, clear all other bits

clean:
	rm -f $(PROGRAMS) *.lst *.o
