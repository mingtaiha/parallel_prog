#ifndef PROBLEM2_H
#define PROBLEM2_H

#include <stdlib.h>
#include <stdio.h>
#include "matrix_gen.h"


// Sequential Multiplication
double * mult_matrix_seq(double * A, double * B, int ROW_A, int COL_A, int ROW_B, int COL_B);

// GPU Multiplication
double * mat_mult_gpu_basic(double * A, double * B, int ROW_A, int COL_A, int ROW_B, int COL_B);
double * mat_mult_gpu_cublas(double * A, double * B, int ROW_A, int COL_A, int ROW_B, int COL_B);
double * mat_mult_gpu_optimized(double * A, double * B, int ROW_A, int COL_A, int ROW_B, int COL_B);

#endif
