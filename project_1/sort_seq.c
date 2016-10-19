#include <time.h>
#include "array_gen.h"


#define SIZE 25


int * array;


////////////////////////////////////////////////////////////////////////////

// Quicksort

int partition(int * arr, int lo, int hi) {

    int pivot = arr[hi];
    
    int i = lo;
    int j, tmp;
    for (j = lo; j < hi; j++) {
        if (arr[j] <= pivot) {
            tmp = arr[i];
            arr[i] = arr[j];
            arr[j] = tmp;
            i++;
        }
    }
    tmp = arr[i];
    arr[hi] = arr[i];
    arr[i] = arr[hi];
    return i;
}

void q_sort(int * arr, int lo, int hi) {
    
    if (lo < hi) {
        int pivot = partition(arr, lo, hi);
        q_sort(arr, lo, pivot-1);
        q_sort(arr, pivot+1, hi);
    }
}


void quicksort(int * arr, int size) {
    q_sort(arr, 0, size-1);
}


////////////////////////////////////////////////////////////////////////////

// Bitonic Sort

void dir_swap(int * arr, int i, int j, int is_up) {

    if (is_up == (arr[i] > arr[j])) {
        int tmp = arr[i];
        arr[i] = arr[j];
        arr[j] = tmp;
    }
}


void b_merge(int * arr, int lo, int count, int is_up) {

    if (count > 1) {
        int k = count / 2;

        int i;
        for (i = lo; i < lo+k; i++) {
            dir_swap(arr, i, i + k, is_up);
        }
        b_merge(arr, lo, k, is_up);
        b_merge(arr, lo + k, k, is_up);
    }
}


void b_sort(int * arr, int lo, int count, int is_up) {

    if (count > 1) {
        int k = count / 2;
        
        // sort in ascending order since is_up is 1
        b_sort(arr, lo, k, 1);
        
        // sort in descending ordering since is_up is 0
        b_sort(arr, lo + k, k, 0);

        // Merge the whole sequence in ascending order since is_up is 1
        b_merge(arr, lo, count, is_up);
    }
}


int bitonic_sort(int * arr, int size) {
    b_sort(arr, 0, size, 1);
}
    

////////////////////////////////////////////////////////////////////////////

// Main Function

int main(int argc, char** argv) {

    int size = atoi(argv[1]);
    char * filename = argv[2];
    int which_sort = atoi(argv[3]);
    array = read_arr(size, filename);
    


    clock_t start_time, end_time;
    start_time = clock();
    
    if (which_sort == 0) {
        printf("Quicksort chosen\n");
        quicksort(array, size);
    } else if (which_sort == 1) {
        printf("Bitonic Sort chosen\n");
//        print_arr(array, size);
        bitonic_sort(array, size);
//        print_arr(array, size);
    } else {
        printf("No sorting algorithm of this type implemented\n");
    }
    
    end_time = clock();
    double duration = (((double) end_time) - ((double) start_time)) / CLOCKS_PER_SEC;
    printf("Sorting time (in sec): %f\n", duration);

}
