//Written By: Cedric Blake

//header file for link list

#include <stdio.h>
#include <stdlib.h>

#ifndef LINKLIST_H_
#define LINKLIST_H_

typedef struct Node {
	int val;
	int* coord; //used to find value on graph array
	struct Node* next;
} Node;

Node* linklistCreate(int* array, int* end);
void linklistTraverse(Node* head);
void linklistDestroy(Node* head);

#endif 