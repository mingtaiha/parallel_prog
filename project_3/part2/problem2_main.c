#include "problem2.h"


int main(int argc, char * argv[]) {

    int ROW1 = atoi(argv[1]);
    int COL1 = atoi(argv[2]);
    int ROW2 = atoi(argv[3]);
    int COL2 = atoi(argv[4]);

    double * mat1 = make_matrix(ROW1, COL1);
    print_matrix(mat1, ROW1, COL1);

    double * mat2 = make_matrix(ROW2, COL2);
    print_matrix(mat2, ROW2, COL2);

    printf("CPU Matrix Multiplication\n");
    double * C_seq = mult_matrix_seq(mat1, mat2, ROW1, COL1, ROW2, COL2);

    printf("GPU Basic Matrix Multiplication\n");
    mat_mult_gpu(mat1, mat2, ROW1, COL1, ROW2, COL2);

    double * diff = diff_matrix(mat1, mat2, ROW1, COL2, ROW1, COL2);
    print_matrix(diff, ROW1, COL1);
    return 0;
}
