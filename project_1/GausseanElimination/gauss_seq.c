#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main() {
	clock_t start = clock(), diff;
	double* y; // Input y
	int n;  //The n from nxn matrix
	int k; //Current row index, from 0 to n-1
	int i; // incrementer
	int j;
	n = 3; // Arbitrarily large
	double A[9] = { 1, 1, 8, 3, 6, 7, 9, 2, 1 }; // Implement as a large flat n*n array
	double q[3] = { 8, 74, 9 };
	
	//A = (int*)malloc(n*n);
	//q = (int*)malloc(n);
	y = (double*)malloc(n); // Initial values of y are irrelevant, y is overwritten and never read until written to. 
	
	for (k = 0; k < n; k ++ ) { // Incrementing Rows
		for (i = k+n*k; i < n*(k + 1); i++) { // Incrementing Columns
			A[i] = A[i] / A[k+n*k];//Divide row by first number
		}
		y[k] = q[k] / A[k + n*k];// Store adjusted q value in y
		for (i = 0; i < n; i++) {
			for (j = k; j < n; j++) {
				//printf("Sub operation: %f - %f*%f\n",A[i*n +j], A[n*k+j], A[k+i*n] );
	       			A[i*n + j] = A[i*n + j] - A[n*k+j] * A[k+i*n];
			}
			q[i] = q[i] - y[i] * A[i];// Commit adjusted q value
		}
	}
	diff = clock() - start;
	int msec = diff * 1000 / CLOCKS_PER_SEC;
	printf("Sequential implementation time taken: %d seconds, %d milliseconds\n", msec/1000, msec%1000);
	return 0;
}
