#ifndef MATRIX_GEN_H
#define MATRIX_GEN_H

#include <time.h>
#include <stdlib.h>
#include <stdio.h>


double * make_matrix(int ROW, int COL);
void print_matrix(double * matrix, int ROW, int COL);
void write_matrix(double * matrix, char * filename, int ROW, int COL);
double * read_matrix(char * filename, int ROW, int COL);
double * diff_matrix(double * mat1, double * mat2, int ROW1, int COL1, int ROW2, int COL2);

#endif
