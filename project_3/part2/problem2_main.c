#include "problem2.h"


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

    mult_matrix_seq(mat1, mat2, ROW1, COL1, ROW2, COL2);
    return 0;
}
