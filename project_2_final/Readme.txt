Since this code is being tested on ORBIT machines, we assume that an environment with ispc has been created


To generate matrices for ISPC part: 
1) compile
    gcc array_gen.c -o array_gen.o -lm
2) run
    ./array_gen.o <array_filename> <sqrt_array_filename> <num_elements>


The ISPC part (using SSE or AVX instructions):

1a) Compile with sse4-i32x8 instructions
    ispc newton.ispc -h newton.h -o newton_ispc_sse4.o --target=sse4-i32x8
1b) Compile with avx2-i32x8 instructions
    ispc newton.ispc -h newton.h -o newton_ispc_avx2.o --target=avx2-i32x8

2) Compile tasksys.cpp which comes along with ispc. A copy is included here
    g++ -c tasksys.cpp -o tasksys.o

3) Compile ispc code with regular code
    g++ -Wall -Werror sqrt_ispc.c newton_ispc_<sse4/avx2>.o tasksys.o -o sqrt_ispc -lpthread

4) run, this will loop over all different number of threads and cores:
    ./sqrt_ispc <array_filename> <number of elements>
    The output is shown below


The AVX intrinsics ONLY part:

1a) Compile sequential version
    gcc sqrt_avx_seq.c -o sqrt_avx_seq.o
1b) Compile parallel version
    gcc -mavx sqrt_avx_parallel.c -o sqrt_avx_parllel.o

2a) Run Sequential version
    ./sqrt_avx_seq.o <num_elements>
2b) Run Parallel Version
    ./sqrt_avx_parallel.o <num_elements>


//////////////////////////////////////////////////////////////////////////////////////

The performance of the code was tested on sb1.orbit-lab.org
The output timings are given in seconds

The output files are:
    output_avx_only	// AVX Intrinsics only
    output_ispc_sse_15m	// ISPC compiled with SSE instructions, 15 million elements
    output_ispc_sse_30m	// ISPC compiled with SSE instructions, 30 million elements
    output_ispc_avx_15m	// ISPC compiled with AVX instructions, 15 million elements
    output_ispc_avx_30m	// ISPC compiled with AVX instructions, 30 million elements


ISPC SAMPLE OUTPUT

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


AVX INTRINSICS ONLY SAMPLE OUTPUT

Sequential
Time taken: 0.691788
Time taken: 1.382810

Parallel
Time Taken = 0.478799
Time Taken = 0.971262

