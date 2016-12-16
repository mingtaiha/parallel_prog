//Breadth First Search CUDA implementation
//Written By: Cedric Blake

//Compiled and ran using Microsoft Visual Studio 2015


#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "cuda.h"
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "device_functions.h"
#include "sm_20_atomic_functions.h"

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
void __syncthreads();
int atomicOr(int*, int);
int atomicExch(int*, int);
int atomicAdd(int*, int);
#endif

typedef struct vertex {
	int val;
	int vflag;
	int coordX, coordY;
} vertex;

typedef struct Node {
	int val;
	int* coord; //used to find value on graph array
	struct Node* next;
} Node;


//graph.c functions

void printGraph(vertex** graph, int size) {

	printf("\nGraph Values\n\n");
	int i = 0;
	for (; i < size; ++i) {
		int j = 0;
		for (; j < size; ++j) {
			if (graph[i][j].val != -1) {
				if (graph[i][j].val < 10) {
					printf("%d  ", graph[i][j].val);
				}
				else {
					printf("%d ", graph[i][j].val);
				}
			}
			else {
				printf("   ");
			}
		}
		printf("\n");
	}

	printf("\n");

	printf("Visited Flag Values\n\n");
	for (i = 0; i < size; ++i) {
		int j = 0;
		for (; j < size; ++j) {
			if (graph[i][j].val != -1) {
				printf("%d ", graph[i][j].vflag);
			}
			else {
				printf("  ");
			}
		}
		printf("\n");
	}
}

vertex** checkGraph(vertex** g, int size) { //for simplicity, change every value around isolated value to (not -1)
	vertex** graph;
	graph = g;
	int i = 0;
	for (; i < size; ++i) {
		int j = 0;
		for (; j < size; ++j) {
			if (i == 0) { //top row
				if (j == 0) { //top left corner
					if (graph[i + 1][j].val == -1 && graph[i][j + 1].val == -1 && graph[i + 1][j + 1].val == -1) {
						graph[i + 1][j].val = rand() % 100; //this is 100 (from 0 to 99)
						graph[i][j + 1].val = rand() % 100; //this is 100 (from 0 to 99)
						graph[i + 1][j + 1].val = rand() % 100; //this is 100 (from 0 to 99)
					}
				}
				else if (j == size - 1) { //top right corner
					if (graph[i + 1][j].val == -1 && graph[i][j - 1].val == -1 && graph[i + 1][j - 1].val == -1) {
						graph[i + 1][j].val = rand() % 100;
						graph[i][j - 1].val = rand() % 100;
						graph[i + 1][j - 1].val = rand() % 100;
					}
				}
				else { //just on top row
					if (graph[i][j - 1].val == -1 && graph[i][j + 1].val == -1 &&
						graph[i + 1][j - 1].val == -1 && graph[i + 1][j].val == -1 && graph[i + 1][j + 1].val == -1) {

						graph[i][j - 1].val = rand() % 100;
						graph[i][j + 1].val = rand() % 100;
						graph[i + 1][j - 1].val = rand() % 100;
						graph[i + 1][j].val = rand() % 100;
						graph[i + 1][j + 1].val = rand() % 100;

					}
				}
			}
			else if (i == size - 1) {
				if (j == 0) { //bot left corner
					if (graph[i - 1][j].val == -1 && graph[i][j + 1].val == -1 && graph[i - 1][j + 1].val == -1) {
						graph[i - 1][j].val = rand() % 100; //this is 100 (from 0 to 99)
						graph[i][j + 1].val = rand() % 100; //this is 100 (from 0 to 99)
						graph[i - 1][j + 1].val = rand() % 100; //this is 100 (from 0 to 99)
					}
				}
				else if (j == size - 1) { //bot right corner
					if (graph[i - 1][j].val == -1 && graph[i][j - 1].val == -1 && graph[i - 1][j - 1].val == -1) {
						graph[i - 1][j].val = rand() % 100;
						graph[i][j - 1].val = rand() % 100;
						graph[i - 1][j - 1].val = rand() % 100;
					}
				}
				else { //just on bot row
					if (graph[i][j - 1].val == -1 && graph[i][j + 1].val == -1 &&
						graph[i - 1][j - 1].val == -1 && graph[i - 1][j].val == -1 && graph[i - 1][j + 1].val == -1) {

						graph[i][j - 1].val = rand() % 100;
						graph[i][j + 1].val = rand() % 100;
						graph[i - 1][j - 1].val = rand() % 100;
						graph[i - 1][j].val = rand() % 100;
						graph[i - 1][j + 1].val = rand() % 100;

					}
				}
			}
			else {
				if (j == 0) { //mid row, left side of graph
					if (graph[i - 1][j].val == -1 && graph[i - 1][j + 1].val == -1 &&
						graph[i][j + 1].val == -1 &&
						graph[i + 1][j].val == -1 && graph[i + 1][j + 1].val == -1) {

						graph[i - 1][j].val = rand() % 100;
						graph[i - 1][j + 1].val = rand() % 100;

						graph[i][j + 1].val = rand() % 100;

						graph[i + 1][j].val = rand() % 100;
						graph[i + 1][j + 1].val = rand() % 100;
					}

				}
				else if (j == size - 1) { //mid row, right side of graph
					if (graph[i - 1][j - 1].val == -1 && graph[i - 1][j].val == -1 &&
						graph[i][j - 1].val == -1 &&
						graph[i + 1][j - 1].val == -1 && graph[i + 1][j].val == -1) {

						graph[i - 1][j - 1].val = rand() % 100;
						graph[i - 1][j].val = rand() % 100;

						graph[i][j - 1].val = rand() % 100;

						graph[i + 1][j - 1].val = rand() % 100;
						graph[i + 1][j].val = rand() % 100;
					}

				}
				else { //landlocked element
					if (graph[i - 1][j - 1].val == -1 && graph[i - 1][j].val == -1 && graph[i - 1][j + 1].val == -1 &&
						graph[i][j - 1].val == -1 && graph[i][j + 1].val == -1 &&
						graph[i + 1][j - 1].val == -1 && graph[i + 1][j].val == -1 && graph[i + 1][j + 1].val == -1) {

						graph[i - 1][j - 1].val = rand() % 100;
						graph[i - 1][j].val = rand() % 100;
						graph[i - 1][j + 1].val = rand() % 100;

						graph[i][j - 1].val = rand() % 100;
						graph[i][j + 1].val = rand() % 100;

						graph[i + 1][j - 1].val = rand() % 100;
						graph[i + 1][j].val = rand() % 100;
						graph[i + 1][j + 1].val = rand() % 100;
					}
				}
			}
		}
	}

	return graph;
}

void genGraph(vertex*** graph, int size) {
	*graph = (vertex**)malloc(sizeof(vertex*) * size);
	srand((unsigned int)time(NULL));

	int i = 0;
	for (; i < size; ++i) {
		vertex* a = (vertex*)malloc(sizeof(vertex) * size);
		int j = 0;
		for (; j < size; ++j) {
			int rando = rand() % 150; //this is 150 values (from 0 to 149),
			if (rando < 100) { //gives -1 more chance to appear
				a[j].val = rando;
			}
			else {
				a[j].val = -1; //too lazy to find how to include -1 in range when generating random number
			}
			a[j].vflag = 0;
		}

		(*graph)[i] = a;
	}

	*graph = checkGraph(*graph, size);
}

void destroyGraph(vertex** graph, int size) {
	int i = 0;
	for(; i < size; ++i) {
		free(graph[i]);
	}

	free(graph);
	printf("graph destroyed!\n");
}

void writeGraph(vertex** graph, char* fileName, long int size) {
	FILE* f = fopen(fileName, "wb");

	int* array1d = (int*)malloc(sizeof(int)* size * size);

	//flatten graph
	int i = 0;
	for (; i < size; ++i) {
		int j = 0;
		for (; j < size; ++j) {
			array1d[j + i*size] = graph[i][j].val;
		}
	}


	printf("Writing Array\n");
	i = 0;
	fwrite(array1d, sizeof(int), size*size, f);
	fclose(f);
	free(array1d);
}

vertex** readGraph(char * filename, long int size) {
	int* array1d = (int*)malloc(sizeof(int) * size * size);

	FILE *f = fopen(filename, "rb");
	if (f == NULL) {
		printf("Error reading File\n");
		return NULL;
	}
	printf("Reading Array\n");
	fread(array1d, sizeof(int), size*size, f);

	vertex** graph = (vertex**)malloc(sizeof(vertex*) * size * size);
	//expand graph
	int i = 0;
	for (; i < size; ++i) {
		graph[i] = (vertex*)malloc(sizeof(vertex)*size);
		int j = 0;
		for (; j < size; ++j) {
			graph[i][j].val = array1d[j + i*size];
			graph[i][j].vflag = 0;
		}
	}

	free(array1d);

	return graph;
}

//to be ran on each individual thread
__device__ void bfsCuda(vertex* graph, int size, Node currNode) {

	//queue used to store the value that you will move to next
	//the value that we move to is the "coord" member variable in Node struct

	//test adjacent nodes with start.coord value
	//NOTE: coord[0] is the row, coord[1] is the col

	Node next = currNode; //this will change in while loop
	int r = *(next.coord);
	int c = *(next.coord + 1);

	if (graph[r*size + c].val != -1) {

		//dealing with 1d array here, so have to address based on size of row
		if (r - 1 >= 0) { //if not first row
			if (graph[(r - 1)*size + c].val != -1 && graph[(r - 1)*size + c].vflag == 0) {
				graph[(r - 1)*size + c].vflag = 1;
			}
			if (c - 1 >= 0) { //if not first row, not first col
				if (graph[(r - 1)*size + (c - 1)].val != -1 && graph[(r - 1)*size + (c - 1)].vflag == 0) {
					graph[(r - 1)*size + (c - 1)].vflag = 1;
				}
				if (graph[(r)*size + (c - 1)].val != -1 && graph[(r)*size + (c - 1)].vflag == 0) {
					graph[(r)*size + (c - 1)].vflag = 1;
				}
			}
			if (c + 1 < size) { //not first row, not last col
				if (graph[(r - 1)*size + (c + 1)].val != -1 && graph[(r - 1)*size + (c + 1)].vflag == 0) {
					graph[(r - 1)*size + (c + 1)].vflag = 1;
				}
				if (graph[(r)*size + (c + 1)].val != -1 && graph[(r)*size + (c + 1)].vflag == 0) {
					graph[(r)*size + (c + 1)].vflag = 1;
				}
			}
		}
		if (r + 1 < size) { //not last row
			if (graph[(r + 1)*size + (c)].val != -1 && graph[(r + 1)*size + (c)].vflag == 0) {
				graph[(r + 1)*size + (c)].vflag = 1;
			}
			if (c - 1 >= 0) { //not last row, not first col
				if (graph[(r)*size + (c - 1)].val != -1 && graph[(r)*size + (c - 1)].vflag == 0) {
					graph[(r)*size + (c - 1)].vflag = 1;
				}
				if (graph[(r + 1)*size + (c - 1)].val != -1 && graph[(r + 1)*size + (c - 1)].vflag == 0) {
					graph[(r + 1)*size + (c - 1)].vflag = 1;
				}
			}
			if (c + 1 < size) { //not last row, not last col
				if (graph[(r)*size + (c + 1)].val != -1 && graph[(r)*size + (c + 1)].vflag == 0) {
					graph[(r)*size + (c + 1)].vflag = 1;
				}
				if (graph[(r + 1)*size + (c + 1)].val != -1 && graph[(r + 1)*size + (c + 1)].vflag == 0) {
					graph[(r + 1)*size + (c + 1)].vflag = 1;
				}
			}
		}
	}
}

__global__	void bfsCudaKernel(vertex* graph1d, int size) {
	int tIndex = threadIdx.x + blockIdx.x*blockDim.x;

	//each thread should have there own start place and queue
	//create queue

	//graph should be divided based on block indexing
	//bfsCuda(graph1d, size, startHolder[tIndex], qheadbuff);

	Node start;
	int* holder = (int*)malloc(sizeof(*holder) * 2);
	*holder = graph1d[tIndex].coordX;
	*(holder + 1) = graph1d[tIndex].coordY;
	start.val = graph1d[tIndex].val;
	start.coord = holder;
	start.next = nullptr;

	for (int i = tIndex; i < size*size; ++i) {
		bfsCuda(graph1d, size, start);
	}

	free(holder);
	__syncthreads();

}


//fuction to change 2d array into 1d array
void flatten(vertex** array2d, vertex** array1d, int size2d) {

	for (int i = 0; i < size2d; ++i) {
		for (int j = 0; j < size2d; ++j) {
			(*array1d)[j + i*size2d] = array2d[i][j];
			//store the coordinates of the flattened array
			(*array1d)[j + i*size2d].coordX = i;
			(*array1d)[j + i*size2d].coordY = j;
		}
	}
}

void expand(vertex*** graph, vertex* array1d, int size2d) {

	for (int i = 0; i < size2d; ++i) {
		for (int j = 0; j < size2d; ++j) {
			(*graph)[i][j].vflag = array1d[j + i*size2d].vflag;
		}
	}
}

int main(int argc, char* argv[]) {
	int graphSize = 100;
	//int numBlocks = 100;
	int tPerBlock = 100;

	srand((unsigned int)time(NULL));

	char* fileName = "graphsave.txt";
	int genFlag = 0;
	//create graph
	vertex** g = readGraph(fileName, graphSize);
	if (g == NULL) {
		genGraph(&g, graphSize);
		genFlag = 1;
	}
	
	vertex* g1d = (vertex*)malloc(sizeof(*g1d)*graphSize*graphSize);
	flatten(g, &g1d, graphSize);

	
	vertex* d_graph;
	
	cudaSetDevice(0);
	
	cudaMalloc((void**)&d_graph, sizeof(vertex)*graphSize*graphSize);

	
	cudaMemcpy(d_graph, g1d, sizeof(vertex)*graphSize*graphSize, cudaMemcpyHostToDevice); //move graph to device
	
	clock_t begin = clock();
	bfsCudaKernel<<<(graphSize*graphSize)/tPerBlock, tPerBlock>>>(d_graph, graphSize);
	clock_t end = clock();

	float timeTaken = (float)((end - begin) / (float)CLOCKS_PER_SEC);

	cudaMemcpy(g1d, d_graph, sizeof(vertex)*graphSize*graphSize, cudaMemcpyDeviceToHost);
	cudaCheckErrors("failed");

	expand(&g, g1d, graphSize);
	
	/*
	for (int k = 0; k < graphSize*graphSize; k++) {
		//printf("%d\n", g1d[k].val);
		printf("%d, ", g1d[k].val);
		//printf("%d\n", valStorage[k]);
	}
	*/

	cudaFree(&d_graph);

	printGraph(g, graphSize);

	printf("\n");
	printf("time taken: %f\n", timeTaken);

	if (genFlag) { //then we generated a graph that needs to be written
		writeGraph(g, fileName, graphSize); // save graph to file
	}

	destroyGraph(g, graphSize);
	free(g1d);
	return 0;

}

//nvm i think this is covered by the checkGraph function
//TODO: need to divide the graph in the bfsCuda function such that each block is 
//allocated an even portion of the graph. the checkGraph() function does NOT
//hold if the graph is cut like this, so u want to add logic to account for this