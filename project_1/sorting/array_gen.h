#ifndef _ARRAY_GEN_H_
#define _ARRAY_GEN_H_

#include <time.h>
#include <stdlib.h>
#include <stdio.h>

#define TEST 0

// Make an array populated with random values
int * make_arr(int size) {

    int i;
    int * arr = (int *) malloc(sizeof(int) * size);
    srand(time(NULL));    
    
    for(i = 0; i < size; i++) {
        arr[i] = rand() % (size * 25);
    }
    return arr;
}

// Print the array
void print_arr(int * arr, int size) {
    
    int i;
    for(i = 0; i < size; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");
}

// Read the array from a file
int * read_arr(int size, char * filename) {

    int * arr = (int *) malloc(sizeof(int) * size);
    FILE * f = fopen(filename, "rb");
    if (f == NULL) {
        printf("Error Reading File\n");
        exit(0);
    }
    int i;
    for (i = 0; i < size; i++) {
        fread(arr, sizeof(int), size, f);
    }
    return arr;
    
}

// Write the array to a file
void write_arr(int * arr, int size, char * filename) {

    FILE * f = fopen(filename, "wb");
    fwrite(arr, sizeof(int), size, f);
    fclose(f);
}

// Checks if an array is sorted
void is_arr_sorted(int * arr, int size) {

    int i;
    for (i = 1; i < size; i++) {
        if (arr[i] < arr[i-1]) {
            printf("Array is not sorted\n");
            return; // Exit if not sorted
        }
    }
    // Prints only when array is sorted
    printf("Array is sorted\n");
}

#endif
    
#if TEST

int main(int argc, char **argv) {

    int size = atoi(argv[1]);
    char * filename = argv[2];
    int * array = make_arr(size);
    print_arr(array, size);
    write_arr(array, size, filename);

    int * array2 = read_arr(size, filename);
    print_arr(array2, size);
 
    return 0;
}

#endif
