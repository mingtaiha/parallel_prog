#ifndef PROBLEM1_H_
#define PROBLEM1_H_

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <unistd.h>

#include "array_gen.h"


// CPU implementations
double max_array_seq(double *arr, long int SIZE);
double min_array_seq(double *arr, long int SIZE);
double avg_array_seq(double *arr, long int SIZE);
double std_array_seq(double *arr, long int SIZE);

// GPU implementation

void hello_gpu(char *a, int *b, const int N, const int blocksize);
void max_gpu(double *array, long int size, int tpb);
void min_gpu(double *array, long int size, int tpb);
void avg_gpu(double *array, long int size, int tpb);
void std_gpu(double *array, long int size, int tpb);

#endif
