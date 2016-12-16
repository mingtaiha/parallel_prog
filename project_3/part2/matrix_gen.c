#include <time.h>
#include <stdlib.h>
#include <stdio.h>


#define TEST 0

double * make_matrix(int ROW, int COL) {
	double * matrix = (double *) malloc(ROW * COL * sizeof(double));
	srand(time(NULL));

	int i;
	for (i = 0; i < (ROW * COL); i++) {
		matrix[i] = (double)rand() / (double)RAND_MAX * 1000;
	}
	return matrix;
}

void print_matrix(double * matrix, int ROW, int COL) {
	int i;
	for (i = ((ROW * COL) - 25); i < (ROW * COL); i++) {
		printf("%f\n", matrix[i]);
	}
}

void write_matrix(double * matrix, char * filename, int ROW, int COL) {
	FILE *f = fopen(filename, "wb");
	printf("Writing Matrix\n");
	fwrite(matrix, sizeof(double), ROW * COL, f);
}

double* read_matrix(char * filename, int ROW, int COL) {
	double * matrix = (double *) malloc(ROW * COL * sizeof(double));
	FILE *f = fopen(filename, "rb");
	if (f == NULL) {
		printf("Error reading file\n");
		exit(0);
	}
	printf("Reading Matrix\n");
	fread(matrix, sizeof(double), ROW * COL, f);
	
	return matrix;
}

double diff_matrix(double * mat1, double * mat2, int ROW1, int COL1, int ROW2, int COL2)
{
	if ((ROW1 != ROW2) || (COL1 != COL2))
	{
		printf("Matrix Dimensions don't match\n");
		return -1;
	}
	else
	{
		double mse = 0;

		int i;
		for (i = 0; i < ROW1 * COL1; i++)
		{
			mse = (mat1[i] - mat2[i]) * (mat1[i] - mat2[i]);
		}
		mse /= ((double)ROW1 * (double)COL1);
		return mse;
	}
}

#if TEST

int main(int argc, char * argv[]) {

	char * mat_name = argv[1];
	int ROW = atoi(argv[2]);
	int COL = atoi(argv[3]);
	double * mat = make_matrix(ROW, COL);
	print_matrix(mat, ROW, COL);
	write_matrix(mat, mat_name, ROW, COL);
	double * mat2 = read_matrix(mat_name, ROW, COL);
	print_matrix(mat, ROW, COL);

	return 0;	
}

#endif
