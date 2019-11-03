#include<stdio.h>
#define SIZE 1000000
// MAX_THREADS depends on type of GPU
#define MAX_THREADS 1024

__global__ void max(int* input, int* maxOut) {
        int i = threadIdx.x + blockIdx.x * blockDim.x;
        atomicMax(maxOut, input[i]);
}

int main() {
        int input[SIZE];
        int maxO = 0;
        int i = 0;
        for(i = 0; i < SIZE; i++)
                input[i] = (rand() % 10000) + 1;
        
        int* d_input;
        int* d_max;
        
        cudaMalloc((void**)&d_input, SIZE * sizeof(int));
        cudaMalloc((void**)&d_max, sizeof(int));
        
        cudaMemcpy(d_input, &input, SIZE * sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_max, &maxO, sizeof(int), cudaMemcpyHostToDevice);
        // adjusting the number of threads per block
        dim3 threadsPerBlock(SIZE);
        dim3 blocksPerGrid(1, 1);
        if(SIZE > 1024){
                threadsPerBlock.x = 1024;
                blocksPerGrid.x = ceil(double(SIZE)/double(threadsPerBlock.x));
        }

        max<<<blocksPerGrid,threadsPerBlock>>>(d_input, d_max);
        
        cudaMemcpy(&maxO, d_max, sizeof(int), cudaMemcpyDeviceToHost);
        
        printf("\nMax: %d",maxO);
        
        cudaFree(d_max);
        cudaFree(d_input);  
        return 0;
}
