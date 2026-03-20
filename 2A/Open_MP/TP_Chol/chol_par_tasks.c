#include "trace.h"
#include "common.h"

/* This is a sequential routine for the LU factorization of a square
   matrix in block-columns */
void chol_par_tasks(matrix_t A){


  int i, j, k;

  #pragma omp parallel private(k,i,j)
  {
    #pragma omp single
    for(k=0; k<A.NB; k++){
      /* reduce the diagonal block */
      #pragma omp task depend(in:A.blocks[k][k]) depend(out:A.blocks[k][k]) priority(400)
      potrf(A.blocks[k][k]);
      
          for(i=k+1; i<A.NB; i++){
            /* compute the A[i][k] sub-diagonal block */
            #pragma omp task depend(in:A.blocks[k][k],A.blocks[i][k]) depend(out:A.blocks[i][k]) priority(200)
            trsm(A.blocks[k][k], A.blocks[i][k]);
            for(j=k+1; j<=i; j++){
              /* update the A[i][j] block in the trailing submatrix */
              #pragma omp task depend(in:A.blocks[j][k],A.blocks[i][k],A.blocks[i][j]) depend(out:A.blocks[i][j])
              gemm(A.blocks[i][k], A.blocks[j][k], A.blocks[i][j]);
            }
          }
    }
  }

  return;

}

