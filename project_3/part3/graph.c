//Written By: Cedric Blake
//this script creates a 2-d graph of vertecies valued between 0 and 99
//this graph is implemented using a 2-d array

//n x n array where n > 100, -1 denotes no value (disconnect) of graph
//every value around a value is concidered to be connected to that value
	//this design choice minimizes the likelyhood that a vertex will be disconnected from the graph
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "graph.h"


//garuntees that every vertex is connected to at least 1 other vertex
//returns the corrected graph
//NOTE: currenty this does not accout for isolated segments, just individual verticies
vertex** checkGraph(vertex** g, int size) { //for simplicity, change every value around isolated value to (not -1)
	vertex** graph;
	graph = g;
	int i = 0;
	for(;i < size; ++i) {
		int j = 0;
		for(;j < size; ++j) {
			if(i == 0) { //top row
				if (j == 0) { //top left corner
					if (graph[i+1][j].val == -1 && graph[i][j+1].val == -1 && graph[i+1][j+1].val == -1) {
						graph[i+1][j].val = rand() % 100; //this is 100 (from 0 to 99)
						graph[i][j+1].val = rand() % 100; //this is 100 (from 0 to 99)
						graph[i+1][j+1].val = rand() % 100; //this is 100 (from 0 to 99)
					}
				} else if (j == size - 1) { //top right corner
					if (graph[i+1][j].val == -1 && graph[i][j-1].val == -1 && graph[i+1][j-1].val == -1) {
						graph[i+1][j].val = rand() % 100; 
						graph[i][j-1].val = rand() % 100; 
						graph[i+1][j-1].val = rand() % 100; 
					}
				} else { //just on top row
					if (graph[i][j-1].val == -1 && graph[i][j+1].val == -1 &&
						graph[i+1][j-1].val == -1 && graph[i+1][j].val == -1 && graph[i+1][j+1].val == -1) {

						graph[i][j-1].val = rand() % 100; 
						graph[i][j+1].val = rand() % 100; 
						graph[i+1][j-1].val = rand() % 100;
						graph[i+1][j].val = rand() % 100; 
						graph[i+1][j+1].val = rand() % 100; 

					}
				}
			} else if (i == size - 1) {
				if (j == 0) { //bot left corner
					if (graph[i-1][j].val == -1 && graph[i][j+1].val == -1 && graph[i-1][j+1].val == -1) {
						graph[i-1][j].val = rand() % 100; //this is 100 (from 0 to 99)
						graph[i][j+1].val = rand() % 100; //this is 100 (from 0 to 99)
						graph[i-1][j+1].val = rand() % 100; //this is 100 (from 0 to 99)
					}
				} else if (j == size - 1) { //bot right corner
					if (graph[i-1][j].val == -1 && graph[i][j-1].val == -1 && graph[i-1][j-1].val == -1) {
						graph[i-1][j].val = rand() % 100; 
						graph[i][j-1].val = rand() % 100; 
						graph[i-1][j-1].val = rand() % 100; 
					}
				} else { //just on bot row
					if (graph[i][j-1].val == -1 && graph[i][j+1].val == -1 &&
						graph[i-1][j-1].val == -1 && graph[i-1][j].val == -1 && graph[i-1][j+1].val == -1) {

						graph[i][j-1].val = rand() % 100; 
						graph[i][j+1].val = rand() % 100; 
						graph[i-1][j-1].val = rand() % 100;
						graph[i-1][j].val = rand() % 100; 
						graph[i-1][j+1].val = rand() % 100; 

					}
				}
			} else {
				if (j == 0) { //mid row, left side of graph
					if(graph[i-1][j].val == -1 && graph[i-1][j+1].val == -1 &&
						graph[i][j+1].val == -1 &&
						graph[i+1][j].val == -1 && graph[i+1][j+1].val == -1) {

						graph[i-1][j].val = rand() % 100;
						graph[i-1][j+1].val = rand() % 100;

						graph[i][j+1].val = rand() % 100;

						graph[i+1][j].val = rand() % 100;
						graph[i+1][j+1].val = rand() % 100;
					}

				} else if (j == size - 1) { //mid row, right side of graph
					if(graph[i-1][j-1].val == -1 && graph[i-1][j].val == -1 &&
						graph[i][j-1].val == -1 &&
						graph[i+1][j-1].val == -1 && graph[i+1][j].val == -1) {

						graph[i-1][j-1].val = rand() % 100;
						graph[i-1][j].val = rand() % 100;

						graph[i][j-1].val = rand() % 100;

						graph[i+1][j-1].val = rand() % 100;
						graph[i+1][j].val = rand() % 100;
					}

				} else { //landlocked element
					if (graph[i-1][j-1].val == -1 && graph[i-1][j].val == -1 && graph[i-1][j+1].val == -1 &&
						graph[i][j-1].val == -1 && graph[i][j+1].val == -1 &&
						graph[i+1][j-1].val == -1 && graph[i+1][j].val == -1 && graph[i+1][j+1].val == -1) {

						graph[i-1][j-1].val = rand() % 100;
						graph[i-1][j].val = rand() % 100;
						graph[i-1][j+1].val = rand() % 100;

						graph[i][j-1].val = rand() % 100;
						graph[i][j+1].val = rand() % 100;

						graph[i+1][j-1].val = rand() % 100;
						graph[i+1][j].val = rand() % 100;
						graph[i+1][j+1].val = rand() % 100;
					}
				}
			}
		}
	}

	return graph;
}

void printGraph(vertex** graph, int size) {

	printf("\nGraph Values\n\n");
	int i = 0;
	for(;i < size; ++i) {
		int j = 0;
		for(;j < size; ++j) {
			if (graph[i][j].val != -1) {
				if (graph[i][j].val < 10) {
					printf("%d  ", graph[i][j].val);
				} else {
					printf("%d ", graph[i][j].val);
				}
			} else {
				printf("   ");
			}
		}
		printf("\n");
	}

	printf("\n");

	// printf("Visited Flag Values\n\n");
	// for(i = 0;i < size; ++i) {
	// 	int j = 0;
	// 	for(;j < size; ++j) {
	// 		if (graph[i][j].val != -1) {
	// 			printf("%d ", graph[i][j].vflag);
	// 		} else {
	// 			printf("  ");
	// 		}
	// 	}
	// 	printf("\n");
	// }
}

//generates random graph
void genGraph(vertex*** graph, int size) {
	*graph = malloc(sizeof(vertex*) * size);
	srand(time(NULL));

	int i = 0;
	for(; i < size; ++i) {
		vertex* a = malloc(sizeof(vertex) * size);
		int j = 0;
		for(; j < size; ++j) {
			int rando = rand() % 150; //this is 150 values (from 0 to 149),
			if (rando < 100) { //gives -1 more chance to appear
				a[j].val = rando; 
			} else {
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

	int* array1d = malloc(sizeof(int)* size * size);

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
	int* array1d = malloc(sizeof(int) * size * size);

	FILE *f = fopen(filename, "rb");
	if (f == NULL) {
		printf("Error reading File\n");
		return NULL;
	}
	printf("Reading Array\n");
	fread(array1d, sizeof(int), size*size, f);

	vertex** graph = malloc(sizeof(vertex*) * size * size);
	//expand graph
	int i = 0;
	for (; i < size; ++i) {
		graph[i] = malloc(sizeof(vertex)*size);
		int j = 0;
		for (; j < size; ++j) {
			graph[i][j].val = array1d[j + i*size];
			graph[i][j].vflag = 0;
		}
	}

	fclose(f);
	free(array1d);

	return graph;
}

// //for testing, keep to 10 by 10 grid

// int main(int argc, char* const argv[]) {
// 	int n;
// 	if(argv[1]) {
// 		n = atoi(argv[1]); //dimensions of generated array
// 	} else {
// 		printf("no input!\n");
// 		return 0;
// 	}
// 	vertex** g;
// 	genGraph(&g, n);

// 	printGraph(g, n);

// 	destroyGraph(g, n);

// 	return 0;

// }