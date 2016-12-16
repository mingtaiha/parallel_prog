#include "array_gen.h"


double * make_array(long int SIZE) {
	double * array = (double *) malloc(SIZE * sizeof(double));
	srand(time(NULL));

	long int i;
	for (i = 0; i < SIZE; i++) {
		array[i] = (double)rand() / (double)RAND_MAX * 1000;
	}
	return array;
}

void print_array(double * array, long int SIZE) {
	long int i;
	for (i = (SIZE - 25); i < SIZE; i++) {
		printf("%f\n", array[i]);
	}
}

void write_array(double * array, char * filename, long int SIZE) {
	FILE *f = fopen(filename, "wb");
	printf("Writing Array\n");
	fwrite(array, sizeof(double), SIZE, f);
	fclose(f);
}

double * read_array(char * filename, long int SIZE) {
	double * array = (double *) malloc(SIZE * sizeof(double));
	FILE *f = fopen(filename, "rb");
	if (f == NULL) {
		printf("Error reading File\n");
		exit(0);
	}
	printf("Reading Array\n");
	fread(array, sizeof(double), SIZE, f);
	return array;
}
