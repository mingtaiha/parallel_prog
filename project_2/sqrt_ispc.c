#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include "array_gen.h"
#include "newton.h"

#define SIZE 15000000

float * arr;
float * sqrt_arr;
float * appx_arr;
float tolerance = 0.0001;


int main() {

	char arr_name[] = "arr_15m.dat";
	char sqrt_arr_name[] = "sqrt_arr_15m.dat";
	arr = read_array(arr_name);
	sqrt_arr = read_array(sqrt_arr_name);	
	appx_arr = (float *) calloc(SIZE * sizeof(float));
	clock_t begin = clock();
	newton_ispc();
	clock_t end = clock();
	double time = (double) (end-begin) / CLOCKS_PER_SEC;
	
	print_array(sqrt_arr);
	printf("\n");
	print_array(appx_arr);
	printf("%f\n",time);
	return 0;
}
