#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "array_gen.h"

#define SIZE 15000000

float * arr;
float * sqrt_arr;
float * appx_arr;
int size = 15000000;
float tolerance = 0.0001;


void * newton_seq() {

	int start = 0;
	int end = size;
	
	int i;
	for (i = start; i < end; i++) {
		float x = arr[i];
		while (fabs(x - sqrt_arr[i]) > tolerance) {
			x = x - ((pow(x,2) - arr[i]) / (2 * x));
		}
		appx_arr[i] = x;
	}
}

int main() {

	char arr_name[] = "arr_15m.dat";
	char sqrt_arr_name[] = "sqrt_arr_15m.dat";
	arr = read_array(arr_name);
	sqrt_arr = read_array(sqrt_arr_name);	
	appx_arr = (float *) malloc(SIZE * sizeof(float));
	
	newton_seq();
	
	print_array(sqrt_arr);
	printf("\n");
	print_array(appx_arr);

	return 0;
}

