#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include "array_gen.h"


float * arr;
float * sqrt_arr;
float * appx_arr;
int size = 30000000;
float tolerance = 0.0001;


void * newton_seq() {

	int start = 0;
	int end = size;
	
	int i;
	for (i = start; i < end; i++) {
		float x = arr[i];
		while (fabs(x - sqrt_arr[i]) > tolerance) {
			x = x - (((x * x) - arr[i]) / (2 * x));
		}
		appx_arr[i] = x;
	}
}

int main() {

	char arr_name[] = "arr_30m.dat";
	char sqrt_arr_name[] = "sqrt_arr_30m.dat";
	arr = read_array(arr_name);
	sqrt_arr = read_array(sqrt_arr_name);	
	appx_arr = (float *) malloc(size * sizeof(float));
	
	clock_t start, end;
	double cpu_time_used;

	start = clock();
	newton_seq();
	end = clock();
	cpu_time_used = (((double) end) - ((double) start)) / CLOCKS_PER_SEC;

	printf("Sequential Runtime: %f\n", cpu_time_used);
	
//	print_array(sqrt_arr);
//	printf("\n");
//	print_array(appx_arr);

	return 0;
}

