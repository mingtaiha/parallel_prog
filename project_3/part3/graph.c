/* NEED TO ASK THESE QUESTIONS IN CLASS

1) are the values of each vertex unique within the graph?
2) are all vertecies expected to be connected with at least 1 other vertex?

right now this generates an array of size n (n is script input) and generates
random numbers between -1 and 99. there is no check for value uniqueness or vertex connection
*/



//n x n array where n > 100, -1 denotes no value (disconnect) of graph
//every value around a value is concidered to be connected to that value
	//this design choice minimizes the likelyhood that a vertex will be disconnected from the graph
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "linklist.h"
#include "queue.h"

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

	printGraph(graph, n);

	for(i = 0; i < n; ++i) {
		free(graph[i]);
	}

	return 0;

}