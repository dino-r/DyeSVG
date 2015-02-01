.PHONY: clean

COMPILE= ghc

dyesvg: Main.hs ProcessSVG.hs
	$(COMPILE) -o $@ $<
	
clean:
	rm -f *.o *.hi dyesvg
