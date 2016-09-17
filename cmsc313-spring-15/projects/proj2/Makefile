###############################################################
# James Guan
# Makefile for proj2
# Last Edited 2/26/2015
#
################################################################

AS=nasm
LD=gcc
ASFLAGS=-f elf -g -F dwarf
LDFLAGS=-m32 -g
.PREFIXES= .o .asm

ALL_TARGETS=rpn

ASM_SOURCE=rpn.asm

ASM_OBJECTS=${ASM_SOURCE:.asm=.o}

all: ${ALL_TARGETS}

%.o: %.asm
	${AS} ${ASFLAGS} $< -o $@

rpn: rpn.o
	${LD} ${LDFLAGS} -o $@ $<

clean:
	rm -f *.o ${ALL_TARGETS} *.lst
