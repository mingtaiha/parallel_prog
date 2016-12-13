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

	/*
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
	*/

	
	long int idx = (blockIdx.x * blockDim.x) + threadIdx.x;

	max[idx] = array[idx];

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
	
}

void max_gpu(double *array, long int size, int tpb)
{

	long int nblocks = (long int)ceil((double)size / (double)tpb);
	printf("N blocks: %ld\n", nblocks);

	double *dev_array, *dev_array2;
	double *dev_max_array;
	double *dev_final_max_array;
	long int arr_size = size * sizeof(double);

	double *max_array = (double *) malloc(nblocks * sizeof(double));
	//double *output_array;
	//max_array[0] = 11.11;
	printf("%f\n", max_array[0]);


	printf("cudaMalloc'ing\n");
	cudaMalloc( (void**)&dev_array, arr_size);
	cudaMalloc( (void**)&dev_array2, arr_size);
	cudaMalloc( (void**)&dev_max_array, nblocks * sizeof(double));
	cudaMalloc( (void**)&dev_final_max_array, nblocks * sizeof(double));

	//printf("%f\n", array[0]);
	printf("cudaMemcpy to device\n");
	cudaMemcpy(dev_array, array, arr_size, cudaMemcpyHostToDevice);
	//cudaMemcpy(arr2, dev_array, arr_size, cudaMemcpyDeviceToHost);
	//printf("%f\n", arr2[0]);
	cudaMemcpy(dev_max_array, max_array, nblocks * sizeof(double), cudaMemcpyHostToDevice);	

	//printf("Calling kernel_max\n");
	
	int count = 0;
	//printf("Calling kernel_max\n");
	while (nblocks/tpb >= 1) {
		printf("Calling kernel_max\n");
		if (count % 2 == 0) {
			kernel_max<<<nblocks, tpb, tpb * sizeof(double)>>>(dev_array, dev_array2, size);
		}
		else
		{
			kernel_max<<<nblocks, tpb, tpb * sizeof(double)>>>(dev_array2, dev_array, size);
		}
	//kernel_max<<<dimGrid, tpb, tpb * sizeof(double)>>>(dev_array, dev_max_array, size);
		cudaThreadSynchronize();
		count++;
		size = nblocks;
		nblocks = (long int)ceil((double)size / double(tpb));
	}
	//cudaError_t code = cudaMemcpy(max_array, dev_max_array, nblocks * sizeof(double), cudaMemcpyDeviceToHost);
	//cudaError_t code = cudaMemcpy(array, dev_array, nblocks * sizeof(double), cudaMemcpyDeviceToHost);
	//int i = 0;
	//for(; i < nblocks; i++) { printf("%f\n", max_array[i]); }
	
	//printf("Calling reduced kernel_max\n");
	//printf("Calling reduced kernel_max\n");
	//kernel_max<<<1, dimGrid, tpb * sizeof(double)>>>(dev_max_array, dev_final_max_array, nblocks);
	//cudaThreadSynchronize();
	
	cudaError_t code;
	if (count % 2 == 0) {	
		code = cudaMemcpy(max_array, dev_array, nblocks * sizeof(double), cudaMemcpyDeviceToHost);
	}
	else
	{
		code = cudaMemcpy(max_array, dev_array2, nblocks * sizeof(double), cudaMemcpyDeviceToHost);
	}
	//i = 0;	
	//for(; i < nblocks; i++) { printf("%f\n", max_array[i]); }
	//printf("cudaMemcpy to host\n");
	
	//cudaError_t code = cudaMemcpy(max_array, dev_max_array, nblocks * sizeof(double), cudaMemcpyDeviceToHost);
	printf("Code: %d\n", code);
	printf( "Max: %f\n", max_array[0] );

	//i = 0;
	//for(; i < nblocks; i++) { printf("%f\n", max_array[i]); }
	free( max_array );
	cudaFree( dev_array );
	cudaFree( dev_max_array );

}
