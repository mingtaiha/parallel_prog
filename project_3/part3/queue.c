//Written By: Cedric Blake

//NOTE: this queue is for positive integers only!
//Inserts to head, removes from tail

#include <stdio.h>
#include <stdlib.h>
#include "linklist.h"
#include "queue.h"

//push to the queue
//Note, needed to make a double pointer so we could reference the head of the linklist
//this is to be able to change the pointers value to "pushNode" within the function
void queuePush(Node** headPointer, int pushVal) {
	Node* pushNode = malloc(sizeof(Node));
	pushNode->val = pushVal;
	pushNode->next = *headPointer;
	*headPointer = pushNode;
	return;
}

//pop from the queue
int queuePop(Node** headPointer) {
	Node* holder = *headPointer; //holds value to be referenced later

	if (*headPointer == NULL) { //if the link list is empty
		printf("Nothing to pop!\n");
		return -1;
	} 

	if ((*headPointer)->next == NULL) { //if there was only 1 element in the link list
		int returnVal = (*headPointer)->val;
		*headPointer = NULL;
		free(holder);
		return returnVal;
	}

	Node* iter = (*headPointer)->next;
	while(1) {
		if (iter->next == NULL) {
			(*headPointer)->next = NULL;
			int returnVal = iter->val;
			free(iter);
			*headPointer = holder;
			return returnVal;
		}
		*headPointer = iter; //holder always stays 1 step behind iter
		iter = iter->next;
	}
}

/* //queue test

int main(int argc, char const *argv[]) {
	int arrayA[] = {7,4,8,6,2,3,2,1};
	int* end = arrayA + sizeof(arrayA)/4;
	Node* head = linklistCreate(arrayA, end);

	linklistTraverse(head);
	queuePush(&head, 3);
	queuePush(&head, 6);
	linklistTraverse(head);

	while (head != NULL) {
		queuePop(&head);
		linklistTraverse(head);
	}


	linklistDestroy(head);
	return 0;
}

*/