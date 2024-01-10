.PHONY: all clean run

D64_IMAGE = "bin/psyii.prg"
X64 = x64
X64SC = x64sc
C1541 = c1541

all: clean run
original: clean d64_orig run_orig

psyii.prg: src/psyII.asm
	64tass -Wall -Wno-implied-reg --cbm-prg -o bin/psyii.prg -L bin/list-co1.txt -l bin/labels.txt src/psyII.asm
#	echo "65d265c4a55235508353668b5c61b1dd  bin/psyii.prg" | md5sum -c

run: psyii.prg
	$(X64) -verbose $(D64_IMAGE)

clean:
	-rm bin/psyii.prg
	-rm bin/*.txt
