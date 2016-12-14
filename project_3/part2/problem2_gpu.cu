#include <math.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include "problem2.h"

#define BLOCK_DIM 32

__global__ void mat_mult_basic(double *dev_a, double *dev_b, double *dev_c, int ROW_A, int COL_A, int ROW_B, int COL_B)
{
	int row = blockIdx.y * blockDim.y + threadIdx.y;
	int col = blockIdx.x * blockDim.x + threadIdx.x;

	double sum = 0.0;
	int i;

	if ((row < ROW_A) && (col  < COL_B))
	{
		for (i = 0; i < COL_A; i++) 
		{
			sum += dev_a[row * COL_A + i] * dev_b[i * ROW_B + col];
		}
	dev_c[row * COL_B + col] = sum;
	}
}


double * mat_mult_gpu(double * A, double * B, int ROW_A, int COL_A,  int ROW_B, int COL_B)
{

	int size_a, size_b, size_c;
	
	size_a = ROW_A * COL_A * sizeof(double);
	size_b = ROW_B * COL_B * sizeof(double);
	size_c = ROW_A * COL_B * sizeof(double);

	double *dev_a, *dev_b, *dev_c;
	
	double *C = (double *) malloc(size_c);
	cudaMalloc((void**)&dev_a, size_a);	
	cudaMalloc((void**)&dev_b, size_b);	
	cudaMalloc((void**)&dev_c, size_c);	

	cudaMemcpy(dev_a, A, size_a, cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, B, size_b, cudaMemcpyHostToDevice);

	dim3 threadsPerBlock(BLOCK_DIM, BLOCK_DIM);
	dim3 blocksPerGrid((int)ceil((double)ROW_A / (double)threadsPerBlock.x), (int)ceil((double)COL_B / (double)threadsPerBlock.y));

	printf("Basic GPU Matrix Multiplication\n");
	mat_mult_basic<<<blocksPerGrid, threadsPerBlock>>>(dev_a, dev_b, dev_c, ROW_A, COL_A, ROW_B, COL_B);
	cudaThreadSynchronize();

	cudaMemcpy(C, dev_c, size_c, cudaMemcpyDeviceToHost);
	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);

	return C;
}
