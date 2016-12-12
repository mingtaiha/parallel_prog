#ifndef ARRAY_GEN_H
#define ARRAY_GEN_H

#include <time.h>
#include <stdlib.h>
#include <stdio.h>

double * make_array(int SIZE);
void print_array(double * array, int SIZE);
void write_array(double * array, char * filename, int SIZE);
double * read_array(char * filename, int SIZE);

#endif
