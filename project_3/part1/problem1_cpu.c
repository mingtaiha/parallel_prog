#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "array_gen.h"


double max_array(double * arr, int SIZE) {

    int i;
    double max = arr[0];
    for (i = 1; i < SIZE; i++) {
        if (max < arr[i]) {
            max = arr[i];
        }
    }
    return max;
}

double min_array(double * arr, int SIZE) {
    
    int i;
    double min = arr[0];
    for (i = 1; i < SIZE; i++) {
        if (min > arr[i]) {
            min = arr[i];
        }
    }
    return min;
}

double avg_array(double * arr, int SIZE) {

    int i;
    double sum = 0;
    for (i = 0; i < SIZE; i++) {
        sum += arr[i];
    }
    double avg = sum / SIZE;
    return avg;
}

double std_array(double * arr, int SIZE) {

    int i;
    double sum = 0;
    double avg = avg_array(arr, SIZE);

    for (i = 0; i < SIZE; i++) {
        sum += (arr[i] - avg) * (arr[i] - avg);
    }
    double std = sqrt(sum / SIZE);
    return std;
}



int main(int argc, char * argv[]) {

    char * filename = argv[1];
    int SIZE = atoi(argv[2]);
    double * arr = read_array(filename, SIZE);

    double max = max_array(arr, SIZE);
    printf("Max: %f\n", max);
    double min = min_array(arr, SIZE);
    printf("Min: %f\n", min);
    double avg = avg_array(arr, SIZE);
    printf("Avg: %f\n", avg);
    double std = std_array(arr, SIZE);
    printf("Std: %f\n", std);

    return 0;
}
