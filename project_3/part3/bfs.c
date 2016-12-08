//bredth first search algorithms
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "linklist.h"
#include "queue.h"
#include "graph.h"

//chooses a starting point for bredth first search
Node bfsStart(vertex** graph, int size) {
	int i = 0;
	for(;i < size; ++i) {
		int j = 0;
		for(;j < size; ++j) {
			if(graph[i][j].val != -1) {
				Node start;
				int* holder = malloc(sizeof(*holder) * 2);
				*holder = i;
				*(holder+1) = j;
				start.val = graph[i][j].val;
				start.coord = holder;
				start.next = NULL;
				return start;
			}
		}
	}
}

void pushNode(vertex*** graph, Node** qhead, int row, int col, int** storageArray) {
	int val = (*graph)[row][col].val;
	**storageArray = (*graph)[row][col].val;
	*storageArray = *storageArray + 1;
	int* holder = malloc(sizeof(*holder) * 2);
	*holder = row;
	*(holder+1) = col;
	queuePush(qhead, val, holder);
}

//place bfsStart function in place of "start" parameter
//NOTE: may need to pass by reference, not sure yet though
static void bfsRecursion(vertex*** graph, int size, Node start, Node** qhead, int** storageArray) {

	//queue used to store the value that you will move to next
	//the value that we move to is the "coord" member variable in Node struct

	//test adjacent nodes with start.coord value
	//NOTE: coord[0] is the row, coord[1] is the col

	int deadEndFlag = 1; //flag for testing if all verticies around a vetex have been visited
	Node next;

	int r = *(start.coord);
	int c = *(start.coord+1);

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

	//linklistTraverse(*qhead);

	//base case check
	if(!deadEndFlag) { //need to do recursion
		next = queuePop(qhead);
		bfsRecursion(graph, size, next, qhead, storageArray);
	} else {
		if (*qhead != NULL) {
			next = queuePop(qhead);
			bfsRecursion(graph, size, next, qhead, storageArray);
		} else {
			return;
		}
	}
}

int main(int argc, char** argv) {
	int n;
	if(argv[1]) {
		n = atoi(argv[1]); //dimensions of generated array
	} else {
		printf("no input!\n");
		return 0;
	}

	//create queue
	Node* qhead = NULL; //initialize to null for queuePush func

	//create graph
	vertex** g;
 	genGraph(&g, n);
 	printGraph(g, n);

 	//create start
	Node start = bfsStart(g, n);
	printf("start at %d, %d\n", *start.coord, *(start.coord+1));

 	int* bfsBuffer = malloc(sizeof(*bfsBuffer) * (n*n));
 	int i = 0;
 	for (; i < n*n; ++i) { //just for displaying result clearly
 		bfsBuffer[i] = -1;
 	}
 	int* buffIter = bfsBuffer;

 	//bfs stuff should go here
 	clock_t begin = clock();
 	bfsRecursion(&g, n, start, &qhead, &buffIter);
 	clock_t end = clock();
 	float timeTaken = (float)((end-begin)/(float)CLOCKS_PER_SEC);

	printf("\n");
	printf("Result");
	printf("\n");

 	i = 0;
 	for(; i < n*n; ++i) {
 		if (bfsBuffer[i] == -1) {
 			break;
 		}
 		if (i % 10 != 9) {
 			printf("%d, ", bfsBuffer[i]);
 		} else {
 			printf("%d\n", bfsBuffer[i]);
 		}
 	}
 	printf("\n");

 	//deallocate graph
 	destroyGraph(g, n);

 	//deallocate queue
 	linklistDestroy(qhead);

 	printf("\n");

 	printf("time taken: %f\n", timeTaken);


	return 0;
}