#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

int main(int argc, char* argv[]) {
	if ( argc != 2)
	{
		printf("Too few arguments. Please supply n of an nxn square matrix");
		return -1;
	}	
	clock_t start = clock(), diff;
	double* y; // Input y
	int n = atoi(argv[1]);  //The n from nxn matrix
	int k; //Current row index, from 0 to n-1
	int i; // incrementer
	int j;
	double** A = (double**)malloc(n*sizeof(double*));
	if(A == NULL){printf("malloc failed");return -1;}

	y = (double*)malloc(n*sizeof(double)); // Initial values of y are irrelevant, y is overwritten and never read until written to.
        if(y == NULL){printf("malloc failed"); return -1;}

        double* q = (double*)malloc(n*sizeof(double));
	if(q == NULL){printf("malloc failed");return -1;}	

	for(k = 0; k < n; k++){
		if((A[k] = (double*) malloc(n*sizeof(double)))== NULL){
			printf("malloc failed"); return -1;}
		for(i = 0; i < n; i++){
			A[k][i] = (ceil(rand()%200) + 1);
		}
		q[i] = (ceil(rand()%200) + 1);
	}
	
	for (k = 0; k < n; k ++ ) { // Incrementing Rows
		for (i = k+1; i < n; i++) { // Incrementing Columns
			A[k][i] = A[k][i] / A[k][k];//Divide row by first number
		}
		y[k] = q[k] / A[k][k];// Store adjusted q value in y
		A[k][k] = 1;
		for (i = k+1; i < n; i++) {
			for (j = k; j < n; j++) {
	       			A[i][j] = A[i][j] - A[k][j] * A[i][k];
			}
			q[i] = q[i] - y[k] * A[i][k];// Commit adjusted q value
		}
	}
	diff = clock() - start;
	int msec = diff * 1000 / CLOCKS_PER_SEC;
	printf("Sequential implementation time taken: %d seconds, %d milliseconds\n", msec/1000, msec%1000);
	return 0;
}
