#include <time.h>
#include <stdlib.h>
#include <stdio.h>


int SIZE;

double * make_array() {
	double * array = (double *) malloc(SIZE * sizeof(double));
	srand(time(NULL));

	int i;
	for (i = 0; i < SIZE; i++) {
		array[i] = (double)rand() / (double)RAND_MAX * 1000;
	}
	return array;
}

void print_array(double * array) {
	int i;
	for (i = (SIZE - 25); i < SIZE; i++) {
		printf("%f\n", array[i]);
	}
}

void write_array(double * array, char * filename) {
	FILE *f = fopen(filename, "wb");
	printf("Writing Array\n");
	fwrite(array, sizeof(double), SIZE, f);
	fclose(f);
}

double * read_array(char * filename) {
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


int main(int argc, char * argv[]) {

	char * arr_name = argv[1];
	SIZE = atoi(argv[2]);
	double * arr = make_array();
	print_array(arr);
	write_array(arr, arr_name);
	double * arr2 = read_array(arr_name);
	print_array(arr2);

	return 0;
}
