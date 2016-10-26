#include <time.h>
#include <pthread.h>
#include "array_gen.h"



int * array;


////////////////////////////////////////////////////////////////////////////

// Quicksort

typedef struct q_struct{
    int * arr;
    int lo;
    int hi;
    int layers;
} Q_STRUCT;

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
    arr[i] = arr[hi];
    arr[hi] = tmp;
    return i;
}


// The quicksort function. lo and hi are indices of the array. When lo < hi
// identify partition the subarray (arr[lo] to arr[hi]) based on a pivot and
// and recursively quicksort the left and right subarray, split based on the
// pivot element

void * q_sort(void * q_args) {
    
    Q_STRUCT * input = (Q_STRUCT *) q_args;
    int * arr = input->arr;
    int lo = input->lo;
    int hi = input->hi;
    int layers = input->layers;

    if (lo < hi) {
        
        int pivot = partition(arr, lo, hi);

        Q_STRUCT left_input, right_input;
        left_input.arr = arr;
        left_input.lo = lo;
        left_input.hi = pivot-1;
        right_input.arr = arr;
        right_input.lo = pivot+1;
        right_input.hi = hi;

        printf("%d\t", layers);
        if (layers == 0) { 
            left_input.layers = 0;
            right_input.layers = 0;
            q_sort(&left_input);
            q_sort(&right_input);
        
        } else {

            left_input.layers = layers - 1;
            right_input.layers = layers - 1;
            pthread_t tid_l, tid_r;
            int ret;

            ret = pthread_create(&tid_l, NULL, q_sort, &left_input);
            if (ret) {
                printf("%d %s - unable to create thread - ret - %d\n", __LINE__, __FUNCTION__, ret);
                exit(1);
            }
        
            ret = pthread_create(&tid_r, NULL, q_sort, &right_input);
            if (ret) {
                printf("%d %s - unable to create thread - ret - %d\n", __LINE__, __FUNCTION__, ret);
                exit(1);
            }

            pthread_join(tid_l, NULL);
            pthread_join(tid_r, NULL);
        }
        //pthread_exit(NULL);
    }
}


// A mask function to separate the invocation of quicksort from the underlying
// functions

void quicksort(int * arr, int size, int layers) {
    
    Q_STRUCT input;
    input.arr = arr;
    input.lo = 0;
    input.hi = size-1;
    input.layers = layers;

    q_sort(&input);
}


////////////////////////////////////////////////////////////////////////////

// Bitonic Sort

typedef struct {
    int * arr;
    int lo;
    int count;
    int is_up;
} B_STRUCT;

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

void * b_merge(void * b_args) {

    B_STRUCT * input = (B_STRUCT *) b_args;
    int * arr = input->arr;
    int lo = input->lo;
    int count = input->count;
    int is_up = input->is_up;
    
    if (count > 1) {
        int k = count / 2;

        int i;
        for (i = lo; i < lo+k; i++) {
            dir_swap(arr, i, i + k, is_up);
        }

        B_STRUCT merge_input1, merge_input2;

        merge_input1.arr = arr;
        merge_input1.lo = lo;
        merge_input1.count = k;
        merge_input1.is_up = is_up;
        
        merge_input2.arr = arr;
        merge_input2.lo = lo + k;
        merge_input2.count = k;
        merge_input2.is_up = is_up;
        
        pthread_t thr_merge1, thr_merge2;
        int ret;

        ret = pthread_create(&thr_merge1, NULL, b_merge, &merge_input1);
        if (ret) {
            printf("%d %s - unable to create thread - ret - %d\n", __LINE__, __FUNCTION__, ret);
            exit(1);
        }

        ret = pthread_create(&thr_merge2, NULL, b_merge, &merge_input2);
        if (ret) {
            printf("%d %s - unable to create thread - ret - %d\n", __LINE__, __FUNCTION__, ret);
            exit(1);
        }

        pthread_join(thr_merge1, NULL);
        pthread_join(thr_merge2, NULL);

    }
}

// The bitonic sort function. The function produces a bitonic sequence,
// sorting the left subarray in ascending order and the right subarray
// in descending order. Then, it calls b_merge to merge the two subarrays
// to follow the same order

void * b_sort(void * b_args) {
 
    B_STRUCT * input = (B_STRUCT *) b_args;
    int * arr = input->arr;
    int lo = input->lo;
    int count = input->count;
    int is_up = input->is_up;
 
    if (count > 1) {
        int k = count / 2;
        
        B_STRUCT up_input, down_input;
        up_input.arr = arr;
        up_input.lo = lo;
        up_input.count = k;
        up_input.is_up = 1;
        down_input.arr = arr;
        down_input.lo = lo + k;
        down_input.count = k;
        down_input.is_up = 0;
        
        pthread_t thr_up, thr_down;
        int ret;

        // sort in ascending order since is_up is 1
        ret = pthread_create(&thr_up, NULL, b_sort, &up_input);
        if (ret) {
            printf("%d %s - unable to create thread - ret - %d\n", __LINE__, __FUNCTION__, ret);
            exit(1);
        }
        
        // sort in descending ordering since is_up is 0
        ret = pthread_create(&thr_down, NULL, b_sort, &down_input);
        if (ret) {
            printf("%d %s - unable to create thread - ret - %d\n", __LINE__, __FUNCTION__, ret);
            exit(1);
        }

        pthread_join(thr_up, NULL);
        pthread_join(thr_down, NULL);
        
        // Merge the whole sequence in ascending order since is_up is 1
        B_STRUCT merge_input;
        merge_input.arr = arr;
        merge_input.lo = lo;
        merge_input.count = count;
        merge_input.is_up = is_up;

        b_merge(&merge_input);
    }
}


// A mask function to separate the invocation of bitonic_sort from the 
// underlying functions

int bitonic_sort(int * arr, int size) {

    B_STRUCT input;
    input.arr = arr;
    input.lo = 0;
    input.count = size;
    input.is_up = 1;

    b_sort(&input);
}
    

////////////////////////////////////////////////////////////////////////////

// Main Function

int main(int argc, char** argv) {

    int size = atoi(argv[1]);           // Gets the size
    char * filename = argv[2];          // Gets the filename
    int which_sort = atoi(argv[3]);     // 1 for bitonic sort, 0 for quicksort
    int layers = atoi(argv[4]);          // Number of layers to go down

    printf("%d\n", layers);
    array = read_arr(size, filename);   // Reads array from file

    
    clock_t start_time, end_time;       // Instantiate timing variables
    start_time = clock();               // Gets start time
    
    if (which_sort == 0) {              // Quicksort chosen
        printf("Quicksort chosen\n");
        //print_arr(array, size);
        quicksort(array, size, layers);         // Perform Quicksort
        //print_arr(array, size);
        is_arr_sorted(array, size);
    } else if (which_sort == 1) {       // Bitonic Sort chosen
        printf("Bitonic Sort chosen\n");
        //print_arr(array, size);
        bitonic_sort(array, size);      // Perform Bitonic Sort
        //print_arr(array, size);
        is_arr_sorted(array, size);
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
