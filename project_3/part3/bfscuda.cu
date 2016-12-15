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

//pop from the queue
__device__ Node queuePop(Node** headPointer) {
	Node* holder = *headPointer; //holds value to be referenced later

	if (*headPointer == NULL) { //if the link list is empty
		printf("Nothing to pop!\n");
		Node returnVal;
		returnVal.val = -1;
		returnVal.coord = NULL;
		return returnVal;
	}

	if ((*headPointer)->next == NULL) { //if there was only 1 element in the link list
		Node returnVal;
		returnVal.val = (*headPointer)->val;
		returnVal.coord = (*headPointer)->coord;
		*headPointer = NULL;
		free(holder);
		return returnVal;
	}

	Node* iter = (*headPointer)->next;
	while (1) {
		if (iter->next == NULL) {
			(*headPointer)->next = NULL;
			Node returnVal;
			returnVal.val = iter->val;
			returnVal.coord = iter->coord;
			free(iter);
			*headPointer = holder;
			return returnVal;
		}
		*headPointer = iter; //holder always stays 1 step behind iter
		iter = iter->next;
	}
}

__device__ void queuePush(Node** headPointer, int pushVal, int* pushCoord) { //set pushCoord to NULL if you dont care about coord value
	Node* pushNode = (Node*)malloc(sizeof(Node));
	pushNode->val = pushVal;
	pushNode->coord = pushCoord;
	if (*headPointer == NULL) { //if there is nothing in the queue initially
		pushNode->next = NULL;
	}
	else {
		pushNode->next = *headPointer;
	}
	*headPointer = pushNode;
	return;
}


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


__device__ //altered to account for threads
Node bfsStart(vertex** graph, int size) {
	Node start;
	int i = 0;
	for(;i < size; ++i) {
		for (int j = 0; j < size; ++j) {
			__syncthreads();
			if ((*graph)[i*size + j].val != -1 && (*graph)[i*size+j].vflag == 0) { //thread has already occupied this start value
				atomicOr(&((*graph)[i*size + j].vflag), 1); //atomic Or sets flag, removes race condition
				int* holder = (int*)malloc(sizeof(*holder) * 2);
				*holder = i;
				*(holder + 1) = j;
				start.val = (*graph)[i*size + j].val;
				start.coord = holder;
				start.next = NULL;
				goto funcEnd; //TODO: changed this, now getting seg faults
			}
		}
	}
	funcEnd:
	return start;
}

__device__
void pushNode(vertex** graph, Node** qhead, int row, int col, int size, int** storageArray) {
	int val = (*graph)[row*size + col].val;
	**storageArray = (*graph)[row*size + col].val; //place val into storage array atomically
	*storageArray = *storageArray + 1;
	int* holder = (int*)malloc(sizeof(*holder) * 2);
	*holder = row;
	*(holder+1) = col;
	queuePush(qhead, val, holder);
}

//to be ran on each individual thread
__device__
void bfsCuda(vertex** graph, int size, Node currNode, Node** qhead, int** storageArray) {

	//queue used to store the value that you will move to next
	//the value that we move to is the "coord" member variable in Node struct

	//test adjacent nodes with start.coord value
	//NOTE: coord[0] is the row, coord[1] is the col

	Node next = currNode; //this will change in while loop

	while (1) {
		int deadEndFlag = 1; //flag for testing if all verticies around a vetex have been visited

		int r = *(next.coord);
		int c = *(next.coord+1);

		//dealing with 1d array here, so have to address based on size of row
		if(r - 1 >= 0) { //if not first row
			if((*graph)[(r-1)*size + c].val != -1 && (*graph)[(r-1)*size + c].vflag == 0) {
				(*graph)[(r - 1)*size + c].vflag = 1;
				pushNode(graph, qhead, r-1, c, size, storageArray);
				deadEndFlag = 0;
			}
			if(c - 1 >= 0) { //if not first row, not first col
				if((*graph)[(r - 1)*size + (c-1)].val != -1 && (*graph)[(r - 1)*size + (c - 1)].vflag == 0) {
					(*graph)[(r - 1)*size + (c - 1)].vflag = 1;
					pushNode(graph, qhead, r-1, c-1, size, storageArray);
					deadEndFlag = 0;
				}
				if((*graph)[(r)*size + (c - 1)].val != -1 && (*graph)[(r)*size + (c - 1)].vflag == 0) {
					(*graph)[(r)*size + (c - 1)].vflag = 1;
					pushNode(graph, qhead, r, c-1, size, storageArray);
					deadEndFlag = 0;
				}
			} 
			if (c + 1 < size) { //not first row, not last col
				if((*graph)[(r-1)*size + (c + 1)].val != -1 && (*graph)[(r - 1)*size + (c + 1)].vflag == 0) {
					(*graph)[(r - 1)*size + (c + 1)].vflag = 1;
					pushNode(graph, qhead, r-1, c+1, size, storageArray);
					deadEndFlag = 0;
				}
				if((*graph)[(r)*size + (c + 1)].val != -1 && (*graph)[(r)*size + (c + 1)].vflag == 0) {
					(*graph)[(r)*size + (c + 1)].vflag = 1;
					pushNode(graph, qhead, r, c+1, size, storageArray);
					deadEndFlag = 0;
				}
			}
		}
		if(r + 1 < size) { //not last row
			if((*graph)[(r+1)*size + (c)].val != -1 && (*graph)[(r + 1)*size + (c)].vflag == 0) {
				(*graph)[(r + 1)*size + (c)].vflag = 1;
				pushNode(graph, qhead, r+1, c, size, storageArray);
				deadEndFlag = 0;
			}
			if(c - 1 >= 0) { //not last row, not first col
				if((*graph)[(r)*size + (c-1)].val != -1 && (*graph)[(r)*size + (c - 1)].vflag == 0) {
					(*graph)[(r)*size + (c - 1)].vflag = 1;
					pushNode(graph, qhead, r, c-1, size, storageArray);
					deadEndFlag = 0;
				}
				if((*graph)[(r+1)*size + (c - 1)].val != -1 && (*graph)[(r + 1)*size + (c - 1)].vflag == 0) {
					(*graph)[(r + 1)*size + (c - 1)].vflag = 1;
					pushNode(graph, qhead, r+1, c-1, size, storageArray);
					deadEndFlag = 0;
				}
			}
			if(c + 1 < size) { //not last row, not last col
				if((*graph)[(r)*size + (c+1)].val != -1 && (*graph)[(r)*size + (c + 1)].vflag == 0) {
					(*graph)[(r)*size + (c + 1)].vflag = 1;
					pushNode(graph, qhead, r, c+1, size, storageArray);
					deadEndFlag = 0;
				}
				if ((*graph)[(r+1)*size + (c + 1)].val != -1 && (*graph)[(r + 1)*size + (c + 1)].vflag == 0) {
					(*graph)[(r + 1)*size + (c + 1)].vflag = 1;
					pushNode(graph, qhead, r+1, c+1, size, storageArray);
					deadEndFlag = 0;
				}
			}
		}

		//once each thread has marked surrounding nodes, then they select which node to go to next
		__syncthreads();


		//ACTUALLY, dont think this is a problen, if a thread flags a node, then the
		//thread that comes after it will see that it has already been flagged.
		//becaue the flag only needs to be set once, synchronization isnt really a problem as
		//far as the graph is concerned. just need to synch when storing found value into storage array
		//TODO: will need to have another check because a thread that has finished its check
		//does not see that its adjacent nodes have been

		//base case
		//base case check
		if(!deadEndFlag) { //need to do recursion
			next = queuePop(qhead);
		} else {
			if (*qhead != NULL) {
				next = queuePop(qhead);
			} else {
				break;
			}
		}
	}
}

__global__	void bfsCudaKernel(vertex* graph1d, int size, int* storageArray) {
	//int tIndex = threadIdx.x + blockIdx.x*blockDim.x;

	//each thread should have there own start place and queue
	//create queue
	Node* qheadbuff = nullptr;
	//initialize queue for each thread
	Node start = bfsStart(&graph1d, size);

	__syncthreads();

	//graph should be divided based on block indexing
	bfsCuda(&graph1d, size, start, &qheadbuff, &storageArray);



}


//fuction to change 2d array into 1d array
vertex* flatten(vertex** array2d, int size2d) {
	vertex* array1d = (vertex*)malloc(sizeof(vertex)*size2d*size2d);

	for (int i = 0; i < size2d; ++i) {
		for (int j = 0; j < size2d; ++j) {
			array1d[j + i*size2d] = array2d[i][j];
			//store the coordinates of the flattened array
			array1d[j + i*size2d].coordX = i;
			array1d[j + i*size2d].coordY = j;
		}
	}

	return array1d;
}


vertex** expand(vertex* array1d, int size2d) {
	vertex** array2d = (vertex**)malloc(sizeof(vertex*)*size2d*size2d);

	for (int i = 0; i < size2d; ++i) {
		for (int j = 0; j < size2d; ++j) {
			array2d[i][j] = array1d[j + i*size2d];
		}
	}

	return array2d;
}

int main(int argc, char* argv[]) {
	int graphSize = 10;
	int numBlocks = 1; //try to code for only threads for now
	int tPerBlock = 1;

	if(graphSize < 1 || numBlocks < 1 || tPerBlock < 1) {
		printf("invalid input!\n");
		return 0;
	}

	vertex** g;
	int valSize = sizeof(int) * (graphSize*graphSize);
	int* valStorage = (int*)malloc(valSize);
 	genGraph(&g, graphSize);

	vertex* g1d = flatten(g, graphSize);

	vertex* d_graph;
	int* d_valStorage; //store the result here (every thread does this)
	

	cudaMalloc((void**)&d_graph, sizeof(vertex)*graphSize*graphSize);
	cudaMalloc((void**)&d_valStorage, valSize);
	
	cudaMemcpy(d_graph, g1d, sizeof(vertex)*graphSize*graphSize, cudaMemcpyHostToDevice); //move graph to device

	bfsCudaKernel<<<1, tPerBlock>>>(d_graph, graphSize, d_valStorage);
	cudaCheckErrors("failed");

	cudaMemcpy(g1d, d_graph, sizeof(vertex)*graphSize*graphSize, cudaMemcpyDeviceToHost);
	cudaMemcpy(valStorage, d_valStorage, valSize, cudaMemcpyDeviceToHost);

	for (int k = 0; k < graphSize*graphSize; k++) {
		//printf("%d\n", g1d[k].val);
		printf("%d\n", g1d[k].vflag);
		//printf("%d\n", valStorage[k]);
	}

	g = expand(g1d, graphSize);
	printGraph(g, graphSize);

	int i = 0;
	for (; i < graphSize*graphSize; ++i) {
		if (valStorage[i] == -1) {
			break;
		}
		if (i % 10 != 9) {
			printf("%d, ", valStorage[i]);
		}
		else {
			printf("%d\n", valStorage[i]);
		}
	}
	printf("\n");

	cudaFree(&d_graph);
	cudaFree(&d_valStorage);


	free(g);
	free(g1d);
	free(valStorage);

	return 0;

}

//nvm i think this is covered by the checkGraph function
//TODO: need to divide the graph in the bfsCuda function such that each block is 
//allocated an even portion of the graph. the checkGraph() function does NOT
//hold if the graph is cut like this, so u want to add logic to account for this