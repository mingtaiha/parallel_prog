CC=gcc

all: make_arr sort_seq sort_par
	chmod u+x *.o

make_arr: make_arr.o
	$(CC) make_arr.c -o make_arr.o

sort_seq: sort_seq.o array_gen.h
	$(CC) sort_seq.c -o sort_seq.o 

sort_par: sort_par.o array_gen.h
	$(CC) sort_par.c -o sort_par.o -pthread

clean: 
	rm *.o

.PHONY: all clean make_arr sort_seq sort_par
