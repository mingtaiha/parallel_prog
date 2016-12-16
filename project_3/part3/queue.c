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
void queuePush(Node** headPointer, int pushVal, int* pushCoord) { //set pushCoord to NULL if you dont care about coord value
	Node* pushNode = malloc(sizeof(Node));
	pushNode->val = pushVal;
	pushNode->coord = pushCoord;
	if(*headPointer == NULL) { //if there is nothing in the queue initially
		pushNode->next = NULL;
	} else {
		pushNode->next = *headPointer;
	}
	*headPointer = pushNode;
	return;
}

//pop from the queue
Node queuePop(Node** headPointer) {
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
	while(1) {
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

//  //queue test

// int main(int argc, char const *argv[]) {
// 	int arrayA[] = {7,4,8,6,2,3,2,1};
// 	int* end = arrayA + sizeof(arrayA)/4;
// 	Node* head = linklistCreate(arrayA, end);

// 	linklistTraverse(head);
// 	queuePush(&head, 3, NULL);
// 	queuePush(&head, 6, NULL);
// 	linklistTraverse(head);

// 	while (head != NULL) {
// 		queuePop(&head);
// 		linklistTraverse(head);
// 	}


// 	linklistDestroy(head);
// 	return 0;
// }

