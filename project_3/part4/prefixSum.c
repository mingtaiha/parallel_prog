#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define ARRAY_SIZE 100

int main(){
	int i;
	srand(time(NULL));

	//allocate memory 
	int *input = (int*)malloc(sizeof(int) * ARRAY_SIZE);
	int *output = (int*)malloc(sizeof(int) * ARRAY_SIZE);
	int *findRepeat = (int*)malloc(sizeof(int) * ARRAY_SIZE);

	//create an array of random integers
	for(i = 0; i < ARRAY_SIZE; i++){
		input[i] = rand()%100;
	}

	// printf("Input Array = ");
	// for(i = 0; i < ARRAY_SIZE; i++){
	// 	printf("%d ", input[i]);
	// }

	//do find repeat and exclusive scan
	int j = 0;
	for(i = 1; i <= ARRAY_SIZE; i++){
		if(input[i-1] == input[i]){
			findRepeat[i] = 1;
			j++;
		} else {
			findRepeat[i] = 0;
		}
		output[i] = output[i-1] + input[i-1];
	}

	// printf("\nOutput Array = ");
	// for(i = 0; i < ARRAY_SIZE; i++){
	// 	printf("%d ", output[i]);
	// }


	//allocate memory for list b of size j
	int *listB = (int*)malloc(sizeof(int) * j);
	//allocate memory for list c of ARRAY_SIZE - number of repeats
	int *listC = (int*)malloc(sizeof(int) * (ARRAY_SIZE - j));

	// put all the repeating indexes in list b
	j = 0;
	int k = 0;
	for(i = 0; i < ARRAY_SIZE; i++){
		if(findRepeat[i]){
			listB[j] = i;
			j++;
		} else {
			listC[k] = input[i];
			k++;
		}
	}
	// printf("\nListB Array = ");
	// for(i = 0; i < j; i++){
	// 	printf("%d ", listB[i]);
	// }
	// printf("\nListC Array = ");
	// for(i = 0; i < k; i++){
	// 	printf("%d ", listC[i]);
	// }
	// printf("\n");

	return 0;
}