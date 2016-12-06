//Written By: Cedric Blake

//this is a licklist implementation for positive integers

#include <stdio.h>
#include <stdlib.h>
#include "linklist.h"



Node* linklistCreate(int* array, int* end) {
	//set head to point to the first Node
	//remember to deallocate this memory
	Node* head = malloc(sizeof(Node));

	Node* iter = head;

	while(1) {
		iter->val = *array;
		array+=1; //incriment array here to test if this element (iter->val) is the last
		if (array == end) {
			iter->next = NULL;
			break;
		} else {
			iter->next = malloc(sizeof(iter));
			iter = iter->next; //set iter to the pointer of the next Node
		}
	}
	
	
	return head;
}

void linklistTraverse(Node* head){
	Node* iter = head;
	if (head == NULL) {
		printf("No elements to print!\n");
		return;
	}

	do { //do/while takes into account case when only 1 element exists
		printf("%d, ", iter->val);
		iter = iter->next;
	} while(iter != NULL);
	printf("\n");
}

void linklistDestroy(Node* head) {
	Node* iter = head;
	if (head == NULL) {
		printf("no linklist to destroy!\n");
		return;
	}

	do {
		free(iter);
		iter = iter->next;
	} while(iter != NULL);
	printf("linklist destroyed!\n");
}

/* //link list test

int main() {
	int arrayA[] = {7,4,8,6,2,3,2,1};
	int* end = arrayA + sizeof(arrayA)/4;
	Node* head = linklistCreate(arrayA, end);
	linklistTraverse(head);

	linklistDestroy(head);

}

*/
