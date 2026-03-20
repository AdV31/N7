#include <aux.h>






int main() {
int i, j;

#pragma omp parallel for private(i,j) collapse(2)
for (i=0; i<2; i++) {
  for (j=0; j<2; j++) {
    printf("Thread %2d does iteration i:%2d j:%2d\n",omp_get_thread_num(),i,j);
  }
}
return 0;
}
