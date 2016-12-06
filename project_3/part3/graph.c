//Written Bu: Cedric Blake
//this script creates a 2-d graph of vertecies valued between 0 and 99
//this graph is implemented using a 2-d array

//n x n array where n > 100, -1 denotes no value (disconnect) of graph
//every value around a value is concidered to be connected to that value
	//this design choice minimizes the likelyhood that a vertex will be disconnected from the graph
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "linklist.h"
#include "queue.h"


//garuntees that every vertex is connected to at least 1 other vertex
//returns the corrected graph
int** checkGraph(int** g, int size) { //for simplicity, change every value around isolated value to (not -1)
	int** graph;
	graph = g;
	int i = 0;
	for(;i < size; ++i) {
		int j = 0;
		for(;j < size; ++j) {
			if(i == 0) { //top row
				if (j == 0) { //top left corner
					if (graph[i+1][j] == -1 && graph[i][j+1] == -1 && graph[i+1][j+1] == -1) {
						graph[i+1][j] = rand() % 100; //this is 100 (from 0 to 99)
						graph[i][j+1] = rand() % 100; //this is 100 (from 0 to 99)
						graph[i+1][j+1] = rand() % 100; //this is 100 (from 0 to 99)
					}
				} else if (j == size) { //top right corner
					if (graph[i+1][j] == -1 && graph[i][j-1] == -1 && graph[i+1][j-1] == -1) {
						graph[i+1][j] = rand() % 100; 
						graph[i][j-1] = rand() % 100; 
						graph[i+1][j-1] = rand() % 100; 
					}
				} else { //just on top row
					if (graph[i][j-1] == -1 && graph[i][j+1] == -1 &&
						graph[i+1][j-1] == -1 && graph[i+1][j] == -1 && graph[i+1][j+1] == -1) {

						graph[i][j-1] = rand() % 100; 
						graph[i][j+1] = rand() % 100; 
						graph[i+1][j-1] = rand() % 100;
						graph[i+1][j] = rand() % 100; 
						graph[i+1][j+1] = rand() % 100; 

					}
				}
			} else if (i == size) {
				if (j == 0) { //bot left corner
					if (graph[i-1][j] == -1 && graph[i][j+1] == -1 && graph[i-1][j+1] == -1) {
						graph[i-1][j] = rand() % 100; //this is 100 (from 0 to 99)
						graph[i][j+1] = rand() % 100; //this is 100 (from 0 to 99)
						graph[i-1][j+1] = rand() % 100; //this is 100 (from 0 to 99)
					}
				} else if (j == size) { //bot right corner
					if (graph[i-1][j] == -1 && graph[i][j-1] == -1 && graph[i-1][j-1] == -1) {
						graph[i-1][j] = rand() % 100; 
						graph[i][j-1] = rand() % 100; 
						graph[i-1][j-1] = rand() % 100; 
					}
				} else { //just on bot row
					if (graph[i][j-1] == -1 && graph[i][j+1] == -1 &&
						graph[i-1][j-1] == -1 && graph[i-1][j] == -1 && graph[i-1][j+1] == -1) {

						graph[i][j-1] = rand() % 100; 
						graph[i][j+1] = rand() % 100; 
						graph[i-1][j-1] = rand() % 100;
						graph[i-1][j] = rand() % 100; 
						graph[i-1][j+1] = rand() % 100; 

					}
				}
			} else {
				if (graph[i-1][j-1] == -1 && graph[i-1][j] == -1 && graph[i-1][j+1] == -1 &&
					graph[i][j-1] == -1 && graph[i][j+1] == -1 &&
					graph[i+1][j-1] == -1 && graph[i+1][j] == -1 && graph[i+1][j+1] == -1) {

					graph[i-1][j-1] = rand() % 100;
					graph[i-1][j] = rand() % 100;
					graph[i-1][j+1] = rand() % 100;

					graph[i][j-1] = rand() % 100;
					graph[i][j+1] = rand() % 100;

					graph[i+1][j-1] = rand() % 100;
					graph[i+1][j] = rand() % 100;
					graph[i+1][j+1] = rand() % 100;
				}
			}
		}
	}

	return graph;
}

void printGraph(int** graph, int size) {
	int i = 0;
	for(;i < size; ++i) {
		int j = 0;
		for(;j < size; ++j) {
			printf("%d, ", graph[i][j]);
		}
		printf("\n");
	}
}

//for testing, keep to 10 by 10 grid

int main(int argc, char* const argv[]) {
	int n = atoi(argv[1]); //dimensions of generated array
	int* graph[n];

	int** graphTwo; //stores result of checkGraph func

	srand(time(NULL));

	int i = 0;
	for(; i < n; ++i) {
		int* a = malloc(sizeof(int) * n);
		int j = 0;
		for(; j < n; ++j) {
			int rando = rand() % 120; //this is 120 values (from 0 to 119),
			if (rando <= 100) { //gives -1 more chance to appear
				a[j] = rando; 
			} else {
				a[j] = -1; //too lazy to find how to include -1 in range when generating random number
			}
		}

		graph[i] = a;
	}

	graphTwo = checkGraph(graph, n);

	printGraph(graphTwo, n);

	for(i = 0; i < n; ++i) {
		free(graph[i]);
	}

	return 0;

}