
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>

//Cuda implementation of prefix finder
//Structure from NVIDIA tutorial slides
#define N_SIZE 1000000
#define THREADS_PER_BLOCK 512
#define NUM_BANKS 16  
#define LOG_NUM_BANKS 4  
#define CONFLICT_FREE_OFFSET(n) ((n) >> NUM_BANKS + (n) >> (2 * LOG_NUM_BANKS))

__global__ void find_repeats(int *dev_a, int *dev_b, int n) {


}
__global__ void exclusive_scan(int *dev_b, int *dev_c, int n) {
	extern __shared__ float temp[];  // allocated on invocation  
	int thid = threadIdx.x;
	int offset = 1; 
	int ai = thid;
	int bi = thid + (n / 2);
	int bankOffsetA = CONFLICT_FREE_OFFSET(ai);
	int bankOffsetB = CONFLICT_FREE_OFFSET(bi);
		temp[ai + bankOffsetA] = dev_b[ai];
		temp[bi + bankOffsetB] = dev_b[bi];

	for (int d = n >> 1; d > 0; d >>= 1)                    // build sum in place up the tree  
	{
		__syncthreads();
		if (thid < d)
		{
			int ai = offset*(2 * thid + 1) - 1;
			int bi = offset*(2 * thid + 2) - 1;
			ai += CONFLICT_FREE_OFFSET(ai);
			bi += CONFLICT_FREE_OFFSET(bi);
			temp[bi] += temp[ai];
		}
		offset *= 2;

		if (thid == 0) { temp[n - 1 + CONFLICT_FREE_OFFSET(n - 1)] = 0; }
		for (int d = 1; d < n; d *= 2) // traverse down tree & build scan  
		{
			offset >>= 1;
			__syncthreads();
			if (thid < d)
			{
				int ai = offset*(2 * thid + 1) - 1;
				int bi = offset*(2 * thid + 2) - 1;
				ai += CONFLICT_FREE_OFFSET(ai);
				bi += CONFLICT_FREE_OFFSET(bi);
				float t = temp[ai];
				temp[ai] = temp[bi];
				temp[bi] += t;
			}
		}
		__syncthreads();
		dev_c[ai] = temp[ai + bankOffsetA];
		dev_c[bi] = temp[bi + bankOffsetB];
	}

}
__global__ void index_repeats(int *dev_b, int *dev_c, int *dev_B, int n) {


}
__global__ void remove_repeats(int *dev_a, int *dev_B, int*dev_C, int n) {


}

main() {

	int *a, *b, *c; //host ABC
	int *dev_a, *dev_b, *dev_c, *dev_B, *dev_C;
	int size = N_SIZE * sizeof(int);
	int i;

	//cudamalloc a, b, and c on device memory

	cudaMalloc((void**)&dev_a, size);
	cudaMalloc((void**)&dev_b, size);
	cudaMalloc((void**)&dev_c, size);
	cudaMalloc((void**)&dev_B, size);
	cudaMalloc((void**)&dev_C, size);

	a = (int *)malloc(size);
	b = (int *)malloc(size);
	c = (int *)malloc(size);

	//Make random array
	for (i = 0; i < N_SIZE; i++) {
		a[i] = (int)(rand() % 100);
	}

	cudaMemcpy(dev_a, a, size, cudaMemcpyHostToDevice);

	//Do find_repeats, store in dev_b
	find_repeats <<< N_SIZE / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>(dev_a, dev_b, N_SIZE);


	//Do exclusive scan on dev_b, store in dev_c
	exclusive_scan <<< N_SIZE / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>(dev_b, dev_c, N_SIZE);

	//Create B and C with some cuda operations on dev_c

	index_repeats <<< N_SIZE / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>(dev_b, dev_c, dev_B, N_SIZE);

	remove_repeats <<< N_SIZE / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>(dev_a, dev_B, dev_C, N_SIZE);

	cudaMemcpy(b, dev_b, size, cudaMemcpyDeviceToHost);
	cudaMemcpy(c, dev_c, size, cudaMemcpyDeviceToHost);

	printf("Last element of find_repeats: %d\n", 0); //replace

	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);
	free(a); free(b); free(c);
	return 0;

}



