#include <stdio.h>
#include <stdlib.h>

#include "linklist.h"
#include "queue.h"
#include "graph.h"


__global__ //altered to account for threads
Node bfsStart(vertex*** graph, int size) {
	int i = 0;
	for(;i < size; ++i) {
		int j = 0;
		for(;j < size; ++j) {
			__synchthreads();
			if((*graph)[i][j].val != -1 && (*graph)[i][j].vflag == 0) { //thread has already occupied this start value
				atomicAdd((*graph)[i][j].vflag, 1); //atomic add removes race condition
				Node start;
				int* holder = malloc(sizeof(*holder) * 2);
				*holder = i;
				*(holder+1) = j;
				start.val = (*graph)[i][j].val;
				start.coord = holder;
				start.next = NULL;
				return start;
			}
		}
	}
}

__global__
void pushNode(vertex*** graph, Node** qhead, int row, int col, int** storageArray) {
	int val = (*graph)[row][col].val;
	atomicAdd(**storageArray, (*graph)[row][col].val); //place val into storage array atomically
	atomicAdd(*storageArray, 1);
	int* holder = malloc(sizeof(*holder) * 2);
	*holder = row;
	*(holder+1) = col;
	queuePush(qhead, val, holder);
}

//to be ran on each individual thread
__global__
void bfsIteration(vertex*** graph, int size, Node currNode, Node** qhead, int** storageArray) {

	//queue used to store the value that you will move to next
	//the value that we move to is the "coord" member variable in Node struct

	//test adjacent nodes with start.coord value
	//NOTE: coord[0] is the row, coord[1] is the col

	Node next = currNode; //this will change in while loop

	while (1) {
		int deadEndFlag = 1; //flag for testing if all verticies around a vetex have been visited

		int r = *(next.coord);
		int c = *(next.coord+1);

		//linklistTraverse(*qhead);

		// printf("r is %d\n", r);
		// printf("c is %d\n", c);

		// printf("%d\n", (*graph)[r][c].val);

		if(r - 1 >= 0) { //if not first row
			if((*graph)[r-1][c].val != -1 && (*graph)[r-1][c].vflag == 0) {
				(*graph)[r-1][c].vflag = 1;
				pushNode(graph, qhead, r-1, c, storageArray);
				deadEndFlag = 0;
			}
			if(c - 1 >= 0) { //if not first row, not first col
				if((*graph)[r-1][c-1].val != -1 && (*graph)[r-1][c-1].vflag == 0) {
					(*graph)[r-1][c-1].vflag = 1;
					pushNode(graph, qhead, r-1, c-1, storageArray);
					deadEndFlag = 0;
				}
				if((*graph)[r][c-1].val != -1 && (*graph)[r][c-1].vflag == 0) {
					(*graph)[r][c-1].vflag = 1;
					pushNode(graph, qhead, r, c-1, storageArray);
					deadEndFlag = 0;
				}
			} 
			if (c + 1 < size) { //not first row, not last col
				if((*graph)[r-1][c+1].val != -1 && (*graph)[r-1][c+1].vflag == 0) {
					(*graph)[r-1][c+1].vflag = 1;
					pushNode(graph, qhead, r-1, c+1, storageArray);
					deadEndFlag = 0;
				}
				if((*graph)[r][c+1].val != -1 && (*graph)[r][c+1].vflag == 0) {
					(*graph)[r][c+1].vflag = 1;
					pushNode(graph, qhead, r, c+1, storageArray);
					deadEndFlag = 0;
				}
			}
		}
		if(r + 1 < size) { //not last row
			if((*graph)[r+1][c].val != -1 && (*graph)[r+1][c].vflag == 0) {
				(*graph)[r+1][c].vflag = 1;
				pushNode(graph, qhead, r+1, c, storageArray);
				deadEndFlag = 0;
			}
			if(c - 1 >= 0) { //not last row, not first col
				if((*graph)[r][c-1].val != -1 && (*graph)[r][c-1].vflag == 0) {
					(*graph)[r][c-1].vflag = 1;
					pushNode(graph, qhead, r, c-1, storageArray);
					deadEndFlag = 0;
				}
				if((*graph)[r+1][c-1].val != -1 && (*graph)[r+1][c-1].vflag == 0) {
					(*graph)[r+1][c-1].vflag = 1;
					pushNode(graph, qhead, r+1, c-1, storageArray);
					deadEndFlag = 0;
				}
			}
			if(c + 1 < size) { //not last row, not last col
				if((*graph)[r][c+1].val != -1 && (*graph)[r][c+1].vflag == 0) {
					(*graph)[r][c+1].vflag = 1;
					pushNode(graph, qhead, r, c+1, storageArray);
					deadEndFlag = 0;
				}
				if ((*graph)[r+1][c+1].val != -1 && (*graph)[r+1][c+1].vflag == 0) {
					(*graph)[r+1][c+1].vflag = 1;
					pushNode(graph, qhead, r+1, c+1, storageArray);
					deadEndFlag = 0;
				}
			}
		}

		//once each thread has marked surrounding nodes, then they select which node to go to next
		__synchthreads();


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

__global__
void bfsCuda(vertex*** graph, vertex*** splitGraph, int size, Node** qheadbuff, int** storageArray) {
	int tIndex = threadIdx.x + blockIdx.x*blockDim.x;

	//each thread should have there own start place and queue
	//create queue

	sgSize = size/gridDim.x;

	__shared__ vertex** sGraph = splitGraph;

	//split graph for each block
	int i = 0;
	for(;i < sgSize; ++i) {
		sGraph[i] = graph[i + blockIdx.x];
	}

	//initialize queue for each thread
	qheadbuff[tIndex] = bfsStart(sGraph, sgSize);

	__synchthreads();

	//graph should be divided based on block indexing
	bfsIteration(splitGraph, sgSize, start, qheadBuff[tIndex], storageArray);
}

int main(int argc, char* argv[]) {
	int graphSize = atoi(argv[1]);
	int numBlocks = atoi(argv[2]);
	int tPerBlock = atoi(argv[3]);

	if(graphSize < 1 || numBlocks < 1 || numThreads < 1) {
		printf("invalid input!\n");
		return 0;
	}

	vertex** g;
 	genGraph(&g, graphSize);

	vertex** d_graph;
	vertex** d_sGraph; //split the graph for each block
	int* valStorage; //store the result here (every thread does this)
	node** qheadHolder = sizeof(*Node)*(tPerBlock*numBlocks);
	node** d_qheadHolder; //stores each queue for all the threads

	int i = 0;
	for(;i < tPerBlock*numBlocks; ++i) {
		Node* qhead = NULL;
		qheadHolder[i] = qhead;
	}

	cudaMalloc(d_graph, sizeof(g));
	cudaMalloc(d_sGraph, sizeof(graph)/numBlocks); //will be populated in function
	cudaMalloc(valStorage, sizeof(*valStorage) * (graphSize*graphSize));
	cudaMalloc(d_qheadHolder, sizeof(*Node)*(tPerBlock*numBlocks));
	cudaMemcpy(d_graph, g, sizeof(g), cudaMemcpyHostToDevice); //move graph to device
	cudaMemcpy(d_qheadHolder, qheadHolder, sizeof(qheadHolder), cudaMemcpyHostToDevice); //move all heads to device

	free(qheadHolder);
	free(g);

	bfsCuda<<<numBlocks, numThreads>>>(&d_graph, &d_sGraph, graphSize, d_qheadHolder, &valStorage);

	cudaFree(d_graph);
	cudaFree(d_sGraph);
	cudaFree(valStorage);
	cudaFree(d_qheadHolder);


	return 0;

}

//nvm i think this is covered by the checkGraph function
//TODO: need to divide the graph in the bfsCuda function such that each block is 
//allocated an even portion of the graph. the checkGraph() function does NOT
//hold if the graph is cut like this, so u want to add logic to account for this