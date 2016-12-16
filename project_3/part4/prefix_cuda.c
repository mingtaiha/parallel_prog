//Cuda implementation of prefix finder
//Structure from NVIDIA tutorial slides
#define N 1000000
#define THREADS_PER_BLOCK 512

main(){

	int *a, *b, *c; //host ABC
	int *dev_a, *dev_b, *dev_c; 
	int size = N * sizeof(int);

	//cudamalloc a, b, and c on device memory

	cudaMalloc((void**)&dev_a, size);
	cudaMalloc((void**)&dev_b, size);
	cudaMalloc((void**)&dev_c, size);
	cudaMalloc((void**)&dev_B, size);
	cudaMalloc((void**)&dev_C, size);

	a = (int *) malloc(size);
	b = (int *) malloc(size);
	c = (int *) malloc(size);

	//Make random array
	for(i = 0; i < N; i++){
		a[i] = (int)(rand()%100);
	}

	cudaMemcpy (dev_a, a, size, cudaMemcpyHostToDevice);

	//Do find_repeats, store in dev_b
	find_repeats<<< N / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>(dev_a, dev_b);


	//Do exclusive scan on dev_b, store in dev_c
	exclusive_scan<<< N / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>(dev_b, dev_c);

	//Create B and C with some cuda operations on dev_c

	index_repeats <<< N / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>(dev_b, dev_c, dev_B);

	remove_repeats <<< N / THREADS_PER_BLOCK, THREADS_PER_BLOCK >>>(dev_a, dev_B, dev_C);

	cudaMemcpy(b, dev_b, size, cudaMemcpyDeviceToHost);
	cudaMemcpy(c, dev_c, size, cudaMemcpyDeviceToHost);

	printf("Last element of find_repeats: %d\n", 0); //replace

	cudaFree (dev_a);
	cudaFree (dev_b);
	cudaFree (dev_c);
	free(a);free(b);free(c);
	return 0;

}