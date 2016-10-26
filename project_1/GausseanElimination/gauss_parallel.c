#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <math.h>

typedef struct matricies {
	double* Asub; // Sub matrix of A
	int size_Asub; // The number of rows passed to the worker thread
	double* q; // Input Matrix q
	double* y;  //Input Matrix y
	int k; // The current row index, from 0 to n-1
	int n; // The n from nxn matrix
	double* certainRow; // The row by which all the passed rows are to be multiplied
	int krt;  //The row index of the beginning of the 
	//subsection of the sub-problem to be solved that is to be passed to the worker
} mx;

//Takes 3 matricies.
void* worker_thread(void* args) {
	mx* data = (mx*)args;
	double* A = data->Asub;
	double* q = data->q;
	double* y = data->y;
	int n = data->n;
	int k = data->k;
	double* certainRow = data->certainRow;
	int size = data->size_Asub;
	int krt = data->krt;
	int i;
	int j;
	for (i = 0; i < size; i++) {
		for (j = k; j < n; j++) {
			//printf("Sub operation: %f - %f*%f\n",A[i*n +j], certainRow[j], A[k+i*n] );
                        A[i*n + j] = A[i*n + j] - certainRow[j] * A[k+i*n];
		}
		q[krt+i] = q[krt+i] - y[krt+i] * A[i*n];// Commit adjusted q value
	}
	return NULL;
}

int main(int argc, char* argv[]) {
	if ( argc != 2)
	{
		printf("Too few arguments. Please supply n of an nxn square matrix");
		return -1;
	}
	int n = atoi(argv[1]);
	double* y; // Input y
	int k; //Current row index, from 0 to n-1
	int i; // incrementer
	void* res;// result
	int threads; // The thread index
	int rows; // The number of rows left that we're passing to workers
	int leftover; // The number of rows left to pass to the leftover workers
	int actualThreads; // Number of threads actually used.
	int rt;//temporary variable to handle the leftover row in edge cases
	int nk1; //n - k - 1
	pthread_attr_t attr;
	
	pthread_attr_init(&attr);
	double* A = (double*)malloc(n*n);
        double* q = (double*)malloc(n);
	for(i = 0; i < n; i++){
		//printf("[ ");
		for(k = 0; k < n; k++){
			A[i*n+k] = (ceil(rand()%200) + 1);
		//	printf("%f " ,A[i*n+k]);
		}
		//printf(" ]\n");
		q[i] = (ceil(rand()%200) + 1);
	}
	
	y = (double*)malloc(n); // Initial values of y are irrelevant, y is overwritten and never read until written to. 
	
	clock_t start = clock(), diff;
	mx* tArgs = (mx*)malloc(4 * sizeof(mx));
	pthread_t *thread_handles = (pthread_t*) calloc(8,sizeof(pthread_t));
	pthread_t *backup_handles = (pthread_t*) calloc(8,sizeof(pthread_t));
		//	Parallel implementation: 
	for (k = 0; k < n; k ++ ) { // Incrementing Rows
		for (i = k+n*k; i < n*(k + 1); i++) { // Incrementing Columns
			A[i] = A[i] / A[k+n*k];//Divide row by first number
		}
		
		nk1 = n-k-1;
		y[k] = q[k] / A[k + n*k];// Store adjusted q value in y
		//	Hand each thread n/4 consecutive rows; one thread per CPU, and process the elimination.
		rows = (nk1) / 4;
		leftover = n-k;
		actualThreads = 0;
		rt = 0;
		//Calculate the number of threads we really need. 
		if(nk1 < 4){
			rows = nk1;//Note, this is nk numeral one, not L
			actualThreads = 1;
		}
		else{
			rows = nk1/4; // Guaranteed to be non zero
			actualThreads = 4;
			leftover = nk1 - rows*(actualThreads-2);
		}

		for (threads = 0; threads < actualThreads; threads++) {
			if (threads == 3) 
				rows = leftover; 
			tArgs[threads].Asub = &A[n*(k+rt+1)];
		//	The pointer to the first array entry of the worker thread's submatrix
			tArgs[threads].size_Asub = rows;
		//	Number of rows of said submatrix
			tArgs[threads].q = q;//Input matrix q (Passed as pointer to first entry of array)
			tArgs[threads].y = y;//Input matrix y (Passed as pointer to first entry of array)
			tArgs[threads].k = k;//Current row entry
			tArgs[threads].krt = k + rt;//Was once k+row*thread
			tArgs[threads].n = n;//Size of Original matrix
			tArgs[threads].certainRow = &A[n*k];// pointer to matrix entry at which the divisor row is

		//	Should be threadsafe, as no entry is modified by more than one worker.
			if(pthread_create(&thread_handles[threads], &attr, &worker_thread,
				(void *)&tArgs[threads])!= 0){
				backup_handles[threads] = thread_handles[threads];
				printf("pthread_create error at: %d\n", threads);
			}
			else {
				//printf("pthread_create success; thread: %d\n", threads);
			}
			rt += rows;
		}
		//	Wait for all threads to finish before proceeding
		for (threads = 0; threads<actualThreads; threads++) {
			if(backup_handles[threads]!=0){
				//printf("Attempting pthread join of thread: %d\n", threads);
				if (pthread_join(backup_handles[threads], &res) != 0) {
					printf("thread %d failed", threads);
				}
			}
			backup_handles[threads] = 0;
		}
	}

	diff = clock() - start;
	int msec = diff * 1000 / CLOCKS_PER_SEC;
	printf("Parallel implementation time taken: %d seconds, %d milliseconds\n", msec/1000, msec%1000);
	/*printf("Matrix A: \n");
	for(k = 0; k <  n; k++){
		for( i = 0; i < n; i++){
			printf("%f ", A[i + k*n]);
		}
		printf("\n");
	}
	printf("Matrix q: \n");
	for(k = 0; k < n; k++){
		printf("%f ", q[k]);
	}
	printf("\n");
	*/
	
	
	return 0;
}

