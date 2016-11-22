#include <immintrin.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define ARRAY_SIZE 1875000 //number of 8 element arrays

//compile using -mavx

__m256 nmParallel(__m256 guess, __m256 target) {

	__m256 twos = _mm256_set_ps(2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0);
	__m256 tol = _mm256_set_ps(0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.0001);

	__m256 func = _mm256_sub_ps(_mm256_mul_ps(guess, guess), target);
	__m256 funcPrime = _mm256_mul_ps(twos, guess);

	__m256 nextGuess = _mm256_sub_ps(guess, _mm256_div_ps(func, funcPrime));
	__m256 tolCheck = _mm256_sub_ps(_mm256_mul_ps(nextGuess, nextGuess), target);

	__m256 tolMask = _mm256_cmp_ps(tolCheck, tol, _CMP_LT_OS);

	__m256 returnBuffer = _mm256_set_ps(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
	int endCheck = 1;


	int i = 0;
	for (; i < 8; i++) {
		if (tolMask[i]) {
			returnBuffer[i] = nextGuess[i];
		} else {
			endCheck = 0;
		}
	}

	if (endCheck) {
		return returnBuffer;
	} else {
		nmParallel(nextGuess, target);
	}
}



int main(int argc, char* argv[]) {
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
	for (i = 0; i < ARRAY_SIZE; i++){
		results[i] = nmParallel(guess[i],target[i]);
	}
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