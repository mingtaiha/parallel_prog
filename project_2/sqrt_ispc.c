#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include "array_gen.h"
#include "newton.h"
float * arr;
float * appx_arr;
float tolerance = 0.0001;
float size = SIZE;

int main(){
        clock_t begin;
        clock_t end;
        double time;
        double base=0;
        char arr_name[] = "arr_30m.dat";
        arr = read_array(arr_name);
        appx_arr = (float *) calloc(SIZE, sizeof(float));
        for(int cores = 1; cores < 9; cores++){
                for(int threads = 1; threads < 9; threads++){
                        begin = clock();
                        ispc::newton_ispc(size, threads, cores, arr, appx_arr);
                        end = clock();
                        time = (double) (end-begin) / CLOCKS_PER_SEC;
                        if(cores == 1 && threads == 1){
                                base = time;
                        }
                        printf("Cores: %d, Threads: %d, Time taken: %f, Speedup: %f\n",cores,threads,time,base/time);
                }
                begin = clock();
                ispc::newton_ispc(size, -1, cores, arr, appx_arr);
                end = clock();
                time = (double) (end-begin) / CLOCKS_PER_SEC;
                printf("Cores: %d, Threads: All, Time taken: %f, Speedup: %f\n",cores,time,base/time);
        }
        return 0;
}
