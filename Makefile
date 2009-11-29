FASM = ../bin/fasm
ALL = foerthchen foer.bin foer.h4

all: $(ALL)

foerthchen: foerthchen.asm core.asm
	$(FASM) foerthchen.asm
	chmod +x foerthchen

foer.bin: foerbin.asm core.asm
	$(FASM) foerbin.asm foer.bin

foer.h4: foer.bin
	perl ./genfoer.pl >foer.h4

clean:
	-rm *~

distclean: clean
	-rm $(ALL)
