###############################################################
# James Guan
# Makefile for extracredit
# Last Edited 5/15/2015
#
################################################################

AS=nasm
LD=gcc
ASFLAGS=-f elf -g -F dwarf
LDFLAGS=-m32 -g
.PREFIXES= .o .asm

ALL_TARGETS=extracredit

ASM_SOURCE=extracredit.asm

ASM_OBJECTS=${ASM_SOURCE:.asm=.o}

all: ${ALL_TARGETS}

%.o: %.asm
	${AS} ${ASFLAGS} $< -o $@

rpn: extracredit.o
	${LD} ${LDFLAGS} -o $@ $<

clean:
	rm -f *.o ${ALL_TARGETS} *.lst
