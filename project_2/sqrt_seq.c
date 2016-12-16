#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include "array_gen.h"


float * arr;
float * sqrt_arr;
float * appx_arr;
float tolerance = 0.0001;

void * newton_seq(int size) {

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

int main(int argc, char * argv[]) {

	char * arr_name = argv[1];
	char * sqrt_arr_name = argv[2];
    int size = atoi(argv[3]);    

    arr = read_array(arr_name, size);
	sqrt_arr = read_array(sqrt_arr_name, size);	
    appx_arr = (float *) malloc(size * sizeof(float));

    print_array(arr);
    print_array(sqrt_arr);

	clock_t start, end;
	double cpu_time_used;

	start = clock();
	newton_seq(size);
	end = clock();
	cpu_time_used = (((double) end) - ((double) start)) / CLOCKS_PER_SEC;

	printf("Sequential Runtime: %f\n", cpu_time_used);
	
//	print_array(sqrt_arr);
//	printf("\n");
//	print_array(appx_arr);

	return 0;
}

