#ifndef _ARRAY_GEN_H
#define _ARRAY_GEN_H

#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define SIZE 15000000

#define TEST 0

float * make_array() {
	
	float * array = (float *) malloc(SIZE * sizeof(float));
	srand(time(NULL));
	
	int i;
	for (i = 0; i < SIZE; i++) {
		array[i] = (float)rand() / (float)RAND_MAX * 5;
	}
	return array;
}

float * sqrt_array(float * array) {

	float * sqrt_array  = (float *) malloc(SIZE * sizeof(float));
	
	int i;
	for (i = 0; i < SIZE; i++) {
		sqrt_array[i] = sqrt(array[i]);
	}
	return sqrt_array;
}

void print_array(float * array) {
	
	int i;
	for (i = 0; i < 25; i++) {
		printf("%1.5f\n", array[i]);
	}
	printf("\n");
}

void write_array(float * array, char * filename) {

	FILE *f = fopen(filename, "wb");
	printf("Writing Array\n");
	fwrite(array, sizeof(float), SIZE, f);
	fclose(f);
}

float * read_array(char * filename) {

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

#if TEST

int main() {

	char arr_name[] = "arr_15m.dat";
	char sqrt_arr_name[] = "sqrt_arr_15m.dat";
	float * arr = make_array();
	float * sqrt_arr = sqrt_array(arr);

	write_array(arr, arr_name);
	write_array(sqrt_arr, sqrt_arr_name);
	float * arr2 = read_array(arr_name);
	float * sqrt_arr2 = read_array(sqrt_arr_name);
	print_array(arr2);
	print_array(sqrt_arr2);
	return 0;
}

#endif
