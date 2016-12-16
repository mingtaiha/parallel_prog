#include <math.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include "cublas_v2.h"
#include "problem2.h"

#define BLOCK_DIM 32

__global__ void mat_mult_optimized(double *dev_a, double *dev_b, double *dev_c, int ROW_A, int COL_A, int ROW_B, int COL_B)
{

	__shared__ double s_a[BLOCK_DIM][BLOCK_DIM];
	__shared__ double s_b[BLOCK_DIM][BLOCK_DIM];

	unsigned int row = BLOCK_DIM * blockIdx.y + threadIdx.y;
	unsigned int col = BLOCK_DIM * blockIdx.x + threadIdx.x;
	unsigned int i, j;

	double c = 0.0;

	#pragma unroll
	for (i = 0; i < (BLOCK_DIM + COL_A - 1) / BLOCK_DIM; i++)
	{
		if ((i * BLOCK_DIM + threadIdx.x < COL_A) && (row < ROW_A))
		{
			s_a[threadIdx.y][threadIdx.x] = dev_a[(row * COL_A) + (i * BLOCK_DIM) + threadIdx.x];
		} 
		else 
		{
			s_a[threadIdx.y][threadIdx.x] = 0.0;
		}

		if ((i * BLOCK_DIM + threadIdx.y < ROW_B) && (col < COL_B))
		{
			s_b[threadIdx.y][threadIdx.x] = dev_b[col + COL_B * (i * BLOCK_DIM + threadIdx.y)];
		}
		else
		{
			s_b[threadIdx.y][threadIdx.x] = 0.0;
		}
		__syncthreads();

		for (j = 0; j < BLOCK_DIM; j++)
		{
			c += s_a[threadIdx.y][j] * s_b[j][threadIdx.x];
		}
		__syncthreads();
	}

	if ((row < ROW_A) && (col < COL_B))
	{
		dev_c[(blockIdx.y * blockDim.y + threadIdx.y) * COL_B + (blockIdx.x * blockDim.x) + threadIdx.x] = c;
	}
}


__global__ void mat_mult_basic(double *dev_a, double *dev_b, double *dev_c, int ROW_A, int COL_A, int ROW_B, int COL_B)
{

	// Naive Matrix Multiplication

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


double * mat_mult_gpu_basic(double * A, double * B, int ROW_A, int COL_A,  int ROW_B, int COL_B)
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

	printf("Basic  GPU Matrix Multiplication\n");

	clock_t start, end;
	start = clock();

	mat_mult_basic<<<blocksPerGrid, threadsPerBlock>>>(dev_a, dev_b, dev_c, ROW_A, COL_A, ROW_B, COL_B);
	cudaThreadSynchronize();

	end = clock();
	printf("Time for Basic Matrix Multiplication: %f\n", ((double)end - (double)start) / CLOCKS_PER_SEC);

	cudaMemcpy(C, dev_c, size_c, cudaMemcpyDeviceToHost);
	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);

	return C;
}


double * mat_mult_gpu_cublas(double * A, double * B, int ROW_A, int COL_A, int ROW_B, int COL_B)
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

	cublasHandle_t handle;
	cublasCreate(&handle);

	cublasSetMatrix(ROW_A, COL_A, sizeof(double), A, ROW_A, dev_a, ROW_A);
	cublasSetMatrix(ROW_B, COL_B, sizeof(double), B, ROW_B, dev_b, ROW_B);
	cublasSetMatrix(ROW_A, COL_B, sizeof(double), C, ROW_A, dev_c, ROW_A);

	printf("CUBLAS GPU Matrix Multiplication\n");
	double alpha = 1.0;
	double beta = 1.0;

	clock_t start, end;
	start = clock();

	cublasDgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, ROW_A, COL_B, COL_A, &alpha, dev_a, ROW_A, dev_b, ROW_B, &beta, dev_c, ROW_A);
	cudaThreadSynchronize();

	end = clock();
	printf("Time for CUBLAS Matrix Multiplication: %f\n", ((double)end - (double)start) / CLOCKS_PER_SEC);

	cublasGetMatrix(ROW_A, COL_B, sizeof(double), dev_c, ROW_A, C, ROW_A);

	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);
	cublasDestroy(handle);

	return C;

}



double * mat_mult_gpu_optimized(double * A, double * B, int ROW_A, int COL_A,  int ROW_B, int COL_B)
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

	printf("Optimized GPU Matrix Multiplication\n");
	
	clock_t start, end;
	start = clock();

	mat_mult_optimized<<<blocksPerGrid, threadsPerBlock>>>(dev_a, dev_b, dev_c, ROW_A, COL_A, ROW_B, COL_B);
	cudaThreadSynchronize();

	end = clock();
	printf("Time for Optimized Matrix Multiplication: %f\n", ((double)end - (double)start) / CLOCKS_PER_SEC);
	
	cudaMemcpy(C, dev_c, size_c, cudaMemcpyDeviceToHost);
	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);

	return C;
}
