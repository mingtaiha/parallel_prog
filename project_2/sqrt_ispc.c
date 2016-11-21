#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include "array_gen.h"
#include "newton.h"


float * arr;
float * appx_arr;
float tolerance = 0.0001;

int main(int argc, char* argv[] ) {
	if(argc!=5){
		printf("syntax: ./sqrt_ispc [array] [num elements to inspect] [cores] [threads]");
		return -1;
	}
	char * arr_name = argv[1];
	float size = atoi(argv[2]);
	int cores = atoi(argv[3]);
	//Could error check on cores here.
	if(cores < 1){
		printf("Invalid number of cores.");
		return -1;
	}
	int threads = atoi(argv[4]);
	arr = read_array(arr_name);
	sqrt_arr = read_array(sqrt_arr_name);	
	appx_arr = (float *) calloc(SIZE * sizeof(float));
	clock_t begin = clock();
	newton_ispc(size, threads, cores, arr, appx_arr);
	clock_t end = clock();
	double time = (double) (end-begin) / CLOCKS_PER_SEC;
	
	print_array(sqrt_arr);
	printf("\n");
	print_array(appx_arr);
	printf("%f\n",time);
	return 0;
}
