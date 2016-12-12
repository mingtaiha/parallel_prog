#include "problem1.h"

int main(int argc, char **argv)
{
	int SIZE = atoi(argv[1]);
	printf("Making array\n");
	double *arr = make_array(SIZE);

	double max = max_array_seq(arr, SIZE);
	printf("Max: %f\n", max);
	double min = min_array_seq(arr, SIZE);
	printf("Min: %f\n", min);
	double avg = avg_array_seq(arr, SIZE);
	printf("Avg: %f\n", avg);
	double std = std_array_seq(arr, SIZE);
	printf("Std: %f\n", std);

	int tpb = 512;
	max_gpu(arr, SIZE, tpb);

	return 0;
}
