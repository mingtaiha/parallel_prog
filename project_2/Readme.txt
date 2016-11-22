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



root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 1 1
Reading Array
Time taken: 2.931709
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 1 2
Reading Array
Time taken: 2.926704
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 1 3
Reading Array
Time taken: 2.933676
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 1 4
Reading Array
Time taken: 2.943198
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 1 5
Reading Array
Time taken: 2.992984
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 1 6
Reading Array
Time taken: 3.028471
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 1 7
Reading Array
Time taken: 3.049301
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 1 8
Reading Array
Time taken: 3.084458
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 1 -1
Reading Array
Time taken: 0.223527
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 2 1
Reading Array
Time taken: 0.971427
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 2 2
Reading Array
Time taken: 0.972464
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 2 3
Reading Array
Time taken: 0.976951
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 2 4
Reading Array
Time taken: 0.977997
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 2 5
Reading Array
Time taken: 0.991260
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 2 6
Reading Array
Time taken: 1.002505
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 2 7
Reading Array
Time taken: 1.012253
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 2 8
Reading Array
Time taken: 1.025442
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 2 -1
Reading Array
Time taken: 0.218335
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 3 1
Reading Array
Time taken: 0.728830
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 3 2
Reading Array
Time taken: 0.730819
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 3 3
Reading Array
Time taken: 0.730885
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 3 4
Reading Array
Time taken: 0.734190
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 3 5
Reading Array
Time taken: 0.743492
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 3 6
Reading Array
Time taken: 0.754028
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 3 7
Reading Array
Time taken: 0.759191
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 3 8
Reading Array
Time taken: 0.770975
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 3 -1
Reading Array
Time taken: 0.220393
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 4 1
Reading Array
Time taken: 0.584592
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 4 2
Reading Array
Time taken: 0.584260
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 4 3
Reading Array
Time taken: 0.586733
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 4 4
Reading Array
Time taken: 0.588287
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 4 5
Reading Array
Time taken: 0.594147
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 4 6
Reading Array
Time taken: 0.603425
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 4 7
Reading Array
Time taken: 0.607317
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 4 8
Reading Array
Time taken: 0.616251
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 4 -1
Reading Array
Time taken: 0.263216

root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 5 1
Reading Array
Time taken: 0.487025
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 5 2
Reading Array
Time taken: 0.487201
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 5 3
Reading Array
Time taken: 0.487680
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 5 4
Reading Array
Time taken: 0.489802
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 5 5
Reading Array
Time taken: 0.496070
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 5 6
Reading Array
Time taken: 0.501052
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 5 7
Reading Array
Time taken: 0.506143
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 5 8
Reading Array
Time taken: 0.526926
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 5 -1
Reading Array
Time taken: 0.259448
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 6 1
Reading Array
Time taken: 0.417895
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 6 2
Reading Array
Time taken: 0.416863
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 6 3
Reading Array
Time taken: 0.418356
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 6 4
Reading Array
Time taken: 0.420080
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 6 5
Reading Array
Time taken: 0.424447
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 6 6
Reading Array
Time taken: 0.430720
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 6 7
Reading Array
Time taken: 0.433907
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 6 8
Reading Array
Time taken: 0.440655
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 6 -1
Reading Array
Time taken: 0.283506
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 7 1
Reading Array
Time taken: 0.364163
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 7 2
Reading Array
Time taken: 0.364881
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 7 3
Reading Array
Time taken: 0.366309
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 7 4
Reading Array
Time taken: 0.367749
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 7 5
Reading Array
Time taken: 0.371444
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 7 6
Reading Array
Time taken: 0.376259
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 7 7
Reading Array
Time taken: 0.379694
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 7 8
Reading Array
Time taken: 0.385817
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 7 -1
Reading Array
Time taken: 0.302831

root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 8 1
Reading Array
Time taken: 0.332794
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 8 2
Reading Array
Time taken: 0.325115
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 8 3
Reading Array
Time taken: 0.325860
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 8 4
Reading Array
Time taken: 0.334487
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 8 5
Reading Array
Time taken: 0.330757
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 8 6
Reading Array
Time taken: 0.334903
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 8 7
Reading Array
Time taken: 0.337883
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 8 8
Reading Array
Time taken: 0.343132
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 8 -1
Reading Array
Time taken: 0.302807

root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 9 -1
Reading Array
Time taken: 0.305744
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 10 -1
Reading Array
Time taken: 0.299541
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 11 -1
Reading Array
Time taken: 0.297361
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 16 -1
Reading Array
Time taken: 0.309338
root@node1-1:~# ./sqrt_ispc arr_30m.dat 30000000 32 -1
Reading Array
Time taken: 0.304093


New program version:
Reading Array
Cores: 1, Threads: 1, Time taken: 2.921518, Speedup: 1.000000
Cores: 1, Threads: 2, Time taken: 1.550144, Speedup: 1.884675
Cores: 1, Threads: 3, Time taken: 1.050666, Speedup: 2.780634
Cores: 1, Threads: 4, Time taken: 0.792861, Speedup: 3.684780
Cores: 1, Threads: 5, Time taken: 0.647700, Speedup: 4.510604
Cores: 1, Threads: 6, Time taken: 0.548074, Speedup: 5.330517
Cores: 1, Threads: 7, Time taken: 0.482241, Speedup: 6.058212
Cores: 1, Threads: 8, Time taken: 0.424536, Speedup: 6.881673
Cores: 1, Threads: All, Time taken: 0.209601, Speedup: 13.938474
Cores: 2, Threads: 1, Time taken: 2.913749, Speedup: 1.002666
Cores: 2, Threads: 2, Time taken: 2.005035, Speedup: 1.457091
Cores: 2, Threads: 3, Time taken: 1.678578, Speedup: 1.740472
Cores: 2, Threads: 4, Time taken: 1.506773, Speedup: 1.938924
Cores: 2, Threads: 5, Time taken: 1.413632, Speedup: 2.066675
Cores: 2, Threads: 6, Time taken: 1.351391, Speedup: 2.161860
Cores: 2, Threads: 7, Time taken: 1.306005, Speedup: 2.236988
Cores: 2, Threads: 8, Time taken: 1.269361, Speedup: 2.301566
Cores: 2, Threads: All, Time taken: 0.211273, Speedup: 13.828165
Cores: 3, Threads: 1, Time taken: 2.912355, Speedup: 1.003146
Cores: 3, Threads: 2, Time taken: 1.888580, Speedup: 1.546939
Cores: 3, Threads: 3, Time taken: 1.521937, Speedup: 1.919605
Cores: 3, Threads: 4, Time taken: 1.374497, Speedup: 2.125518
Cores: 3, Threads: 5, Time taken: 1.224478, Speedup: 2.385929
Cores: 3, Threads: 6, Time taken: 1.151742, Speedup: 2.536608
Cores: 3, Threads: 7, Time taken: 1.098240, Speedup: 2.660182
Cores: 3, Threads: 8, Time taken: 1.055423, Speedup: 2.768102
Cores: 3, Threads: All, Time taken: 0.211348, Speedup: 13.823258
Cores: 4, Threads: 1, Time taken: 3.049094, Speedup: 0.958159
Cores: 4, Threads: 2, Time taken: 1.886204, Speedup: 1.548888
Cores: 4, Threads: 3, Time taken: 1.472317, Speedup: 1.984300
Cores: 4, Threads: 4, Time taken: 1.258400, Speedup: 2.321613
Cores: 4, Threads: 5, Time taken: 1.142724, Speedup: 2.556626
Cores: 4, Threads: 6, Time taken: 1.063337, Speedup: 2.747500
Cores: 4, Threads: 7, Time taken: 1.000344, Speedup: 2.920513
Cores: 4, Threads: 8, Time taken: 0.928647, Speedup: 3.145994
Cores: 4, Threads: All, Time taken: 0.254385, Speedup: 11.484632
Cores: 5, Threads: 1, Time taken: 3.028494, Speedup: 0.964677
Cores: 5, Threads: 2, Time taken: 1.830934, Speedup: 1.595644
Cores: 5, Threads: 3, Time taken: 1.402101, Speedup: 2.083672
Cores: 5, Threads: 4, Time taken: 1.181500, Speedup: 2.472719
Cores: 5, Threads: 5, Time taken: 1.058708, Speedup: 2.759513
Cores: 5, Threads: 6, Time taken: 1.004448, Speedup: 2.908581
Cores: 5, Threads: 7, Time taken: 0.914433, Speedup: 3.194896
Cores: 5, Threads: 8, Time taken: 0.895135, Speedup: 3.263774
Cores: 5, Threads: All, Time taken: 0.247308, Speedup: 11.813277
Cores: 6, Threads: 1, Time taken: 3.124106, Speedup: 0.935153
Cores: 6, Threads: 2, Time taken: 1.834114, Speedup: 1.592877
Cores: 6, Threads: 3, Time taken: 1.402108, Speedup: 2.083661
Cores: 6, Threads: 4, Time taken: 1.171838, Speedup: 2.493107
Cores: 6, Threads: 5, Time taken: 1.035898, Speedup: 2.820276
Cores: 6, Threads: 6, Time taken: 0.950035, Speedup: 3.075169
Cores: 6, Threads: 7, Time taken: 0.885049, Speedup: 3.300968
Cores: 6, Threads: 8, Time taken: 0.837378, Speedup: 3.488888
Cores: 6, Threads: All, Time taken: 0.273541, Speedup: 10.680366
Cores: 7, Threads: 1, Time taken: 3.171590, Speedup: 0.921152
Cores: 7, Threads: 2, Time taken: 1.847947, Speedup: 1.580953
Cores: 7, Threads: 3, Time taken: 1.380342, Speedup: 2.116518
Cores: 7, Threads: 4, Time taken: 1.142866, Speedup: 2.556308
Cores: 7, Threads: 5, Time taken: 1.003540, Speedup: 2.911212
Cores: 7, Threads: 6, Time taken: 0.920641, Speedup: 3.173352
Cores: 7, Threads: 7, Time taken: 0.852287, Speedup: 3.427857
Cores: 7, Threads: 8, Time taken: 0.803039, Speedup: 3.638077
Cores: 7, Threads: All, Time taken: 0.294163, Speedup: 9.931630
Cores: 8, Threads: 1, Time taken: 3.231933, Speedup: 0.903954
Cores: 8, Threads: 2, Time taken: 1.854555, Speedup: 1.575320
Cores: 8, Threads: 3, Time taken: 1.362931, Speedup: 2.143555
Cores: 8, Threads: 4, Time taken: 1.116422, Speedup: 2.616858
Cores: 8, Threads: 5, Time taken: 0.978697, Speedup: 2.985110
Cores: 8, Threads: 6, Time taken: 0.901839, Speedup: 3.239512
Cores: 8, Threads: 7, Time taken: 0.817670, Speedup: 3.572979
Cores: 8, Threads: 8, Time taken: 0.767849, Speedup: 3.804808
Cores: 8, Threads: All, Time taken: 0.308580, Speedup: 9.467619

Image saved to: 
 INFO node1-1.sb1.orbit-lab.org:   to the file 'Group3-node-node1-1.sb1.orbit-lab.org-2016-11-21-22-24-08.ndz' on host '10.11.0.42'




