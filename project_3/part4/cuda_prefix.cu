#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <cmath>
#include <device_functions.h>

#define N 1048576
#define THREADS_PER_BLOCK 1024

#define cudaCheckErrors(msg) \
    do { \
        cudaError_t __err = cudaGetLastError(); \
        if (__err != cudaSuccess) { \
            fprintf(stderr, "Fatal error: %s (%s at %s:%d)\n", \
                msg, cudaGetErrorString(__err), \
                __FILE__, __LINE__); \
            fprintf(stderr, "*** FAILED - ABORTING\n"); \
            exit(1); \
        } else { \
			printf("success\n"); \
		} \
    } while (0)


#pragma once
#ifdef __INTELLISENSE__
void __syncthreads(); //Just so sync threads doesnt get underlined in red
int atomicAdd(int* address, int val);
#endif

typedef struct Node {
	int sum;
	int fromLeft;
}Node;


void randomGen(int *input, int size) {
	srand(time(NULL));
	for (int i = 0; i < size; i++) {
		input[i] = rand() % 100;
	}
}

__device__ void downPass(Node *nodeArray, int count) {
	int index = threadIdx.x + blockIdx.x * blockDim.x;

	//set root node
	if (index%N == 0) {
		nodeArray[0].fromLeft = 0;
	}

	if (index%(N) == 0) {
		nodeArray[1].fromLeft = nodeArray[0].fromLeft;
		nodeArray[2].fromLeft = nodeArray[0].fromLeft + nodeArray[1].sum;
		
	}

	__syncthreads();

	int divisor = N / 2;
	for (int i = 1; i < count; i++) {
		if (index%divisor == 0) {
			//int random = i - 1;
			//int leftIndex = power(2, i) + index / divisor + 2 * random + 1;
			int leftIndex = 2 * i + 1;
			nodeArray[leftIndex].fromLeft = nodeArray[leftIndex / 2].fromLeft;//left child
			nodeArray[leftIndex + 1].fromLeft = nodeArray[leftIndex / 2].fromLeft + nodeArray[leftIndex].sum;
			divisor /= 2;
		}
		__syncthreads();
	}
}

//Tree builds!!!!
__device__ void buildTree(int *input, Node *nodeArray, int *sum, int count) {
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	nodeArray[index + (N-1)].sum = input[index]; //Save all the leaf nodes
	int divisor = 2;
	for (int i = 0; i < count; i++) { //Generate all of the parent nodes
		if (index % divisor == 0) {
			nodeArray[(index+(N-1))/divisor].sum = nodeArray[(index+(N-1))/(divisor/2)].sum + nodeArray[(index + N)/(divisor/2)].sum;
			divisor *= 2;
		}
		__syncthreads();
	}

}

__global__ void find_repeats(int *a, int *b, int n) {
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	if (index < n - 1) {
		if (a[index] == a[index + 1]) {
			b[index] = 1;
		}
		else {
			b[index] = 0;
		}
	}
}

__global__ void exclusive_scan(int *input, int *output, Node *nodeArray, int *totalSum, int iterations) {
	//int index = threadIdx.x + blockIdx.x * blockDim.x;
	buildTree(input, nodeArray, totalSum, iterations);
	__syncthreads();
	downPass(nodeArray, iterations);
	

}

//In order to implement this we need a working version of exclusive scan
__global__ void index_repeats(int *b, int *c, int *B) {

}

int main() {

	int *a, *b, *c; //host ABC
	int *dev_a, *dev_b, *dev_A;
	int *totalSum;
	int sum = 0;
	//int *dev_c, *dev_B;
	int size = N * sizeof(int);

	Node *nodeArray, *dev_nodeArray;
	int nodeArraySize = (2 * N - 1) * sizeof(Node);

	//cudamalloc a, b, and c on device memory

	cudaMalloc((void**)&dev_a, size);
	cudaMalloc((void**)&dev_b, size);
	cudaMalloc((void**)&dev_A, size);
	cudaMalloc((void**)&totalSum, sizeof(int));
	cudaMalloc((void**)&dev_nodeArray, nodeArraySize);
	//cudaMalloc((void**)&dev_c, size);
	//cudaMalloc((void**)&dev_B, size);

	a = (int *)malloc(size);
	b = (int *)malloc(size);
	c = (int *)malloc(size);
	nodeArray = (Node *)malloc(nodeArraySize);

	//Make random array
	randomGen(a, N);

	cudaMemcpy(dev_a, a, size, cudaMemcpyHostToDevice);

	//This works properly
	find_repeats <<< N / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>(dev_a, dev_b, N);


	//Do exclusive scan on dev_b, store in dev_c
	//exclusive_scan <<< N / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>(dev_b, dev_c);

	int iterations = log(N) / log(2); //Cannot be called from the device
	exclusive_scan <<< N / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>(dev_a, dev_A, dev_nodeArray, totalSum, iterations);
	//Create B and C with some cuda operations on dev_c
	//need to implement exclusive scan on dev_b in order to do index repeats
	//index_repeats <<< N / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>(dev_b, dev_c, dev_B);

	cudaMemcpy(b, dev_b, size, cudaMemcpyDeviceToHost);
	//cudaCheckErrors("failed");
	//cudaMemcpy(a, dev_A, size, cudaMemcpyDeviceToHost);
	cudaMemcpy(&sum, totalSum, sizeof(int), cudaMemcpyDeviceToHost);
	cudaMemcpy(nodeArray, dev_nodeArray, nodeArraySize, cudaMemcpyDeviceToHost);
	

	//remove repeats cannot be done in parallel
	int j = 0;
	for (int i = 0; i < N; i++) {
		if (b[i] == 0) {
			c[j] = a[i];
			j++;
		}
	}


	printf("Last element of find_repeats: %d\n", c[N-j]); //replace

	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_A);
	cudaFree(totalSum);
	cudaFree(dev_nodeArray);
	//cudaFree(dev_c);
	free(a); free(b); free(c); free(nodeArray);
	return 0;

}
