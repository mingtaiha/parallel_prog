#include <time.h>
#include <stdlib.h>
#include <stdio.h>

#define TEST 1

int * make_arr(int size) {

    int i;
    int * arr = (int *) malloc(sizeof(int) * size);
    srand(time(NULL));    
    
    for(i = 0; i < size; i++) {
        arr[i] = rand() % (size * 25);
    }
    return arr;
}

void print_arr(int * arr, int size) {
    
    int i;
    for(i = 0; i < size; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");
}


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

void write_arr(int * arr, int size, char * filename) {

    FILE * f = fopen(filename, "wb");
    fwrite(arr, sizeof(int), size, f);
    fclose(f);
}


#if TEST

int main(int argc, char **argv) {

    int size = atoi(argv[1]);
    int * array = make_arr(size);
    print_arr(array, size);
    write_arr(array, size, "arr_test.dat");

    int * array2 = read_arr(size, "arr_test.dat");
    print_arr(array2, size);
 
    return 0;
}

#endif
