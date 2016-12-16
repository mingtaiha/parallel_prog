#include <time.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include "problem1.h"


__global__ void hello(char *a, int *b)
{
	a[threadIdx.x] += b[threadIdx.x];
}

void hello_gpu(char *a, int *b, const int N, const int blocksize) {

	char *ad;
	int *bd;
	const int csize = N*sizeof(char);
	const int isize = N*sizeof(int);

	printf("%s", a);

	cudaMalloc( (void**)&ad, csize );
	cudaMalloc( (void**)&bd, isize );
	cudaMemcpy( ad, a, csize, cudaMemcpyHostToDevice );
	cudaMemcpy( bd, b, isize, cudaMemcpyHostToDevice );

	dim3 dimBlock( blocksize, 1 );
	dim3 dimGrid( 1, 1 );
	hello<<<dimGrid, dimBlock>>>(ad, bd);

	cudaMemcpy( a, ad, csize, cudaMemcpyDeviceToHost );
	cudaFree( ad );
	cudaFree( bd );
	printf("%s\n", a);
	sleep(1);
}


__global__ void kernel_max(double * array, double * max, long int num_elem)
{

	
	extern __shared__ double sdata[];
	unsigned long int tid = threadIdx.x;
	unsigned long int idx = (blockIdx.x * blockDim.x) + threadIdx.x;

	
	sdata[tid] = array[idx];
	//unsigned int i = (unsigned int)ceil((float)blockDim.x/2);
	__syncthreads();

	unsigned long int i;
	for ( i = 1; i < blockDim.x; i*=2)
	{
		if ((tid % (2*i) == 0) && (idx + i < num_elem)) 
		{
			sdata[tid] = (sdata[tid] > sdata[tid + i]) ? sdata[tid] : sdata[tid + i];
		}
		__syncthreads();
	}
	__syncthreads();

	if ( tid == 0 )
	{
		max[blockIdx.x] = sdata[tid];
	}
	

/*
	long int idx = (blockIdx.x * blockDim.x) + threadIdx.x;

	max[idx] = array[idx];

	__syncthreads();

	long int i;
	for (i = 1; i < num_elem ; i*=2)
	{
		if ((idx % (2*i) == 0) && (idx + i < num_elem))
		{
			max[idx] = (max[idx] > max[idx + i]) ? max[idx] : max[idx + i];
		}
		__syncthreads();
	}
	__syncthreads();
*/	
}

void max_gpu(double *array, long int size, int tpb)
{

	long int nblocks = (long int)ceil((double)size / (double)tpb);
	//printf("N blocks: %ld\n", nblocks);

	double *dev_array, *dev_array2;
	double *dev_max_array;
	long int arr_size = size * sizeof(double);

	double *max_array = (double *) malloc(size * sizeof(double));
	//printf("%f\n", max_array[0]);


	//printf("cudaMalloc'ing\n");
	cudaMalloc( (void**)&dev_array, arr_size);
	cudaMalloc( (void**)&dev_array2, arr_size);
	cudaMalloc( (void**)&dev_max_array, nblocks * sizeof(double));

	//printf("cudaMemcpy to device\n");
	cudaMemcpy(dev_array, array, arr_size, cudaMemcpyHostToDevice);

	clock_t start, end;
	start = clock();

	int count = 0;
	while (nblocks >= 1) {
		//printf("Calling kernel_max\n");
		//printf("nblocks: %ld\n", nblocks);
		if (count % 2 == 0) {
			kernel_max<<<nblocks, tpb, tpb * sizeof(double)>>>(dev_array, dev_array2, size);
		}
		else
		{
			kernel_max<<<nblocks, tpb, tpb * sizeof(double)>>>(dev_array2, dev_array, size);
		}
		cudaThreadSynchronize();
		if (nblocks == 1) { break; }
		count++;
		size = nblocks;
		nblocks = (long int)ceil((double)size / (double)tpb);
	}
	end = clock();
	printf("Time for Max: %f\n", (((double)end - (double)start)) / CLOCKS_PER_SEC);

	if (count % 2 == 0) {	
		cudaMemcpy(max_array, dev_array2, nblocks * sizeof(double), cudaMemcpyDeviceToHost);
	}
	else
	{
		cudaMemcpy(max_array, dev_array, nblocks * sizeof(double), cudaMemcpyDeviceToHost);
	}

	printf( "Max: %f\n", max_array[0] );

	free( max_array );
	cudaFree( dev_array );
	cudaFree( dev_array2 );
	cudaFree( dev_max_array );
}



__global__ void kernel_min(double * array, double * max, long int num_elem)
{

	
	extern __shared__ double sdata[];
	unsigned long int tid = threadIdx.x;
	unsigned long int idx = (blockIdx.x * blockDim.x) + threadIdx.x;

	
	sdata[tid] = array[idx];
	__syncthreads();

	unsigned long int i;
	for ( i = 1; i < blockDim.x; i*=2)
	{
		if ((tid % (2*i) == 0) && (idx + i < num_elem)) 
		{
			sdata[tid] = (sdata[tid] < sdata[tid + i]) ? sdata[tid] : sdata[tid + i];
		}
		__syncthreads();
	}
	__syncthreads();

	if ( tid == 0 )
	{
		max[blockIdx.x] = sdata[tid];
	}
}


void min_gpu(double *array, long int size, int tpb)
{

	long int nblocks = (long int)ceil((double)size / (double)tpb);
	//printf("N blocks: %ld\n", nblocks);

	double *dev_array, *dev_array2;
	double *dev_min_array;
	long int arr_size = size * sizeof(double);

	double *min_array = (double *) malloc(size * sizeof(double));

	//printf("cudaMalloc'ing\n");
	cudaMalloc( (void**)&dev_array, arr_size);
	cudaMalloc( (void**)&dev_array2, arr_size);
	cudaMalloc( (void**)&dev_min_array, nblocks * sizeof(double));

	//printf("cudaMemcpy to device\n");
	cudaMemcpy(dev_array, array, arr_size, cudaMemcpyHostToDevice);

	clock_t start, end;
	start = clock();

	int count = 0;
	while (nblocks >= 1) {
		//printf("Calling kernel_min\n");
		//printf("nblocks: %ld\n", nblocks);
		if (count % 2 == 0) {
			kernel_min<<<nblocks, tpb, tpb * sizeof(double)>>>(dev_array, dev_array2, size);
		}
		else
		{
			kernel_min<<<nblocks, tpb, tpb * sizeof(double)>>>(dev_array2, dev_array, size);
		}
		cudaThreadSynchronize();
		if (nblocks == 1) { break; }
		count++;
		size = nblocks;
		nblocks = (long int)ceil((double)size / (double)tpb);
	}
	end = clock();
	printf("Time for Min: %f\n", (((double)end - (double)start)) / CLOCKS_PER_SEC);

	if (count % 2 == 0) {	
		cudaMemcpy(min_array, dev_array2, nblocks * sizeof(double), cudaMemcpyDeviceToHost);
	}
	else
	{
		cudaMemcpy(min_array, dev_array, nblocks * sizeof(double), cudaMemcpyDeviceToHost);
	}

	printf( "Min: %f\n", min_array[0] );

	free( min_array );
	cudaFree( dev_array );
	cudaFree( dev_array2 );
	cudaFree( dev_min_array );
}


__global__ void kernel_avg(double * array, double * max, long int num_elem, int final_step)
{

	
	extern __shared__ double sdata[];
	unsigned long int tid = threadIdx.x;
	unsigned long int idx = (blockIdx.x * blockDim.x) + threadIdx.x;

	
	sdata[tid] = array[idx];
	__syncthreads();

	unsigned long int i;
	for ( i = 1; i < blockDim.x; i*=2)
	{
		if ((tid % (2*i) == 0) && (idx + i < num_elem)) 
		{
			sdata[tid] += sdata[tid + i];
		}
		__syncthreads();
	}
	__syncthreads();

	if ( tid == 0 )
	{
		max[blockIdx.x] = sdata[tid];
		if (final_step == 1) 
		{
			max[blockIdx.x] /= (double)num_elem;
		}
	}
}


void avg_gpu(double *array, long int size, int tpb)
{

	long int nblocks = (long int)ceil((double)size / (double)tpb);
	//printf("N blocks: %ld\n", nblocks);

	double *dev_array, *dev_array2;
	double *dev_avg_array;
	long int arr_size = size * sizeof(double);

	double *avg_array = (double *) malloc(size * sizeof(double));

	//printf("cudaMalloc'ing\n");
	cudaMalloc( (void**)&dev_array, arr_size);
	cudaMalloc( (void**)&dev_array2, arr_size);
	cudaMalloc( (void**)&dev_avg_array, nblocks * sizeof(double));

	//printf("cudaMemcpy to device\n");
	cudaMemcpy(dev_array, array, arr_size, cudaMemcpyHostToDevice);
	cudaMemcpy(dev_avg_array, avg_array, nblocks * sizeof(double), cudaMemcpyHostToDevice);	

	clock_t start, end;
	start = clock();

	int count = 0;
	long int num_elem = size;
	while (nblocks >= 1) {
		//printf("Calling kernel_avg\n");
		//printf("nblocks: %ld\n", nblocks);
		if (count % 2 == 0) {
			kernel_avg<<<nblocks, tpb, tpb * sizeof(double)>>>(dev_array, dev_array2, num_elem, nblocks);
		}
		else
		{
			kernel_avg<<<nblocks, tpb, tpb * sizeof(double)>>>(dev_array2, dev_array, num_elem, nblocks);
		}
		cudaThreadSynchronize();
		if (nblocks == 1) { break; }
		count++;
		size = nblocks;
		nblocks = (long int)ceil((double)size / (double)tpb);
	}
	end = clock();
	printf("Time for Avg: %f\n", (((double)end - (double)start)) / CLOCKS_PER_SEC);

	if (count % 2 == 0) {	
		cudaMemcpy(avg_array, dev_array2, nblocks * sizeof(double), cudaMemcpyDeviceToHost);
	}
	else
	{
		cudaMemcpy(avg_array, dev_array, nblocks * sizeof(double), cudaMemcpyDeviceToHost);
	}

	printf( "Avg: %f\n", avg_array[0] );

	free( avg_array );
	cudaFree( dev_array );
	cudaFree( dev_array2 );
	cudaFree( dev_avg_array );
}

__global__ void kernel_std(double * array, double * max, long int num_elem, double avg, int first_step, int final_step)
{

	
	extern __shared__ double sdata[];
	unsigned long int tid = threadIdx.x;
	unsigned long int idx = (blockIdx.x * blockDim.x) + threadIdx.x;

	if (first_step == 0) {
		sdata[tid] = (array[idx] - avg) * (array[idx] - avg);
	}
	else
	{
		sdata[tid] = array[idx];
	}
	__syncthreads();

	unsigned long int i;
	for ( i = 1; i < blockDim.x; i*=2)
	{
		if ((tid % (2*i) == 0) && (idx + i < num_elem)) 
		{
			sdata[tid] += sdata[tid + i];
		}
		__syncthreads();
	}
	__syncthreads();

	if ( tid == 0 )
	{
		max[blockIdx.x] = sdata[tid];
		if (final_step == 1)
		{
			max[blockIdx.x] /= num_elem;
			max[blockIdx.x] = sqrt(max[blockIdx.x]);
		}
	}
}


void std_gpu(double *array, long int size, int tpb)
{

	long int nblocks = (long int)ceil((double)size / (double)tpb);
	//printf("N blocks: %ld\n", nblocks);

	double *dev_array, *dev_array2;
	double *dev_avg_array;
	long int arr_size = size * sizeof(double);

	double *avg_array = (double *) malloc(size * sizeof(double));

	//printf("cudaMalloc'ing\n");
	cudaMalloc( (void**)&dev_array, arr_size);
	cudaMalloc( (void**)&dev_array2, arr_size);
	cudaMalloc( (void**)&dev_avg_array, nblocks * sizeof(double));

	//printf("cudaMemcpy to device\n");
	cudaMemcpy(dev_array, array, arr_size, cudaMemcpyHostToDevice);

	clock_t avg_start, avg_end, std_start, std_end;
	avg_start = clock();

	int count = 0;
	long int num_elem = size;
	while (nblocks >= 1) {
		//printf("Calling kernel_avg\n");
		//printf("nblocks: %ld\n", nblocks);
		if (count % 2 == 0) {
			kernel_avg<<<nblocks, tpb, tpb * sizeof(double)>>>(dev_array, dev_array2, num_elem, nblocks);
		}
		else
		{
			kernel_avg<<<nblocks, tpb, tpb * sizeof(double)>>>(dev_array2, dev_array, num_elem, nblocks);
		}
		cudaThreadSynchronize();
		if (nblocks == 1) { break; }
		count++;
		size = nblocks;
		nblocks = (long int)ceil((double)size / (double)tpb);
	}
	avg_end = clock();


	if (count % 2 == 0) {	
		cudaMemcpy(avg_array, dev_array2, nblocks * sizeof(double), cudaMemcpyDeviceToHost);
	}
	else
	{
		cudaMemcpy(avg_array, dev_array, nblocks * sizeof(double), cudaMemcpyDeviceToHost);
	}

	double avg = avg_array[0];
	free( avg_array );
	cudaFree( dev_avg_array );
	
	double *std_array = (double *) malloc(nblocks * sizeof(double));
	double *dev_std_array;
	cudaMalloc((void**)&dev_std_array, nblocks * sizeof(double));

	cudaMemcpy(dev_array, array, arr_size, cudaMemcpyHostToDevice);

	std_start = clock();

	size = num_elem;
	nblocks = (long int)ceil((double)num_elem / (double)tpb);
	count = 0;
	while (nblocks >= 1) {
		//printf("Calling kernel_std\n");
		//printf("nblocks: %ld\n", nblocks);
		if (count % 2 == 0) {
			kernel_std<<<nblocks, tpb, tpb * sizeof(double)>>>(dev_array, dev_array2, num_elem, avg, count, nblocks);
		}
		else
		{
			kernel_std<<<nblocks, tpb, tpb * sizeof(double)>>>(dev_array2, dev_array, num_elem, avg, count, nblocks);
		}
		cudaThreadSynchronize();
		if (nblocks == 1) { break; }
		count++;
		size = nblocks;
		nblocks = (long int)ceil((double)size / (double)tpb);
	}
	std_end = clock();
	printf("Time for Std: %f\n", (((double)avg_end - (double)avg_start) + ((double)std_end - (double)std_start)) / CLOCKS_PER_SEC);


	if (count % 2 == 0) {	
		cudaMemcpy(std_array, dev_array2, nblocks * sizeof(double), cudaMemcpyDeviceToHost);
	}
	else
	{
		cudaMemcpy(std_array, dev_array, nblocks * sizeof(double), cudaMemcpyDeviceToHost);
	}

	printf( "Std: %f\n", std_array[0] );

	free( std_array );
	cudaFree( dev_array );
	cudaFree( dev_array2 );
	cudaFree( dev_std_array );
}

