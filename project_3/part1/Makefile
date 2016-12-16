CC = g++
NVCC = nvcc
OBJS = array_gen.o problem1_cpu.o problem1_gpu.o problem1_main.o

problem2 : $(OBJS)
	$(NVCC) $(OBJS) -o problem1

matrix_gen.o : array_gen.c array_gen.h
	$(CC) -c array_gen.c -o array_gen.o

problem1_cpu.o : problem1_cpu.c problem1.h
	$(CC) -c problem1_cpu.c -o problem1_cpu.o

problem1_gpu.o : problem1_gpu.cu problem1.h
	$(NVCC) -c problem1_gpu.cu -o problem1_gpu.o

problem1_main.o : problem1_main.c problem1.h
	$(CC) -c problem1_main.c -o problem1_main.o

clean:
	rm *.o
	rm problem1
