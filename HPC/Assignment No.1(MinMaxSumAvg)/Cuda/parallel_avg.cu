#include<stdio.h>
#include<time.h>
#define SIZE 10000
// MAX_THREADS depends on type of GPU
#define MAX_THREADS 1024

__global__ void sum(const int* __restrict__ input, const int size, int* sumOut)
{
    int i = threadIdx.x + blockDim.x * blockIdx.x;
    atomicAdd(sumOut, input[i]);
}

int main()
{
  int i;
  int a[SIZE];
  int c = 0;
  int *dev_a, *dev_c;
    
  cudaMalloc((void **) &dev_a, SIZE*sizeof(int));
  cudaMalloc((void **) &dev_c, sizeof(int));
  srand(time(0));
  for( i = 0 ; i < SIZE ; i++)
  {
    a[i] = (rand() % (1000 - 100 + 1)) + 100;
  }
  for( i = 0 ; i < SIZE ; i++)
  {
    printf("%d ",a[i]);
    if (i%10==0 && i!=0){
      printf("\n");
    }
  }
  cudaMemcpy(dev_c , &c, sizeof(int),cudaMemcpyHostToDevice);
  cudaMemcpy(dev_a , a, SIZE*sizeof(int),cudaMemcpyHostToDevice);
   // adjusting the number of threads per block
   dim3 threadsPerBlock(SIZE);
   dim3 blocksPerGrid(1, 1);
   if(SIZE > 1024){
           threadsPerBlock.x = 1024;
           blocksPerGrid.x = ceil(double(SIZE)/double(threadsPerBlock.x));
   }
  clock_t start = clock();
  sum<<<blocksPerGrid,threadsPerBlock>>>(dev_a,SIZE,dev_c);
  cudaMemcpy(&c, dev_c, sizeof(int),cudaMemcpyDeviceToHost);
  c = c / SIZE;
  clock_t end = clock();
  
  printf("avg =  %d ",c);
  printf("\nThe gpu took: %f milli-seconds.\n",(float)(end-start)/CLOCKS_PER_SEC);
    
  printf("\n");
  printf("avg =  %d ",c);
  cudaFree(dev_a);
  cudaFree(dev_c);
  return 0;
}
