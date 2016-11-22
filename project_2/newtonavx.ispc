#include <immintrin.h>

__m256 nmParallel(uniform __m256 guess, uniform __m256 target) {

	uniform __m256 twos = _mm256_set_ps(2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0);
	uniform __m256 tol = _mm256_set_ps(0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.0001, 0.0001);

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

task void nmParallelTask(uniform float size, uniform float threads, uniform __m256* guess, uniform __m256* target, uniform __m256* result) {
	//size should be number of arrays
	uniform int span = size / (taskCount+1);
	uniform int start = taskIndex * span;
    uniform int end = (taskIndex+1) * span;

    //if num of threads are not evenly divisible by num of tasks
	if(taskIndex == taskCount-1){
		end = size;
	}

	nmParallelThreads(span, threads, guess, target, result);
}

void nmParallelThreads(uniform float size, unform float threads, uniform __m256* guess, uniform __m256* target, uniform __m256* result) {
	uniform int span = size / threads;

	foreach(i = 0 ... threads) {
		int start = i * span;
		int end = (i+1) * span;
		if (i == threads - 1) {
			end = size;
		}
		int j = start;
		for (; j < end; ++j) {
			result[j] = nmParallel(guess[j], target[j]);
		}
	}
}

task void nmParallelTaskOneThread(uniform float size, uniform __m256* guess, uniform __m256* target, uniform __m256* result) {
	//size should be number of arrays
	uniform int span = size / (taskCount+1);
	uniform int start = taskIndex * span;
    uniform int end = (taskIndex+1) * span;

    //if num of threads are not evenly divisible by num of tasks
	if(taskIndex == taskCount-1){
		end = size;
	}

	int i = start;
	for(; i < end; ++i) {
		result[i] = nmParallel(guess[i], target[i]);
	}
}

export void nispcavx(uniform float size, uniform float threads, uniform int cores, uniform __m256* guess, uniform __m256* target, uniform __m256* result) {
	if(cores == 1){
		if(threads < 0) {
			int i = 0;
			for(; i < size; ++i) {
				result[i] = nmParallel(guess[i], target[i]);
			}
		}
		else {
			nmParallelThreads(size, threads, guess, target, result);
		}	
	}
	else{
		if(threads < 0) {
			launch[cores] nmParallelTaskOneThread(size, guess, target, result);
		} else {
			launch[cores] nmParallelTask( size, threads, guess, target, result);
		}
	}
}
