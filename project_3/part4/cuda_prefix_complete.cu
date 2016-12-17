
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

//Cuda implementation of prefix finder
//Structure from NVIDIA tutorial slides
#define N_SIZE 1048576
//N_SIZE must be a power of 2
#define THREADS_PER_BLOCK 512
//THREADS_PER_BLOCK must also be a power of 2
//Following 3 defines are for if conflict-free indexing is later implemented
//Not currently in use
#define NUM_BANKS 16  
#define LOG_NUM_BANKS 4  
#define CONFLICT_FREE_OFFSET(n) ((n) >> NUM_BANKS + (n) >> (2 * LOG_NUM_BANKS))

__global__ void find_repeats(int *dev_a, int *dev_b, int n) {
	// Places a 1 in dev_b[i] whenever dev_a[i] == dev_a[i+1]
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	if (index < n - 1) { // Don't check the last element, you'll go out of bounds.
		if (dev_a[index] == dev_a[index + 1]) {
			dev_b[index] = 1;
		}
		else {
			dev_b[index] = 0;
		}
	}
}
__global__ void exclusive_scan(int *dev_b, int *dev_c, int *dev_toAdd, int n) {
	__shared__ int temp[THREADS_PER_BLOCK*2];  // allocated on invocation  
	int nn = blockDim.x*2;
	int thid = threadIdx.x % blockDim.x;
	// We perform exclusive scan independently on every block in dev_b in place, storing the result in dev_c
	// To seperate each block, we mod the thread ID by blockDim, 
	// and pretend that we're working with only one array that fits within a single block
	int offset_tid = threadIdx.x + blockIdx.x * blockDim.x;
	// To write the data back to dev_c, we do need the offset in the big picture though.
	int offset = 1;
	int ai = 2 * offset_tid;
	int bi = 2 * offset_tid + 1;// +(n / 2);
	int ai0 = 2 * thid;
	int bi0 = 2 * thid + 1;
	//We need to use offset_tid to read the data from dev_b as well

		//int bankOffsetA = CONFLICT_FREE_OFFSET(ai);
		//int bankOffsetB = CONFLICT_FREE_OFFSET(bi); 
		//ai += bankOffsetA;
		//bi += bankOffsetB;
	temp[ai0] = dev_b[ai];
	temp[bi0] = dev_b[bi];
	//printf("temp[%d]: %d\ttemp[%d]: %d\n", ai0, dev_b[ai], bi0, dev_b[bi]);

	for (int d = nn >> 1; d > 0; d >>= 1) // build sum in place up the tree  
	{ // We loop once for every row of the binary tree.
		__syncthreads();
		if (thid < d) // This is the modded thread index. 
		{//thid starts from 0
			int ai2 = offset*(2 * thid + 1) - 1;
			int bi2 = offset*(2 * thid + 2) - 1;
			//ai += CONFLICT_FREE_OFFSET(ai);
			//bi += CONFLICT_FREE_OFFSET(bi);
			//printf("thid %d, temp[%d] += temp[%d]\t%d += %d \n", offset_tid, bi2, ai2, temp[bi2], temp[ai2]);
			temp[bi2] += temp[ai2];
			//On every row, we will add two nodes together, and store it in place on the same array
			//See GPU Gems on the NVIDIA website for visuals.
		}
		offset *= 2;
		//The referenced nodes have a greater offset for each subsequent level

	}
	if (thid == 0) {
		dev_toAdd[blockIdx.x] = temp[nn - 1];
		//printf("dev_toAdd[%d], %d at index %d\n", blockIdx.x, temp[nn - 1], nn - 1);
		temp[nn - 1] = 0;
	}
	//Store the sum before zeroing
	for (int d = 1; d < nn; d *= 2) // traverse down tree & build scan  
	{
		offset >>= 1;
		__syncthreads();
		if (thid < d)
		{
			int ai3 = offset*(2 * thid + 1) - 1;
			int bi3 = offset*(2 * thid + 2) - 1;
			//ai += CONFLICT_FREE_OFFSET(ai);
			//bi += CONFLICT_FREE_OFFSET(bi);
			int t = temp[ai3];
			temp[ai3] = temp[bi3];
			temp[bi3] += t;
		}
	}
	__syncthreads();
	dev_c[ai] = temp[ai0];
	dev_c[bi] = temp[bi0];
	//Push the data back to global memory
	//We use shared memory because it's very much faster.
	//printf("Index %d--: %d, %d\n", ai0, temp[ai0], temp[bi0]);
}
__global__ void addToAll(int *dev_c, int n, int *dev_toAdd) {
	//Add offset to all elements, so it becomes as though we had done a prefix sum over the entire array
	int index = threadIdx.x + blockIdx.x * blockDim.x;

	if (index < n) {
		dev_c[index] += dev_toAdd[(int)(blockIdx.x / 2)];
	}
}

__global__ void index_repeats(int *dev_c, int *dev_B, int n) {
	// Find the index of the repeating elements.
	// The index is found by the prefix sum, and the largest element is discovered in addToAll
	// We create an array to hand to index_repeats of size according to largest element
	// When we find an inequality in the prefix sum, the value is the index of dev_B, and the index is the value of dev_B
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	if (index < n-1)
	{
		if (dev_c[index] != dev_c[index + 1])
		{
			dev_B[dev_c[index]] = index;
		}
	}
}
__global__ void remove_repeats(int *dev_a, int *dev_c, int *dev_C, int n) {
	//Replace the indexes in dev_B with values by referencing dev_a
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	if (index < n ) {
		dev_C[index] = dev_a[index - dev_c[index]];
	}
}

main() {

	int *a, *b, *c, *B, *C; //host ABC
	int *dev_a, *dev_b, *dev_c, *dev_B, *dev_C, *dev_toAdd, *dev_toAdd0, *dev_throwaway;
	int size = N_SIZE * sizeof(int);
	//printf("size is %d\n", size);
	int i;
	int *toAdd;
	int numRepeats;
	int size2 = sizeof(int) * (N_SIZE / 2 / THREADS_PER_BLOCK);


	//cudamalloc a, b, and c on device memory

	cudaMalloc((void**)&dev_a, size);
	cudaMalloc((void**)&dev_b, size);
	cudaMalloc((void**)&dev_c, size);
	cudaMalloc((void**)&dev_toAdd, size2);
	cudaMalloc((void**)&dev_toAdd0, size2);
	cudaMalloc((void**)&dev_throwaway, sizeof(int));

	a = (int *)malloc(size);
	b = (int *)malloc(size);
	c = (int *)malloc(size);
	toAdd = (int *)malloc(size2);

	//Make random array
	for (i = 0; i < N_SIZE; i++) {
		a[i] = (int)(rand() % 10);
	}

	clock_t begin = clock();
	cudaMemcpy(dev_a, a, size, cudaMemcpyHostToDevice);

	//Do find_repeats, store in dev_b
	find_repeats <<< N_SIZE / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>> (dev_a, dev_b, N_SIZE);

	cudaMemcpy(b, dev_b, size, cudaMemcpyDeviceToHost);

	//Do exclusive scan on dev_b, store in dev_c
	exclusive_scan <<< (N_SIZE / 2) / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>> (dev_b, dev_c, dev_toAdd0, N_SIZE);

	//cudaMemcpy(c, dev_c, size, cudaMemcpyDeviceToHost);
	//cudaMemcpy(toAdd, dev_toAdd0, size2, cudaMemcpyDeviceToHost);

	//We now know the largest element in dev_c.
	// That means we know how many repeats there are.

	//We stored the largest element of each of the parallel prefix sums, and will now sum them
	// The calculated offset for each block is stored in a toAdd array

	exclusive_scan <<< 1, N_SIZE / 4 / THREADS_PER_BLOCK >>> (dev_toAdd0, dev_toAdd, dev_throwaway, N_SIZE / 2 / THREADS_PER_BLOCK);
	/*
	printf("toAdd0: %d\n", toAdd[0]);
	for (i = 1; i < N_SIZE/ 2 / THREADS_PER_BLOCK; i++)
	{//Iterate over each block
		toAdd[i] += toAdd[i - 1];
		printf("toAdd: %d\n",toAdd[i]);
	}
	toAdd[0] = 0;
	cudaMemcpy(dev_toAdd, toAdd, size2, cudaMemcpyHostToDevice);*/
	addToAll <<< N_SIZE / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>> (dev_c, N_SIZE, dev_toAdd);
	// dev_c array should contain proper data now.
	cudaMemcpy(c, dev_c, size, cudaMemcpyDeviceToHost);
	
	numRepeats = c[N_SIZE - 1];
	printf("Number of Repeats: %d\n", numRepeats); 
	B = (int*)malloc(sizeof(int)*numRepeats);
	cudaMalloc((void**)&dev_B, sizeof(int)*numRepeats);

	//Create B and C with some cuda operations on dev_c

	index_repeats <<< N_SIZE / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>(dev_c, dev_B, N_SIZE);

	cudaMemcpy(B, dev_B, sizeof(int)*numRepeats, cudaMemcpyDeviceToHost);
	int thisNumBlocks = 1;
	if( numRepeats > THREADS_PER_BLOCK)
		thisNumBlocks = numRepeats / THREADS_PER_BLOCK;

	int nonRepeats = N_SIZE - numRepeats;
	int size3 = nonRepeats * sizeof(int);
	C = (int*)malloc(size3);
	cudaMalloc((void**)&dev_C, size3);



	remove_repeats <<< thisNumBlocks, THREADS_PER_BLOCK >>>(dev_a, dev_c, dev_C, numRepeats);

	cudaMemcpy(C, dev_C, sizeof(int)*numRepeats, cudaMemcpyDeviceToHost);


	clock_t end = clock();

	float timeTaken = (float)((end - begin) / (float)CLOCKS_PER_SEC);

	printf("time taken: %f\n", timeTaken);
	FILE *ff = fopen("A.arr", "wb");
	for (i = 0; i < N_SIZE; i++) {
		fprintf(ff, "%d ", a[i]);
	}

	FILE *f = fopen("B.arr", "wb");
	for (i = 0; i < N_SIZE; i++) {
		fprintf(f, "%d ", b[i]);
	}

	FILE *fff = fopen("C.arr", "wb");
	for (i = 0; i < N_SIZE; i++) {
		fprintf(fff, "%d ", c[i]);
	}

	FILE *ffff = fopen("BB.arr", "wb");
	for (i = 0; i < numRepeats; i++) {
		fprintf(ffff, "%d ", B[i]);
	}

	FILE *fffff = fopen("CC.arr", "wb");
	for (i = 0; i < numRepeats; i++) {
		fprintf(fffff, "%d ", C[i]);
	}


	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);
	cudaFree(dev_B);
	cudaFree(dev_C);
	free(a); free(b); free(c); free(C); free(B); free(toAdd);
	return 0;

}



