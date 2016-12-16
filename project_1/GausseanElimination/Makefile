CC = gcc
CFLAGS = -c -Wall -Werror -g

all: parallel.o sequential.o
	$(CC) gauss_parallel.o -pthread -o gauss_parallel -lm
	$(CC) gauss_seq.o -o gauss_sequential -lm

parallel.o: gauss_parallel.c
	$(CC) $(CFLAGS) -pthread gauss_parallel.c

sequential.o: gauss_seq.c
	$(CC) $(CFLAGS) gauss_seq.c

clean:
	rm *.o
	rm gauss_parallel
	rm gauss_sequential
