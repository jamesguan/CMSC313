################################################################
# James Guan
################################################################

CC=gcc
CFLAGS=-m32 -g
.PREFIXES= .c .o

ALL_TARGETS=main5 test1 test2

C_SOURCE=main5.c book_info_heap.c test1.c

C_OBJECTS=${C_SOURCE:.c=.o}

all: ${ALL_TARGETS}

%.o: %.c
	${CC} -c ${CFLAGS} $< -o $@

main5: book_info_heap.o main5.o
	gcc -o main5 -m32 -g main5.c book_info_heap.c
	
test1: book_info_heap.o test1.o
	gcc -o test1 -m32 -g test1.c book_info_heap.c
	
test2: book_info_heap.o test2.o
	gcc -o test2 -m32 -g test2.c book_info_heap.c
	
run:
	./main5
	
run_test1:
	./test1
	
run_test2:
	./test2
	
clean:
	rm -f *.o ${ALL_TARGETS}