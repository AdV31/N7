#include <aux.h>






int main() {
    int i, sum, n=1000;
    int x[n];  

    rand_fill(x, n); sum=0;

#pragma omp parallel reduction(+:sum)
    {
#pragma omp for 
      for(i=0; i<n; i++){
        sum += x[i];
      }
      printf("Partial Sum on %d is %d\n",omp_get_thread_num(),sum);
    }
    printf("Sum is %d\n",sum);

return 0;
}
