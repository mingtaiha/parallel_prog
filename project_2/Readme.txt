To compile the ISPC part of it:

ispc newton.ispc -h newton_ispc.h -o newton_ispc.o

root@node1-11:~# g++ -Wall -Werror sqrt_ispc.c newton_ispc.o tasksys.o -o sqrt_ispc -lpthread

To run:
./sqrt_ispc [Number_of_cores] [Number_of_threads]

for example: 

root@node1-11:~# ./sqrt_ispc 4
Reading Array
Time taken: 0.594615


Image is saved to: 
Group3ISPC.ndz

Threaded image is saved to:
Group3ISPCwithThreading.ndz

To load image:

omf load -t all -i Group3ISPCwithThreading.ndz
omf tell -a on -t all


Raw data:
root@node1-1:~# ./sqrt_ispc 1 1
Reading Array
Time taken: 2.931709
root@node1-1:~# ./sqrt_ispc 1 2
Reading Array
Time taken: 2.926704
root@node1-1:~# ./sqrt_ispc 1 3
Reading Array
Time taken: 2.933676
root@node1-1:~# ./sqrt_ispc 1 4
Reading Array
Time taken: 2.943198
root@node1-1:~# ./sqrt_ispc 1 5
Reading Array
Time taken: 2.992984
root@node1-1:~# ./sqrt_ispc 1 6
Reading Array
Time taken: 3.028471
root@node1-1:~# ./sqrt_ispc 1 7
Reading Array
Time taken: 3.049301
root@node1-1:~# ./sqrt_ispc 1 8
Reading Array
Time taken: 3.084458
root@node1-1:~# ./sqrt_ispc 1 -1
Reading Array
Time taken: 0.223527
root@node1-1:~# ./sqrt_ispc 2 1
Reading Array
Time taken: 0.971427
root@node1-1:~# ./sqrt_ispc 2 2
Reading Array
Time taken: 0.972464
root@node1-1:~# ./sqrt_ispc 2 3
Reading Array
Time taken: 0.976951
root@node1-1:~# ./sqrt_ispc 2 4
Reading Array
Time taken: 0.977997
root@node1-1:~# ./sqrt_ispc 2 5
Reading Array
Time taken: 0.991260
root@node1-1:~# ./sqrt_ispc 2 6
Reading Array
Time taken: 1.002505
root@node1-1:~# ./sqrt_ispc 2 7
Reading Array
Time taken: 1.012253
root@node1-1:~# ./sqrt_ispc 2 8
Reading Array
Time taken: 1.025442
root@node1-1:~# ./sqrt_ispc 2 -1
Reading Array
Time taken: 0.218335
root@node1-1:~# ./sqrt_ispc 3 1
Reading Array
Time taken: 0.728830
root@node1-1:~# ./sqrt_ispc 3 2
Reading Array
Time taken: 0.730819
root@node1-1:~# ./sqrt_ispc 3 3
Reading Array
Time taken: 0.730885
root@node1-1:~# ./sqrt_ispc 3 4
Reading Array
Time taken: 0.734190
root@node1-1:~# ./sqrt_ispc 3 5
Reading Array
Time taken: 0.743492
root@node1-1:~# ./sqrt_ispc 3 6
Reading Array
Time taken: 0.754028
root@node1-1:~# ./sqrt_ispc 3 7
Reading Array
Time taken: 0.759191
root@node1-1:~# ./sqrt_ispc 3 8
Reading Array
Time taken: 0.770975
root@node1-1:~# ./sqrt_ispc 3 -1
Reading Array
Time taken: 0.220393
root@node1-1:~# ./sqrt_ispc 4 1
Reading Array
Time taken: 0.584592
root@node1-1:~# ./sqrt_ispc 4 2
Reading Array
Time taken: 0.584260
root@node1-1:~# ./sqrt_ispc 4 3
Reading Array
Time taken: 0.586733
root@node1-1:~# ./sqrt_ispc 4 4
Reading Array
Time taken: 0.588287
root@node1-1:~# ./sqrt_ispc 4 5
Reading Array
Time taken: 0.594147
root@node1-1:~# ./sqrt_ispc 4 6
Reading Array
Time taken: 0.603425
root@node1-1:~# ./sqrt_ispc 4 7
Reading Array
Time taken: 0.607317
root@node1-1:~# ./sqrt_ispc 4 8
Reading Array
Time taken: 0.616251
root@node1-1:~# ./sqrt_ispc 4 -1
Reading Array
Time taken: 0.263216

root@node1-1:~# ./sqrt_ispc 5 1
Reading Array
Time taken: 0.487025
root@node1-1:~# ./sqrt_ispc 5 2
Reading Array
Time taken: 0.487201
root@node1-1:~# ./sqrt_ispc 5 3
Reading Array
Time taken: 0.487680
root@node1-1:~# ./sqrt_ispc 5 4
Reading Array
Time taken: 0.489802
root@node1-1:~# ./sqrt_ispc 5 5
Reading Array
Time taken: 0.496070
root@node1-1:~# ./sqrt_ispc 5 6
Reading Array
Time taken: 0.501052
root@node1-1:~# ./sqrt_ispc 5 7
Reading Array
Time taken: 0.506143
root@node1-1:~# ./sqrt_ispc 5 8
Reading Array
Time taken: 0.526926
root@node1-1:~# ./sqrt_ispc 5 -1
Reading Array
Time taken: 0.259448
root@node1-1:~# ./sqrt_ispc 6 1
Reading Array
Time taken: 0.417895
root@node1-1:~# ./sqrt_ispc 6 2
Reading Array
Time taken: 0.416863
root@node1-1:~# ./sqrt_ispc 6 3
Reading Array
Time taken: 0.418356
root@node1-1:~# ./sqrt_ispc 6 4
Reading Array
Time taken: 0.420080
root@node1-1:~# ./sqrt_ispc 6 5
Reading Array
Time taken: 0.424447
root@node1-1:~# ./sqrt_ispc 6 6
Reading Array
Time taken: 0.430720
root@node1-1:~# ./sqrt_ispc 6 7
Reading Array
Time taken: 0.433907
root@node1-1:~# ./sqrt_ispc 6 8
Reading Array
Time taken: 0.440655
root@node1-1:~# ./sqrt_ispc 6 -1
Reading Array
Time taken: 0.283506
root@node1-1:~# ./sqrt_ispc 7 1
Reading Array
Time taken: 0.364163
root@node1-1:~# ./sqrt_ispc 7 2
Reading Array
Time taken: 0.364881
root@node1-1:~# ./sqrt_ispc 7 3
Reading Array
Time taken: 0.366309
root@node1-1:~# ./sqrt_ispc 7 4
Reading Array
Time taken: 0.367749
root@node1-1:~# ./sqrt_ispc 7 5
Reading Array
Time taken: 0.371444
root@node1-1:~# ./sqrt_ispc 7 6
Reading Array
Time taken: 0.376259
root@node1-1:~# ./sqrt_ispc 7 7
Reading Array
Time taken: 0.379694
root@node1-1:~# ./sqrt_ispc 7 8
Reading Array
Time taken: 0.385817
root@node1-1:~# ./sqrt_ispc 7 -1
Reading Array
Time taken: 0.302831

root@node1-1:~# ./sqrt_ispc 8 1
Reading Array
Time taken: 0.332794
root@node1-1:~# ./sqrt_ispc 8 2
Reading Array
Time taken: 0.325115
root@node1-1:~# ./sqrt_ispc 8 3
Reading Array
Time taken: 0.325860
root@node1-1:~# ./sqrt_ispc 8 4
Reading Array
Time taken: 0.334487
root@node1-1:~# ./sqrt_ispc 8 5
Reading Array
Time taken: 0.330757
root@node1-1:~# ./sqrt_ispc 8 6
Reading Array
Time taken: 0.334903
root@node1-1:~# ./sqrt_ispc 8 7
Reading Array
Time taken: 0.337883
root@node1-1:~# ./sqrt_ispc 8 8
Reading Array
Time taken: 0.343132
root@node1-1:~# ./sqrt_ispc 8 -1
Reading Array
Time taken: 0.302807

root@node1-1:~# ./sqrt_ispc 9 -1
Reading Array
Time taken: 0.305744
root@node1-1:~# ./sqrt_ispc 10 -1
Reading Array
Time taken: 0.299541
root@node1-1:~# ./sqrt_ispc 11 -1
Reading Array
Time taken: 0.297361
root@node1-1:~# ./sqrt_ispc 16 -1
Reading Array
Time taken: 0.309338
root@node1-1:~# ./sqrt_ispc 32 -1
Reading Array
Time taken: 0.304093






