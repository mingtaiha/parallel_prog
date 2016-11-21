#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#define ARRAY_SIZE 160000

float nMethod(float guess, float target) {
	float func = guess*guess - target;
	float funcPrime = 2*guess;

	float nextGuess = guess - func/funcPrime;
	float tol = nextGuess*nextGuess - target;

	//base case
	if (tol < 0.0001) {
		return nextGuess;
	} else {
		nMethod(nextGuess, target);
	}
}

int main(int argc, char** argv) {
	
	float a[ARRAY_SIZE];
	srand(time(NULL));
	float g[ARRAY_SIZE];
	float result[ARRAY_SIZE];

	float max = 5;

	int i = 0;
	for(;i < ARRAY_SIZE; i++) {
		a[i] = ((float)rand()/(float)(RAND_MAX)) * max;
		g[i] = 1.0;
	}

	clock_t begin = clock();
	for(i = 0; i < ARRAY_SIZE; ++i) {
		result[i] = nMethod(g[i], a[i]);
	}
	clock_t end = clock();
	float timeTaken = (float)((end-begin)/(float)CLOCKS_PER_SEC);

	for(i = 0; i < ARRAY_SIZE; ++i) {
		printf("%f, ", result[i]);
		if (i % 10 == 0 && i != 0){
			printf("\n");
		}
	}

	printf("\n");

	printf("time taken: %f\n", timeTaken);

}