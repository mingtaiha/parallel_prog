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


__global__ void kernel_max(double * array, double * max, int num_elem)
{

	extern __shared__ double sdata[];
	int tid = threadIdx.x;
	int idx = blockIdx.x - 1* blockDim.x + threadIdx.x;

	//sdata[tid] = 5.0;
	sdata[tid] = array[idx];
	int i = (unsigned int)ceil((float)blockDim.x/2);

	__syncthreads();

	/*
	int i;
	for ( i = 1; i < blockDim.x; i*=2)
	{
		if ((tid % (2*i) == 0) && (idx + i < num_elem)) {
			sdata[tid] = (sdata[tid] > sdata[tid + i]) ? sdata[tid] : sdata[tid + i];
		}
	}
	*/

		
	while( i!=0 )
	{
		if ( tid+i < num_elem && idx < i )
		{
			sdata[idx] = (sdata[idx] > sdata[idx+i]) ? sdata[idx] : sdata[idx+i];
		}
		i /= 2;
	}
	
	
	__syncthreads();

	
	if ( tid == 0 )
	{
		max[blockIdx.x] = sdata[0];
	}
	
	
}

void max_gpu(double *array, int size, int tpb)
{

	int nblocks = (int)ceil((double)size / (double)tpb);

	double *dev_array;
	double *dev_max_array;
	int arr_size = size * sizeof(double);

	//double *arr2 = (double *) malloc(size * sizeof(double));
	double *max_array = (double *) malloc(nblocks * sizeof(double));
	//double *output_array;
	//max_array[0] = 11.11;
	printf("%f\n", max_array[0]);


	printf("cudaMalloc'ing\n");
	cudaMalloc( (void**)&dev_array, arr_size);
	cudaMalloc( (void**)&dev_max_array, 1 * sizeof(double));

	printf("%f\n", array[0]);
	printf("cudaMemcpy to device\n");
	cudaMemcpy(dev_array, array, arr_size, cudaMemcpyHostToDevice);
	//cudaMemcpy(arr2, dev_array, arr_size, cudaMemcpyDeviceToHost);
	//printf("%f\n", arr2[0]);
	cudaMemcpy(dev_max_array, max_array, nblocks * sizeof(double), cudaMemcpyHostToDevice);	

	printf("Calling kernel_max\n");
	
	dim3 dimGrid(16, 1);
	dim3 dimBlock(32, 1);
	kernel_max<<<dimGrid, dimBlock>>>(dev_array, dev_max_array, size);
	//cudaDeviceSynchronize();
	
	//printf("cudaMemcpy to host\n");
	
	cudaError_t code = cudaMemcpy(max_array, dev_max_array, 1 * sizeof(double), cudaMemcpyDeviceToHost);
	printf("%d\n", code);
	printf( "Max: %f\n", max_array[0] );

	free( max_array );
	cudaFree( dev_array );
	cudaFree( dev_max_array );

}
