
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "matrix_gen.h"

//Cuda implementation of prefix finder
//Structure from NVIDIA tutorial slides
#define N_SIZE 32
#define THREADS_PER_BLOCK 8
#define NUM_BANKS 16  
#define LOG_NUM_BANKS 4  
#define CONFLICT_FREE_OFFSET(n) ((n) >> NUM_BANKS + (n) >> (2 * LOG_NUM_BANKS))

__global__ void find_repeats(float *dev_a, float *dev_b, int n) {

	int index = threadIdx.x + blockIdx.x * blockDim.x;
	if (index < n - 1) {
		if (dev_a[index] == dev_a[index + 1]) {
			dev_b[index] = 1;
			printf("Found Repeat\t");
		}
		else {
			dev_b[index] = 0;
		}
	}
}
__global__ void addToAll(float *dev_c, float toAdd) {
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	dev_c[index] += toAdd;
}

__global__ void exclusive_scan(float *dev_b, float *dev_c, int n) {
	__shared__ float temp[THREADS_PER_BLOCK];  // allocated on invocation  
	int thid = threadIdx.x + blockIdx.x * blockDim.x;
	int block_offset = blockIdx.x * blockDim.x;
	int offset = 1; 
	int ai = 2*thid;
	int bi = 2*thid + 1;// +(n / 2);
	//int bankOffsetA = CONFLICT_FREE_OFFSET(ai);
	//int bankOffsetB = CONFLICT_FREE_OFFSET(bi);
	//ai += bankOffsetA;
	//bi += bankOffsetB;
		temp[ai] = dev_b[ai];
		temp[bi] = dev_b[bi];

		printf("ai[%d]: %f\t", ai, dev_b[ai]);
		printf("bi[%d]: %f\t", bi, dev_b[bi]);
		printf("Total Offset: %d, %d\n", ai, bi);
	for (int d = n >> 1; d > 0; d >>= 1) // build sum in place up the tree  
	{
		__syncthreads();
		if (thid < d)
		{//thid starts from 0
			int ai2 = offset*(2 * thid + 1) - 1;
			int bi2 = offset*(2 * thid + 2) - 1;
			//ai += CONFLICT_FREE_OFFSET(ai);
			//bi += CONFLICT_FREE_OFFSET(bi);
			//printf("thid %d, temp[%d] += temp[%d]\n",thid, bi2, ai2);
			temp[bi2] += temp[ai2];
		}
		offset *= 2;

	}
		if (thid == 0) { temp[n - 1] = 0; }
		for (int d = 1; d < n; d *= 2) // traverse down tree & build scan  
		{
			offset >>= 1;
			__syncthreads();
			if (thid < d)
			{
				int ai3 = offset*(2 * thid + 1) - 1;
				int bi3 = offset*(2 * thid + 2) - 1;
				//ai += CONFLICT_FREE_OFFSET(ai);
				//bi += CONFLICT_FREE_OFFSET(bi);
				float t = temp[ai3];
				temp[ai3] = temp[bi3];
				temp[bi3] += t;
			}
		}
		__syncthreads();
		dev_c[2*thid] = temp[2 * thid];
		dev_c[2 * thid + 1] = temp[2 * thid + 1];

		printf("Index %d--: %f, %f\n",2*thid,  temp[2 * thid], temp[2 * thid + 1]);


}

__global__ void index_repeats(float *dev_b, float *dev_c, float *dev_B, float n) {


}
__global__ void remove_repeats(float *dev_a, float *dev_B, float *dev_C, float n) {


}

main() {

	float *a, *b, *c; //host ABC
	float *dev_a, *dev_b, *dev_c, *dev_B, *dev_C;
	int size = N_SIZE * sizeof(float);
	int i;
	float toAdd;

	//cudamalloc a, b, and c on device memory

	cudaMalloc((void**)&dev_a, size);
	cudaMalloc((void**)&dev_b, size);
	cudaMalloc((void**)&dev_c, size);
	cudaMalloc((void**)&dev_B, size);
	cudaMalloc((void**)&dev_C, size);

	a = (float *)malloc(size);
	b = (float *)malloc(size);
	c = (float *)malloc(size);

	//Make random array
	for (i = 0; i < N_SIZE; i++) {
		a[i] = (float)(rand() % 10);
	}

	cudaMemcpy(dev_a, a, size, cudaMemcpyHostToDevice);

	//Do find_repeats, store in dev_b
	find_repeats <<< N_SIZE / 2 / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>> (dev_a, dev_b, N_SIZE);

	cudaMemcpy(b, dev_b, size, cudaMemcpyDeviceToHost);

	//Do exclusive scan on dev_b, store in dev_c
	exclusive_scan <<< N_SIZE / 2 / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>> (dev_b, dev_c, N_SIZE);

	cudaMemcpy(c, dev_c, size, cudaMemcpyDeviceToHost);


	for (i = (N_SIZE / THREADS_PER_BLOCK) - 1; i > 0; i--)
	{
		// Starting from the last block, add the last number from the previous block
		// End one block before the first block
		// Note that each block in the previous kernel calls handled 2*THREADS_PER_BLOCK elements
		// Each of these blocks handles only THREADS_PER_BLOCK elements. 
		toAdd = c[THREADS_PER_BLOCK*i - 1];
		addToAll <<< (N_SIZE / THREADS_PER_BLOCK) - i, THREADS_PER_BLOCK >>> (&dev_c[THREADS_PER_BLOCK * i], toAdd);
	}

	cudaMemcpy(c, dev_c, size, cudaMemcpyDeviceToHost);


	//Create B and C with some cuda operations on dev_c

	//index_repeats <<< N_SIZE / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>(dev_b, dev_c, dev_B, N_SIZE);

	//remove_repeats <<< N_SIZE / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>(dev_a, dev_B, dev_C, N_SIZE);


	printf("Last element of find_repeats: %d\n", 0); //replace

	FILE *ff = fopen("A.arr", "wb");
	for (i = 0; i < N_SIZE; i++) {
		fprintf(ff, "%f ", a[i]);
	}

	FILE *f = fopen("B.arr", "wb");
	for (i = 0; i < N_SIZE; i++) {
		fprintf(f, "%f ", b[i]);
	}

	FILE *fff = fopen("C.arr", "wb");
	for (i = 0; i < N_SIZE; i++) {
		fprintf(fff, "%f ", c[i]);
	}


	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);
	free(a); free(b); free(c);
	return 0;

}



