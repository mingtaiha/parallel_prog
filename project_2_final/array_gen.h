#ifndef _ARRAY_GEN_H
#define _ARRAY_GEN_H

#include <time.h>
#include <stdlib.h>
#include <stdio.h>

#define TEST 0


void print_array(float * array) {
	
	int i;
	for (i = 0; i < 25; i++) {
		printf("%1.5f\n", array[i]);
	}
	printf("\n");
}

void write_array(float * array, char * filename, int SIZE) {

	FILE *f = fopen(filename, "wb");
	printf("Writing Array\n");
	fwrite(array, sizeof(float), SIZE, f);
	fclose(f);
}

float * read_array(char * filename, int SIZE) {

	float * array = (float *) malloc(SIZE * sizeof(float));
	FILE *f = fopen(filename, "rb");
	if (f == NULL) {
		printf("Error reading File\n");
		exit(0);
	}
	printf("Reading Array\n");
	int i;
	for (i = 0; i < SIZE; i++) {
		fread(array, sizeof(float), SIZE, f);
	}
	return array;
}

#endif
