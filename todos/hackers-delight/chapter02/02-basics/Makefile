PROGRAMS = torob torzb totob totzb torzbca torobsa totzbca totobsa irob krobstzco ktobsrzco torcob

all: $(PROGRAMS)

% : %.asm
	nasm -felf64 -o $@.o -l $@.lst $@.asm
	ld -m elf_x86_64 $@.o -o $@

torob	: torob.asm		# turn off rightmost one bit
torzb	: torzb.asm		# turn on rightmost zero bit
totob	: totob.asm		# turn off trailing one bits
totzb	: totzb.asm		# turn on trailing zero bits
torzbca : torzbca.asm		# turn on rightmost zero bit, clear all other bits
torobsa	: torobsa.asm		# turn off rightmost one bit, set all other bits
totzbca : totzbca.asm		# turn on trailing zero bits, clear all other bits
totobsa : totobsa.asm		# turn off trailing one bits, set all other bits
irob	: irob.asm		# isolate rightmost one bit
krobstzco : krobstzco.asm	# keep rightmost one bit, set trailing zero bits, clear all other bits
ktobsrzco : ktobsrzco.asm	# keep trailing one bits, set rightmost zero bit, clear all other bits
torcob	: torcob.asm		# turn off the rightmost contigious string of one bits

clean:
	rm -f $(PROGRAMS) *.lst *.o
