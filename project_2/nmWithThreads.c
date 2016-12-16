#include <immintrin.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define ARRAY_SIZE 1875000


int main(int argc, char* argv[]) {

	int numCores = atoi(argv[1]);
	int numThreads = atoi(argv[2]);

	//printf("size %i\n", sizeof(__m256) * ARRAY_SIZE);

	//int numThreads = atoi(argv[1]);
	void* t; //= (float*)aligned_alloc(32, (sizeof(__m256)) * ARRAY_SIZE);
	void* g;// = (float*)aligned_alloc(32, (sizeof(__m256)) * ARRAY_SIZE);
	void* r;// = (float*)aligned_alloc(32, (sizeof(__m256)) * ARRAY_SIZE);

	posix_memalign(&t, 32, (sizeof(__m256)) * ARRAY_SIZE);
	posix_memalign(&g, 32, (sizeof(__m256)) * ARRAY_SIZE);
	posix_memalign(&r, 32, (sizeof(__m256)) * ARRAY_SIZE);

	__m256* target = (__m256*)t;
	__m256* guess = (__m256*)g;
	__m256* results = (__m256*)r;

	//float* f[ARRAY_SIZE];

	srand(time(NULL));
	float a = 5.0;
	int i = 0;
	int j = 0;
	for(;i < ARRAY_SIZE; i++){
		target[i] = _mm256_set_ps(((float)rand()/(float)(RAND_MAX)) * a,((float)rand()/(float)(RAND_MAX)) * a,
			((float)rand()/(float)(RAND_MAX)) * a,((float)rand()/(float)(RAND_MAX)) * a,((float)rand()/(float)(RAND_MAX)) * a,
			((float)rand()/(float)(RAND_MAX)) * a,((float)rand()/(float)(RAND_MAX)) * a,((float)rand()/(float)(RAND_MAX)) * a);
		guess[i] = _mm256_set_ps(1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0);
	
	}

	//Actual Function
	clock_t begin = clock();
	nispcavx(ARRAY_SIZE,numThreads, numCores, guess, target, result)
	clock_t end = clock();
	float timeTaken = (float)((end-begin)/(float)CLOCKS_PER_SEC);

	//PRINTS THE FUCKS

	// for(i = 0; i < ARRAY_SIZE; ++i){
	// 	float* piece = (float*)&results[i];
	// 	for(j = 0; j < 8; ++j) {
	// 		printf("%f, ", piece[j]);
	// 	}
	// 	printf("\n");
	// }
	

	printf("\nTime Taken = %f\n", timeTaken);

	free(target);
	free(guess);
	free(results);
	//free(f);

	
	return 0;
}