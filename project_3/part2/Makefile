CC = g++
NVCC = nvcc
OBJS = matrix_gen.o problem2_cpu.o problem2_gpu.o problem2_main.o
CUBLAS_FLAG = -lcublas

problem2 : $(OBJS)
	$(NVCC) $(CUBLAS_FLAG) $(OBJS) -o problem2

matrix_gen.o : matrix_gen.c matrix_gen.h
	$(CC) -c matrix_gen.c -o matrix_gen.o

problem2_cpu.o : problem2_cpu.c problem2.h
	$(CC) -c problem2_cpu.c -o problem2_cpu.o

problem2_gpu.o : problem2_gpu.cu problem2.h
	$(NVCC) $(CUBLAS_FLAG) -c problem2_gpu.cu -o problem2_gpu.o

problem2_main.o : problem2_main.c problem2.h
	$(CC) -c problem2_main.c -o problem2_main.o

clean:
	rm *.o
	rm problem2
