#ifndef PROBLEM1_H_
#define PROBLEM1_H_

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <unistd.h>

#include "array_gen.h"


// CPU implementations
double max_array_seq(double *arr, int SIZE);
double min_array_seq(double *arr, int SIZE);
double avg_array_seq(double *arr, int SIZE);
double std_array_seq(double *arr, int SIZE);

// GPU implementation

void hello_gpu(char *a, int *b, const int N, const int blocksize);
void max_gpu(double *array, int size, int tpb);

#endif
