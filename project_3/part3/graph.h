#ifndef GRAPH_H_
#define GRAPH_H_

typedef struct vertex {
	int val;
	int vflag;
} vertex;

vertex** checkGraph(vertex** graph, int size);
void printGraph(vertex** graph, int size);
void genGraph(vertex*** graph, int size);
void destroyGraph(vertex** graph, int size);
void writeGraph(vertex** graph, char* fileName, long int size);
vertex** readGraph(char* fileName, long int size);

#endif