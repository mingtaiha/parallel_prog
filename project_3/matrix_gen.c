#include <time.h>
#include <stdlib.h>
#include <stdio.h>


double ** make_matrix(int ROW, int COL) {
	double ** matrix = (double **) malloc(ROW * sizeof(double *));
	srand(time(NULL));

	int i, j;
	for (i = 0; i < ROW; i++) {
		matrix[i] = (double *) malloc(COL * sizeof(double));
		for (j = 0; j < COL; j++) {
			matrix[i][j] = (double)rand() / (double)RAND_MAX * 1000;
		}
	}
	return matrix;
}

void print_matrix(double ** matrix, int ROW, int COL) {
	int i;
	for (i = (ROW - 25); i < ROW; i++) {
		printf("%f\n", matrix[i][COL - 1]);
	}
}

void write_matrix(double ** matrix, char * filename, int ROW, int COL) {
	FILE *f = fopen(filename, "wb");
	printf("Writing Matrix\n");
	int i;
	for (i = 0; i < ROW; i++) {
		fwrite(matrix[i], sizeof(double), COL, f);
	}
}

double ** read_matrix(char * filename, int ROW, int COL) {
	double ** matrix = (double **) malloc(ROW * sizeof(double *));
	FILE *f = fopen(filename, "rb");
	if (f == NULL) {
		printf("Error reading file\n");
		exit(0);
	}
	printf("Reading Matrix\n");
	int i;
	for (i = 0; i < ROW; i++){
		matrix[i] = (double *) malloc(COL * sizeof(double));
		fread(matrix[i], sizeof(double), COL, f);
	}
	return matrix;
}

int main(int argc, char * argv[]) {

	char * mat_name = argv[1];
	int ROW = atoi(argv[2]);
    int COL = atoi(argv[3]);
	double ** mat = make_matrix(ROW, COL);
	print_matrix(mat, ROW, COL);
	write_matrix(mat, mat_name, ROW, COL);
	double ** mat2 = read_matrix(mat_name, ROW, COL);
	print_matrix(mat, ROW, COL);

	return 0;	
}
