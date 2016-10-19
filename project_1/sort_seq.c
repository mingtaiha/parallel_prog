#include <time.h>
#include "array_gen.h"



int * array;


////////////////////////////////////////////////////////////////////////////

// Quicksort


// The partitioning helping function. The function assumes that the array
// indicies lo < hi. First, assign a "pivot" element as the right most
// element of the array (or subarray). Fix a variable i which will be
// incremented, starting at lo. Going from left to right, identify if 
// any element is less that or equal to the pivot. If so, switch that
// element with a[i] and increment i to let the subarray on the left
// grow. This will push elements less than the pivot to the left. After
// doing this for every element in the except for the pivot, switch the
// pivot with the element arr[i]

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


// The quicksort function. lo and hi are indices of the array. When lo < hi
// identify partition the subarray (arr[lo] to arr[hi]) based on a pivot and
// and recursively quicksort the left and right subarray, split based on the
// pivot element

void q_sort(int * arr, int lo, int hi) {
    
    if (lo < hi) {
        int pivot = partition(arr, lo, hi);
        q_sort(arr, lo, pivot-1);
        q_sort(arr, pivot+1, hi);
    }
}


// A mask function to separate the invocation of quicksort from the underlying
// functions

void quicksort(int * arr, int size) {
    q_sort(arr, 0, size-1);
}


////////////////////////////////////////////////////////////////////////////

// Bitonic Sort


// This function decides how the swapping should occur. is_up denotes whether
// to swap elements in ascending (is_up == 1) or descending (is_up == 0) order.
// arr[i] > arr[j] is a boolean function is 1 when the elements is in descending
// order, and 0 when the elements in descending order, and assumes i < j. When 
// the elements should be in ascending order (is_up = 1) and the elements are 
// in descending order (arr[i] > arr[j]), then the elements should be swapped
// so that arr[i] <= arr[j]. The similar occurs for when is_up = 0 and 
// arr[i] < arr[j]

void dir_swap(int * arr, int i, int j, int is_up) {

    if (is_up == (arr[i] > arr[j])) {
        int tmp = arr[i];
        arr[i] = arr[j];
        arr[j] = tmp;
    }
}


// The b_merge function recursively sorts the bitonic sequence to follow one
// order, ascending order when is_up = 1 and descending order when is_up = 0.
// The sequence to be sorted starts at the index lo, and sorts 'count' number
// of elements.

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

// The bitonic sort function. The function produces a bitonic sequence,
// sorting the left subarray in ascending order and the right subarray
// in descending order. Then, it calls b_merge to merge the two subarrays
// to follow the same order

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


// A mask function to separate the invocation of bitonic_sort from the 
// underlying functions

int bitonic_sort(int * arr, int size) {
    b_sort(arr, 0, size, 1);
}
    

////////////////////////////////////////////////////////////////////////////

// Main Function

int main(int argc, char** argv) {

    int size = atoi(argv[1]);           // Gets the size
    char * filename = argv[2];          // Gets the filename
    int which_sort = atoi(argv[3]);     // 1 for bitonic sort, 0 for quicksort
    array = read_arr(size, filename);   // Reads array from file
    

    
    clock_t start_time, end_time;       // Instantiate timing variables
    start_time = clock();               // Gets start time
    
    if (which_sort == 0) {              // Quicksort chosen
        printf("Quicksort chosen\n");
        quicksort(array, size);         // Perform Quicksort
    } else if (which_sort == 1) {       // Bitonic Sort chosen
        printf("Bitonic Sort chosen\n");
        bitonic_sort(array, size);      // Perform Bitonic Sort
    } else {
        printf("No sorting algorithm of this type implemented\n");
    }
    
    end_time = clock();                 // Get end time
    
    // Calculating duration of sorting algorithm, with overhead of choosing
    // sorting algorithm
    double duration = (((double) end_time) - ((double) start_time)) / CLOCKS_PER_SEC;
    printf("Sorting time (in sec): %f\n", duration);

    return 0;

}
