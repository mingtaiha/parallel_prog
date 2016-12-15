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
    print_matrix(C_seq, ROW1, COL2);

    printf("GPU Basic Matrix Multiplication\n");
    double * C_gpu_basic = mat_mult_gpu_basic(mat1, mat2, ROW1, COL1, ROW2, COL2);
    print_matrix(C_gpu_basic, ROW1, COL2);

    printf("GPU CUBLAS Matrix Multiplication\n");
    double * C_gpu_cublas = mat_mult_gpu_cublas(mat1, mat2, ROW1, COL1, ROW2, COL2);
    print_matrix(C_gpu_cublas, ROW1, COL2);

    printf("CPU / GPU Basic diff\n");
    double * diff_basic = diff_matrix(C_seq, C_gpu_basic, ROW1, COL2, ROW1, COL2);
    print_matrix(diff_basic, ROW1, COL1);

    printf("CPU / GPU CUBLAS diff\n");
    double * diff_cublas = diff_matrix(C_seq, C_gpu_cublas, ROW1, COL2, ROW1, COL2);
    print_matrix(diff_cublas, ROW1, COL1);



    return 0;
}
