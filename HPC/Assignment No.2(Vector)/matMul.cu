#include<iostream>
#include<time.h>
#define SIZE 100
using namespace std;

__global__ void mul(int (*mat1)[SIZE][SIZE] , int (*mat2)[SIZE][SIZE] , long (*result)[SIZE][SIZE]){
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    int j =  threadIdx.y + blockIdx.y * blockDim.y;
    if(i < SIZE && j < SIZE){
        (*result)[i][j] = 0;
        for(int k = 0 ; k < SIZE ; k++)
            (*result)[i][j] += (*mat1)[i][k]*(*mat2)[k][j];
    }
}

int main(){
    int mat1[SIZE][SIZE];
    int mat2[SIZE][SIZE];
    long result[SIZE][SIZE];

    // pointer to gpu location
    int (*d_in_mat1)[SIZE][SIZE], (*d_in_mat2)[SIZE][SIZE];
    long (*d_out_result)[SIZE][SIZE];

    // intialize
    for(int i = 0 ; i < SIZE ; i++){
        for(int j = 0 ; j < SIZE ; j++){
            mat1[i][j] = i+1;
            mat2[i][j] = i+1;
            result[i][j] = 0;
        }
    }

    // Allocate memory to gpu
    cudaMalloc((void**)&d_in_mat1,SIZE*SIZE*sizeof(int));
    cudaMalloc((void**)&d_in_mat2,SIZE*SIZE*sizeof(int));
    cudaMalloc((void**)&d_out_result,SIZE*SIZE*sizeof(long));

    // Copy the contents to gpu
    cudaMemcpy(d_in_mat1,mat1,SIZE*SIZE*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(d_in_mat2,mat2,SIZE*SIZE*sizeof(int),cudaMemcpyHostToDevice);

    // invoke the kernel function
    
    dim3 threadsPerBlock(SIZE, SIZE);
    dim3 blocksPerGrid(1, 1);
    
    if(SIZE*SIZE > 1024){
        threadsPerBlock.x = 1024;
        threadsPerBlock.y = 1024;
        blocksPerGrid.x = ceil(double(SIZE)/double(threadsPerBlock.x));
        blocksPerGrid.y = ceil(double(SIZE)/double(threadsPerBlock.y));
    }

    clock_t startTime = clock();
    // mul<<<blocksPerGrid,threadsPerBlock>>>(d_in_mat1,d_in_mat2,d_out_result);
    mul<<<blocksPerGrid, threadsPerBlock>>>(d_in_mat1,d_in_mat2,d_out_result);
    clock_t endTime = clock();
    printf("\n\nTime for GPU: %f",(float)(endTime-startTime)/CLOCKS_PER_SEC);

    // cpy the result back 
    cudaMemcpy(result,d_out_result,SIZE*SIZE*sizeof(long),cudaMemcpyDeviceToHost);
    printf("\nres GPU: %ld", result[0][0]);

    // sequential code
    startTime = clock();
    for(int i = 0 ; i < SIZE ; i++){
        for(int j = 0 ; j < SIZE ; j++){
            result[i][j] = 0;
            for(int k = 0 ; k < SIZE ; k++)
               result[i][j] += mat1[i][k]*mat2[k][j];
        }
    }
    printf("\nres seq: %ld", result[0][0]);
    endTime = clock();
    printf("\n\nTime for sequential: %f",(float)(endTime-startTime)/CLOCKS_PER_SEC);
    // print result
    // for(int i = 0 ; i < SIZE ; i++){
    //     cout<<result[i]<<" ";
    // }
    
    return 0;
}