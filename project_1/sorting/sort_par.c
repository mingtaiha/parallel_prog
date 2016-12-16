#include <time.h>
#include <pthread.h>
#include "array_gen.h"



int * array;


// NOTE: The algorithms only work on arrays with aith a length that is
// a power of 2


////////////////////////////////////////////////////////////////////////////

// Quicksort


// The argument struct that is passed around when calling quicksort
typedef struct q_struct{
    int * arr;      // The array
    int lo;         // The leftmost index of the subarray
    int hi;         // The rightmost index of the subarray
    int layers;     // The number of layers of the recursive function call
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
    
    // Making a local copy of the arguments
    Q_STRUCT * input = (Q_STRUCT *) q_args;
    int * arr = input->arr;
    int lo = input->lo;
    int hi = input->hi;
    int layers = input->layers;

    // If the subarray is not the empty list, partition array and recursively
    // call quicksort
    if (lo < hi) {
        
        // Partition the array
        int pivot = partition(arr, lo, hi);

        // Defining argument structs to call quicksort on left and right
        // subarray, split by the pivot element
        Q_STRUCT left_input, right_input;
        left_input.arr = arr;
        left_input.lo = lo;
        left_input.hi = pivot-1;
        right_input.arr = arr;
        right_input.lo = pivot+1;
        right_input.hi = hi;

        //printf("%d\t", layers);

        // If layers == 0, then do not create new threads, run sequentially
        if (layers == 0) { 
            left_input.layers = 0;
            right_input.layers = 0;
            q_sort(&left_input);
            q_sort(&right_input);
        
        } 
        // If layers > 0, then we can create more threads. The max number
        // of threads created is 2^(layers) - 1
        else {

            // Decrease the number of layers. Every time threads will be made
            // decrease the number of threads that will be created subsequently
            left_input.layers = layers - 1;
            right_input.layers = layers - 1;
            pthread_t tid_l, tid_r;
            int ret;

            // Create threads to run quicksort on subarrays
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

            // Wait for the quicksort of the two subarrays to finish before
            // exiting the function
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


// The argument struct that is passed around when calling quicksort
typedef struct {
    int * arr;          // The array
    int lo;             // The leftmost array
    int count;          // The number of elements to sort
    int is_up;          // The sorting direction. 1 Ascending, 0 Descending
    int layer;          // The number of layers of merge function can be called
    int max_layers;     // The total number of layer of threads that can be made
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

    // Making a local copy of the arguments
    B_STRUCT * input = (B_STRUCT *) b_args;
    int * arr = input->arr;
    int lo = input->lo;
    int count = input->count;
    int is_up = input->is_up;
    int layer = input->layer;
    int max_layers = input->max_layers;
    
    // Sort if there is more than one element
    if (count > 1) {
        int k = count / 2;

        // Swap elements to follow the indicated order (Ascending/Descendign)
        int i;
        for (i = lo; i < lo+k; i++) {
            dir_swap(arr, i, i + k, is_up);
        }

        // Defining argument structs for the two merging function calls
        B_STRUCT merge_input1, merge_input2;

        merge_input1.arr = arr;
        merge_input1.lo = lo;
        merge_input1.count = k;
        merge_input1.is_up = is_up;
        merge_input1.max_layers = max_layers;
        
        merge_input2.arr = arr;
        merge_input2.lo = lo + k;
        merge_input2.count = k;
        merge_input2.is_up = is_up;
        merge_input2.max_layers = max_layers;
        
        // If no more layers can be created (layers <= 0), sort sequentially
        if (layer <= 0) {
            merge_input1.layer = 0;
            merge_input2.layer = 0;
            b_merge(&merge_input1);
            b_merge(&merge_input2);
        } 
        // If layers > 0, create threads to merge in parallel. 2^(layers) - 1
        // will be created for merging
        else {
            
            // Decrease the number of layers. Every time threads will be made
            // decrease the number of threads that will be created subsequently
            merge_input1.layer = layer - 1;
            merge_input2.layer = layer - 1;
            pthread_t thr_merge1, thr_merge2;
            int ret;

            // Create threads to run bitonic merge in parallel
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

            // Wait for the bitonic merge threads before exiting
            pthread_join(thr_merge1, NULL);
            pthread_join(thr_merge2, NULL);
        }
    }
}

// The bitonic sort function. The function produces a bitonic sequence,
// sorting the left subarray in ascending order and the right subarray
// in descending order. Then, it calls b_merge to merge the two subarrays
// to follow the same order

void * b_sort(void * b_args) {
 
    // Making a local copy of the arguments
    B_STRUCT * input = (B_STRUCT *) b_args;
    int * arr = input->arr;
    int lo = input->lo;
    int count = input->count;
    int is_up = input->is_up;
    int layer = input->layer;
    int max_layers = input->max_layers;

    // Sort if there is more than one element
    if (count > 1) {
        int k = count / 2;

        // Defining argument structs for the two merging function calls
        B_STRUCT up_input, down_input;
        
        up_input.arr = arr;
        up_input.lo = lo;
        up_input.count = k;
        up_input.is_up = 1;
        up_input.max_layers = max_layers;
        
        down_input.arr = arr;
        down_input.lo = lo + k;
        down_input.count = k;
        down_input.is_up = 0;
        down_input.max_layers = max_layers;
        
        // If the number of thread layers are at least the number of
        // maximum number of thread layers specified to create, sort
        // sequentially
        if (layer >= max_layers) {
            up_input.layer = max_layers;
            down_input.layer = max_layers;
            b_sort(&up_input);
            b_sort(&down_input);
        }
        // If the number of thread layers are less than the nummber
        // of maximum number of thread layers specified to create,
        // create more threads
        else {
            
            // Increase the layer number to track the number of thread
            // layers created for running bitonic sort
            up_input.layer = layer + 1;
            down_input.layer = layer + 1;
            pthread_t thr_up, thr_down;
            int ret;

            // Sort in ascending order since is_up is 1
            ret = pthread_create(&thr_up, NULL, b_sort, &up_input);
            if (ret) {
                printf("%d %s - unable to create thread - ret - %d\n", __LINE__, __FUNCTION__, ret);
                exit(1);
            }
            
            // Sort in descending ordering since is_up is 0
            ret = pthread_create(&thr_down, NULL, b_sort, &down_input);
            if (ret) {
                printf("%d %s - unable to create thread - ret - %d\n", __LINE__, __FUNCTION__, ret);
                exit(1);
            }
            
            // Wait for bitonic sort threads to finish
            pthread_join(thr_up, NULL);
            pthread_join(thr_down, NULL);
        }

        // Merge the whole sequence in ascending order since is_up is 1
        B_STRUCT merge_input;
        merge_input.arr = arr;
        merge_input.lo = lo;
        merge_input.count = count;
        merge_input.is_up = is_up;
        merge_input.layer = max_layers - layer;
        merge_input.max_layers = max_layers;
        
        // NOTE: If there are 'layer' number of thread layers created
        // to run bitonic sort, then bitonic merge can create at most 
        // 'max_layers - layer' threads layers. This is because the
        // number of thread layers that can be created are split between
        // threads that run bitonic sort and those that run bitonic merge
        // 'layers' + 'max_layers - layer' = 'max_layers'
        b_merge(&merge_input);
    }
}


// A mask function to separate the invocation of bitonic_sort from the 
// underlying functions

int bitonic_sort(int * arr, int size, int layers) {

    B_STRUCT input;
    input.arr = arr;
    input.lo = 0;
    input.count = size;
    input.is_up = 1;
    input.layer = 0;
    input.max_layers = layers;

    b_sort(&input);
}
    

////////////////////////////////////////////////////////////////////////////

// Main Function

int main(int argc, char** argv) {

    int size = atoi(argv[1]);           // Gets the size
    char * filename = argv[2];          // Gets the filename
    int which_sort = atoi(argv[3]);     // 1 for bitonic sort, 0 for quicksort
    int layers = atoi(argv[4]);         // Number of layers to go down
                                        // If layers == 0, then the sorting
                                        // algorithms will be sequential

    array = read_arr(size, filename);   // Reads array from file

    
    clock_t start_time, end_time;       // Instantiate timing variables
    start_time = clock();               // Gets start time
    
    if (which_sort == 0) {                      // Quicksort chosen
        printf("Quicksort chosen\n");
        //print_arr(array, size);
        quicksort(array, size, layers);         // Perform Quicksort
        //print_arr(array, size);
        is_arr_sorted(array, size);
    } else if (which_sort == 1) {               // Bitonic Sort chosen
        printf("Bitonic Sort chosen\n");
        //print_arr(array, size);
        bitonic_sort(array, size, layers);      // Perform Bitonic Sort
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
