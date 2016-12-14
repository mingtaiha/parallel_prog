#include "problem2.h"

#define TEST 0

double * mult_matrix_seq(double * A, double * B, int ROW_A, int COL_A, int ROW_B, int COL_B) {

    if (COL_A != ROW_B) {
        printf("Can't multiply. Dimensions don't match\n");
        exit(0);
    }
    
    printf("Mutliplying Matrix\n");

    int i, j, k;
    double * C = (double *) calloc(ROW_A * COL_B, sizeof(double));
    
    for (i = 0; i < ROW_A; i++) {
        for (j = 0; j < COL_B; j++) {
            for (k = 0; k < COL_A; k++) {
                C[(ROW_A * i) + j] += A[(COL_A * i) + k] * B[(COL_B * k) + j];
            }
        }            
    }
    printf("Done Multiplying\n");
    return C;
}

#if TEST
/*
int main(int argc, char * argv[]) {

    char * filename1 = argv[1];
    char * filename2 = argv[2];
    int ROW1 = atoi(argv[3]);
    int COL1 = atoi(argv[4]);
    int ROW2 = atoi(argv[5]);
    int COL2 = atoi(argv[6]);

    double ** mat1 = read_matrix(filename1, ROW1, COL1);
    print_matrix(mat1, ROW1, COL1);

    double ** mat2 = read_matrix(filename2, ROW2, COL2);
    print_matrix(mat2, ROW2, COL2);

    mult_matrix(mat1, mat2, ROW1, COL1, ROW2, COL2);
    return 0;
}
*/
#endif
