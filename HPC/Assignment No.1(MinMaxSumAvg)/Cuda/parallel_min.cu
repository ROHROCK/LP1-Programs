#include <stdio.h>
#include <time.h>
#define SIZE 10000
// MAX_THREADS depends on type of GPU
#define MAX_THREADS 1024

__global__ void min(const int* __restrict__ input,int* minOut)
{
  int i = threadIdx.x + blockIdx.x * blockDim.x;
  atomicMin(minOut, input[i]);
}

int main()
{
  int i;
  int a[SIZE];
  int c;
  int *dev_a, *dev_c;
  cudaMalloc((void **) &dev_a, SIZE*sizeof(int));
  cudaMalloc((void **) &dev_c, sizeof(int));
  srand(time(0));
  for( i = 0 ; i < SIZE ; i++)
  {
    a[i] = (rand() % (1000 - 100 + 1)) + 100;
  }
  // a[0]= -10; just to check 
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
  min<<<blocksPerGrid,threadsPerBlock>>>(dev_a,dev_c);
  cudaMemcpy(&c, dev_c, sizeof(int),cudaMemcpyDeviceToHost);
  clock_t end = clock();
  printf("\nmin =  %d ",c);
  printf("\nThe time taken to execute is: %f",(float)(end-start)/CLOCKS_PER_SEC);
  cudaFree(dev_a);
  cudaFree(dev_c);
  return 0;
}
