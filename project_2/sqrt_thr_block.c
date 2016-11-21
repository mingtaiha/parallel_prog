#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include <pthread.h>
#include "array_gen.h"

#define TOLERANCE 0.0001


typedef struct thr_arg {
	int start;
	int end;
	pthread_t thr_id;
} thr_arg;


int ARR_SIZE;
int NUM_THREADS;
float * arr;
float * sqrt_arr;
//float * appx_arr;
thr_arg * arg_arr;


void define_args() {

	arg_arr = malloc(NUM_THREADS * sizeof(thr_arg));
	int equal_piece = ARR_SIZE / NUM_THREADS;
	
	int i;
	for (i = 0; i < NUM_THREADS; i++) {
		arg_arr[i].start = i * equal_piece;
		arg_arr[i].end = (i + 1) * equal_piece;
	}
	arg_arr[NUM_THREADS - 1].end = ARR_SIZE;

}

void * newton_thr(void * args) {

	thr_arg * tinfo = (thr_arg *) args;
	int start = tinfo->start;
	int end = tinfo->end;
	
	int i;
	for (i = start; i < end; i++) {
		float x = arr[i];
		while (fabs(x - sqrt_arr[i]) > TOLERANCE) {
			x = x - (((x * x) - arr[i]) / (2 * x));
		}
		//appx_arr[i] = x;
	}
}

int main(int argc, char ** argv) {

	char * arr_name = argv[1];
	char * sqrt_arr_name = argv[2];
    ARR_SIZE = atoi(argv[3]);
    NUM_THREADS = atoi(argv[4]);
    printf("size: %d\n", ARR_SIZE);
    printf("Num Threads: %d\n", NUM_THREADS);

	arr = read_array(arr_name, ARR_SIZE);
	sqrt_arr = read_array(sqrt_arr_name, ARR_SIZE);	
	//appx_arr = (float *) malloc(ARR_SIZE * sizeof(float));

	define_args();


	clock_t start, end;
	double cpu_time_used;
	int i, s;

	start = clock();
	for (i = 0; i < NUM_THREADS; i++) {
		pthread_create(&arg_arr[i].thr_id, NULL, &newton_thr, &arg_arr[i]);
	}
	for (i = 0; i < NUM_THREADS; i++) {
		pthread_join(arg_arr[i].thr_id, NULL);
	}
	end = clock();
	cpu_time_used = (((double) end) - ((double) start)) / CLOCKS_PER_SEC;

	printf("Parallel Runtime: %f\n", cpu_time_used);


	
//	print_array(sqrt_arr);
//	printf("\n");
//	print_array(appx_arr);

	free(arr);
	free(sqrt_arr);
	//free(appx_arr);
	return 0;
}

