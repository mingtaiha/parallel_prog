#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <math.h>

typedef struct matricies {
	double** Asub; // Sub matrix of A
	int size_Asub; // The number of rows passed to the worker thread
	int numThreads; // The user defined number of threads +1 for main
	pthread_barrier_t *barrier_worker;//Start worker threads
	pthread_barrier_t *barrier_main;//Start main thread edits of data
	double* q; // Input Matrix q
	double* y;  //Input Matrix y
	int k; // The current row index, from 0 to n-1
	int n; // The n from nxn matrix
	double* certainRow; // The row by which all the passed rows are to be multiplied
	int krt;  //The row index of the beginning of the 
	//subsection of the sub-problem to be solved that is to be passed to the worker
	int enable; //If there are more threads than rows at any point, we disable some threads.
} mx;

//Takes 3 matricies.
void* worker_thread(void* args) {
	mx* data = (mx*)args;
	pthread_barrier_t *barrier_worker = data->barrier_worker;
	pthread_barrier_t *barrier_main = data->barrier_main;
	double** A;
	double* q;
	double* y;
	int n = 10;
	int k = -1;
	int numThreads;
	double* certainRow;
	int size;
	int krt, i, j;
	int enable;

	while(k < n-1){
		//Wait for all threads to finish
		//Barrier here
		pthread_barrier_wait(barrier_worker);
		enable = data->enable;
		if(enable){
			A = data->Asub;
			q = data->q;
			y = data->y;
			n = data->n;
			k = data->k;
			certainRow = data->certainRow;
			size = data->size_Asub;
			krt = data->krt;

			for (i = 0; i < size; i++) {
				for (j = k; j < n; j++) {
		                        A[i][j] = A[i][j] - certainRow[j] * A[i][k];
				}
				q[krt+i] = q[krt+i] - y[krt] * A[i][k];// Commit adjusted q value
			}
		}
		pthread_barrier_wait(barrier_main);//Tell the main thread you're done so it can fiddle with data
	}

	return NULL;
}

int main(int argc, char* argv[]) {
	if ( argc != 3)
	{
		printf("Please supply n of an nxn square matrix, and the number of threads desired respectively.");
		return -1;
	}
	int n = atoi(argv[1]);
	int desired = atoi(argv[2]);
	double* y; // Input y
	int k; //Current row index, from 0 to n-1
	int i; // incrementer
	void* res;// result
	int threads; // The thread index
	int rows; // The number of rows left that we're passing to workers
	int actualThreads; // Number of threads actually used.
	int nk1; //n - k - 1
	int rt; //Describes current row position of the submatrices
	int enable; //1 if thread has work to do, 0 if not
	pthread_attr_t attr;
	
	pthread_attr_init(&attr);
	//Array memory allocation
	double** A = (double**)malloc(n*sizeof(double*));
	if(A == NULL){printf("malloc failed");return -1;}
        double* q = (double*)malloc(n*sizeof(double));
	if(q == NULL){printf("malloc failed");return -1;}
	y = (double*)malloc(n*sizeof(double)); // Initial values of y are irrelevant, y is overwritten and never read until written to. 
	if(y == NULL){printf("malloc failed"); return -1;}

	//Array generation
	for(k = 0; k < n; k++){
		if((A[k] = (double*) malloc(n*sizeof(double)))== NULL){
			printf("malloc failed"); return -1;}
		for(i = 0; i < n; i++){
			A[k][i] = (ceil(rand()%200) + 1);
		}
		q[i] = (ceil(rand()%200) + 1);
	}

	//Start timing.
	clock_t start = clock(), diff;
	//Allocate space for the thread handles and initialize synchronization barrier
	mx* tArgs = (mx*)malloc(desired * sizeof(mx));
	pthread_t *thread_handles = (pthread_t*) calloc(2*desired,sizeof(pthread_t));
	pthread_t *backup_handles = (pthread_t*) calloc(2*desired,sizeof(pthread_t));

	pthread_barrier_t *barrier_worker;// = (pthread_barrier_t*) calloc(1, sizeof(pthread_barrier_t));
	pthread_barrier_init(barrier_worker, NULL, desired+1); //Initialize the worker thread barrier

	pthread_barrier_t *barrier_main;// = (pthread_barrier_t*) calloc(1, sizeof(pthread_barrier_t));
	pthread_barrier_init(barrier_main, NULL, desired+1); //Initialize the main thread barrier
	actualThreads = desired+1; // We have (desired) worker threads and (1) main thread

	//Create the threads with the barrier, pass other parameters in later
	//Have the threads wait at the barrier for the data, then read and do their work.
	for (threads = 0; threads < actualThreads; threads++) {
		tArgs[threads].barrier_worker = barrier_worker;
		tArgs[threads].barrier_main = barrier_main;
		//Pass in only the barriers at first
		//Should be threadsafe, as no entry is modified by more than one worker.
		if(pthread_create(&thread_handles[threads], &attr, &worker_thread,
			(void *)&tArgs[threads])!= 0){
			backup_handles[threads] = thread_handles[threads];
			printf("pthread_create error at: %d\n", threads);
		}
		//else {
		//	printf("pthread_create success; thread: %d\n", threads);
		//}
	}

		//	Parallel implementation:
	for (k = 0; k < n; k ++ ) { // Incrementing Rows
		for (i = k+1; i < n; i++) { // Incrementing Columns
			A[k][i] = A[k][i] / A[k][k];//Divide row by first number
		}
		y[k] = q[k] / A[k][k];// Store adjusted q value in y
		A[k][k] = 1;

		nk1 = n-k-1;
		//	Hand each thread n/desired consecutive rows; one thread per CPU, and process the elimination.
		rows = (nk1) / desired;
		rt = 0;
		//Calculate the number of threads we really need.
		for (threads = 0; threads < desired; threads++) {
		// If we have more threads than rows, give each thread 1 row and disable the rest
			if(desired > nk1){
				if(threads < nk1){
					rows = 1;
					enable = 1;
				}
				else{
					enable = 0;
				}
			}
			if(enable){
				tArgs[threads].enable = 1;
				//set args
				if (threads == desired-1) 
					rows = nk1 - rt; // If there are more rows leftover, assign them all to the last worker
				tArgs[threads].Asub = &A[k+rt+1];
				//The pointer to the first array entry of the worker thread's submatrix
				tArgs[threads].size_Asub = rows;
				//Number of rows of said submatrix
				tArgs[threads].q = q;//Input matrix q (Passed as pointer to first entry of array)
				tArgs[threads].y = y;//Input matrix y (Passed as pointer to first entry of array)
				tArgs[threads].k = k;//Current row entry
				tArgs[threads].krt = k + rt;//describes the beginning row value of the submatrix 
				tArgs[threads].n = n;//Size of Original matrix
				tArgs[threads].numThreads = desired+1;
				tArgs[threads].certainRow = A[k];// pointer to matrix entry at which the divisor row is
				rt += rows;
			}
			else{
				//if disabled, we have no rows to give.
				tArgs[threads].enable = 0;
			}
		}//All thread arguments set properly

		//Signal threads to begin working.
		pthread_barrier_wait(barrier_worker);

		//Wait for the workers to all finish before we start changing the data
		pthread_barrier_wait(barrier_main);

	}// Matrix in rref form

	//	Clean up the threads.
	for (threads = 0; threads<actualThreads; threads++) {
		if(backup_handles[threads]!=0){
			//printf("Attempting pthread join of thread: %d\n", threads);
			if (pthread_join(backup_handles[threads], &res) != 0) {
				printf("thread %d failed", threads);
			}
		}
		backup_handles[threads] = 0;
	}
	//	Free the barriers
	pthread_barrier_destroy(barrier_main);
	pthread_barrier_destroy(barrier_worker);
	//	Free all the malloced variables
	for(i = 0; i < n; i++){
		free(A[i]);
	}
	free(A); free(y); free(q);
	free(thread_handles);
	free(backup_handles);


	diff = clock() - start;
	int msec = diff * 1000 / CLOCKS_PER_SEC;
	printf("Parallel implementation time taken: %d seconds, %d milliseconds\n", msec/1000, msec%1000);	
	
	return 0;
}

