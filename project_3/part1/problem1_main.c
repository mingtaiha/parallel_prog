#include "problem1.h"

int main(int argc, char **argv)
{
	long int SIZE = atol(argv[1]);
	int tpb = atoi(argv[2]);
	printf("Making array\n");
	double *arr = make_array(SIZE);

	printf("\n\n");

	printf("CPU Part\n");
	double max = max_array_seq(arr, SIZE);
	printf("Max: %f\n", max);
	double min = min_array_seq(arr, SIZE);
	printf("Min: %f\n", min);
	double avg = avg_array_seq(arr, SIZE);
	printf("Avg: %f\n", avg);
	double std = std_array_seq(arr, SIZE);
	printf("Std: %f\n", std);

	printf("\n\n");

	printf("GPU Part\n");
	max_gpu(arr, SIZE, tpb);
	min_gpu(arr, SIZE, tpb);
	avg_gpu(arr, SIZE, tpb);
	std_gpu(arr, SIZE, tpb);

	return 0;
}
