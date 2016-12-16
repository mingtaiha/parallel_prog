
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "matrix_gen.h"

//Cuda implementation of prefix finder
//Structure from NVIDIA tutorial slides
#define N_SIZE 32
//N_SIZE must be a power of 2
#define THREADS_PER_BLOCK 8
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
__global__ void exclusive_scan(int *dev_b, int *dev_c, int n) {
	__shared__ int temp[THREADS_PER_BLOCK];  // allocated on invocation  
	//int nn = blockDim.x;
	int thid = threadIdx.x % blockDim.x;
	// We perform exclusive scan independently on every block in dev_b in place, storing the result in dev_c
	// To seperate each block, we mod the thread ID by blockDim, 
	// and pretend that we're working with only one array that fits within a single block
	int offset_tid = threadIdx.x + blockIdx.x * blockDim.x;
	// To write the data back to dev_c, we do need the offset in the big picture though.
	int offset = 1; 
	int ai = 2*offset_tid;
	int bi = 2* offset_tid + 1;// +(n / 2);
	//We need to use offset_tid to read the data from dev_b as well
	if (bi < n) {
		//We only want to work with data as long as bi+1 is within the range of the input data

		//int bankOffsetA = CONFLICT_FREE_OFFSET(ai);
		//int bankOffsetB = CONFLICT_FREE_OFFSET(bi);
		//ai += bankOffsetA;
		//bi += bankOffsetB;
		temp[ai] = dev_b[ai];
		temp[bi] = dev_b[bi];
		printf("temp[%d]: %d\t", ai, dev_b[ai]);
		printf("temp[%d]: %d\t", bi, dev_b[bi]);
		printf("Total Offset: %d, %d\n", ai, bi);

		for (int d = n >> 1; d > 0; d >>= 1) // build sum in place up the tree  
		{ // We loop once for every row of the binary tree.
			__syncthreads();
			if (thid < d) // This is the modded thread index. 
			{//thid starts from 0
				int ai2 = offset*(2 * thid + 1) - 1;
				int bi2 = offset*(2 * thid + 2) - 1;
				//ai += CONFLICT_FREE_OFFSET(ai);
				//bi += CONFLICT_FREE_OFFSET(bi);
				printf("thid %d, temp[%d] += temp[%d]; %d += %d \n", thid, bi2, ai2, temp[bi2], temp[ai2]);
				temp[bi2] += temp[ai2];
				//On every row, we will add two nodes together, and store it in place on the same array
				//See GPU Gems on the NVIDIA website for visuals.
			}
			offset *= 2;
			//The referenced nodes have a greater offset for each subsequent level

		}
		//if (offset_tid== N_SIZE/2-1) { temp[n - 1] = 0; } // On the very last block, we zero out the last element, only once
		if (thid == 0) { temp[n - 1] = 0; } // Above is a change that I think might be needed, along with a few more changes from n to nn
		//This would be to handle blocks being distinct prefix sums... But there would be a boundary problem, 
		// especially if each block has a zeroed last element
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
				int t = temp[ai3];
				temp[ai3] = temp[bi3];
				temp[bi3] += t;
			}
		}
		__syncthreads();
		dev_c[2 * offset_tid] = temp[2 * thid];
		dev_c[2 * offset_tid + 1] = temp[2 * thid + 1];
		//Push the data back to global memory
		//We use shared memory because it's very much faster.
		printf("Index %d--: %d, %d\n", 2 * thid, temp[2 * thid], temp[2 * thid + 1]);
	}
}

__global__ void addToAll(int *dev_c, int n, int *dev_toAdd) {
	//Add offset to all elements, so it becomes as though we had done a prefix sum over the entire array
	int index = threadIdx.x + blockIdx.x * blockDim.x;

	if (index < n) {
		dev_c[index] += dev_toAdd[blockIdx.x];
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
__global__ void remove_repeats(int *dev_a, int *dev_B, int *dev_C, int n) {
	//Replace the indexes in dev_B with values by referencing dev_a
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	if (index < n - 1) {
		dev_C[index] = dev_a[dev_B[index]];
	}
}

main() {

	int *a, *b, *c, *B, *C; //host ABC
	int *dev_a, *dev_b, *dev_c, *dev_B, *dev_C, *dev_toAdd;
	int size = N_SIZE * sizeof(int);
	printf("size is %d\n", size);
	int i;
	int *toAdd;
	int numRepeats;

	//cudamalloc a, b, and c on device memory

	cudaMalloc((void**)&dev_a, size);
	cudaMalloc((void**)&dev_b, size);
	cudaMalloc((void**)&dev_c, size);

	a = (int *)malloc(size);
	b = (int *)malloc(size);
	c = (int *)malloc(size);

	//Make random array
	for (i = 0; i < N_SIZE; i++) {
		a[i] = (int)(rand() % 10);
	}

	cudaMemcpy(dev_a, a, size, cudaMemcpyHostToDevice);

	//Do find_repeats, store in dev_b
	find_repeats <<< N_SIZE / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>> (dev_a, dev_b, N_SIZE);

	cudaMemcpy(b, dev_b, size, cudaMemcpyDeviceToHost);

	//Do exclusive scan on dev_b, store in dev_c
	exclusive_scan <<< (N_SIZE / 2) / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>> (dev_b, dev_c, N_SIZE);

	cudaMemcpy(c, dev_c, size, cudaMemcpyDeviceToHost);

	//We now know the largest element in dev_c.
	// That means we know how many repeats there are.
	int run = 0;
	int temp = 0;
	int size2 = sizeof(int) * (N_SIZE / THREADS_PER_BLOCK);
	toAdd = (int*)malloc(size2);
	cudaMalloc((void**)&dev_toAdd, size2);
	toAdd[0] = 0;
	//Here, we find the largest element of each of the parallel prefix sums, and sum them
	// The calculated offset for each block is stored in a toAdd array
	for (i = 1; i < (N_SIZE / THREADS_PER_BLOCK); i++)
	{
		temp = THREADS_PER_BLOCK*i - 1;
		printf("temp is: %d\n", temp);
		if (temp < N_SIZE) {
			run += c[temp];
			toAdd[i] = run;
			printf("toAdd[%d] = run is: %d\n",i, run);
		}
	}
	cudaMemcpy(dev_toAdd, toAdd, size2, cudaMemcpyHostToDevice);
	addToAll <<< N_SIZE / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>> (dev_c, N_SIZE, dev_toAdd);
	// dev_c array should contain proper data now.
	cudaMemcpy(c, dev_c, size, cudaMemcpyDeviceToHost);
	
	numRepeats = c[N_SIZE - 1];
	printf("Number of Repeats: %d\n", numRepeats); 
	B = (int*)malloc(sizeof(int)*numRepeats);
	C = (int*)malloc(sizeof(int)*numRepeats);
	cudaMalloc((void**)&dev_B, sizeof(int)*numRepeats);
	cudaMalloc((void**)&dev_C, sizeof(int)*numRepeats);

	//Create B and C with some cuda operations on dev_c

	index_repeats <<< N_SIZE / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>(dev_c, dev_B, N_SIZE);

	cudaMemcpy(B, dev_B, sizeof(int)*numRepeats, cudaMemcpyDeviceToHost);
	int thisNumBlocks = 1;
	if( numRepeats > THREADS_PER_BLOCK)
		thisNumBlocks = numRepeats / THREADS_PER_BLOCK;

	remove_repeats <<< thisNumBlocks, THREADS_PER_BLOCK >>>(dev_a, dev_B, dev_C, numRepeats);

	cudaMemcpy(C, dev_C, sizeof(int)*numRepeats, cudaMemcpyDeviceToHost);


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



