To compile the ISPC part of it:

ispc newton.ispc -o newton_ispc.o

root@node1-11:~# g++ -Wall -Werror sqrt_ispc.c newton_ispc.o tasksys.o -o sqrt_ispc -lpthread

To run:
./sqrt_ispc [Number_of_cores]

for example: 

root@node1-11:~# ./sqrt_ispc 4
Reading Array
Time taken: 0.594615


Image is saved to: 
Group3ISPC.ndz

Raw data:

.
root@node1-11:~# ./sqrt_ispc 4
Reading Array
Time taken: 0.659015
root@node1-11:~# ./sqrt_ispc 1
Reading Array
Time taken: 0.583182
root@node1-11:~# ./sqrt_ispc 2
Reading Array
Time taken: 0.581795
root@node1-11:~# ./sqrt_ispc 3
Reading Array
Time taken: 0.584317
root@node1-11:~# ./sqrt_ispc 4
Reading Array
Time taken: 0.597107
root@node1-11:~# ./sqrt_ispc 5
Reading Array
Time taken: 0.644324
root@node1-11:~# ./sqrt_ispc 16
Invalid number of cores.root@node1-11:~# ./sqrt_ispc 8
Reading Array
Time taken: 0.751932

c
root@node1-12:~# ./sqrt_ispc 1
Reading Array
Time taken: 0.437670
root@node1-12:~# ./sqrt_ispc 2
Reading Array
Time taken: 0.445981
root@node1-12:~# ./sqrt_ispc 3
Reading Array
Time taken: 0.456826
root@node1-12:~# ./sqrt_ispc 4
Reading Array
Time taken: 0.473212
root@node1-12:~# ./sqrt_ispc 8
Reading Array
Time taken: 0.628615
root@node1-12:~#

s
root@node1-13:~# ./sqrt_ispc 1
Reading Array
Time taken: 0.442156
root@node1-13:~# ./sqrt_ispc 2
Reading Array
Time taken: 0.443815
root@node1-13:~# ./sqrt_ispc 3
Reading Array
Time taken: 0.454411
root@node1-13:~# ./sqrt_ispc 4
Reading Array
Time taken: 0.468050
root@node1-13:~# ./sqrt_ispc 8
Reading Array
Time taken: 0.478062
root@node1-13:~#

.
root@node1-14:~# ./sqrt_ispc 1
Reading Array
Time taken: 0.443386
root@node1-14:~# ./sqrt_ispc 2
Reading Array
Time taken: 0.443816
root@node1-14:~# ./sqrt_ispc 3
Reading Array
Time taken: 0.454954
root@node1-14:~# ./sqrt_ispc 8
Reading Array
Time taken: 0.477420
root@node1-14:~# ./sqrt_ispc 4
Reading Array
Time taken: 0.468506
root@node1-14:~#



