#include <immintrin.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define ARRAY_SIZE 20000


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

int main() {
	__m256 target[ARRAY_SIZE];
	malloc(sizeof(target));
	__m256 guess[ARRAY_SIZE];
	malloc(sizeof(guess));
	__m256 results[ARRAY_SIZE];
	malloc(sizeof(results));
	float* f[ARRAY_SIZE];
	malloc(sizeof(results));

	srand(time(NULL));
	float a = 5;
	int i = 0;
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

	for(i = 0; i < ARRAY_SIZE; i++){
		f[i] = (float*)&results[i];
	}
	
	for (i = 0; i < ARRAY_SIZE; i++){
		printf("%f, %f, %f, %f, %f, %f, %f, %f \n ",f[i][0],f[i][1],f[i][2],f[i][3],f[i][4],f[i][5],f[i][6],f[i][7]);
	}
	printf("\nTime Taken = %f\n", timeTaken);
	
	return 0;
}