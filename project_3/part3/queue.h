//Written By: Cedric Blake

//header file for queue

#include <stdio.h>
#include <stdlib.h>

#ifndef QUEUE_H_
#define QUEUE_H_

void queuePush(Node** head, int pushVal, int* pushCoord);
Node queuePop(Node** head);

#endif