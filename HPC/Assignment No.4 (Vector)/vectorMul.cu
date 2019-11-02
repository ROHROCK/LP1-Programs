#include<iostream>
#include<time.h>
#define SIZE 1000
using namespace std;

__global__ void mul(int *vect , int (*mat)[SIZE][SIZE] , long *res){
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    res[i] = 0;
    for(int j = 0 ; j < SIZE ; j++)
        res[i] += vect[j]* (*mat)[j][i];  
}

int main(){
    int vect[SIZE];
    int mat[SIZE][SIZE];
    long result[SIZE];
    cudaEvent_t gpu_start,gpu_stop;
    float gpu_elapsed_time;

    // pointer to gpu location
    int *d_in_vector,(*d_in_mat)[SIZE][SIZE];
    long *d_out_result;

    // intialize
    for(int i = 0 ; i < SIZE ; i++){
        vect[i] = i;
        for(int j = 0 ; j < SIZE ; j++){
            mat[i][j] = i;
        }
    }

    // Allocate memory to gpu
    cudaMalloc((void**)&d_in_vector,SIZE*sizeof(int));
    cudaMalloc((void**)&d_in_mat,SIZE*SIZE*sizeof(int));
    cudaMalloc((void**)&d_out_result,SIZE*sizeof(long));

    // Copy the contents to gpu
    cudaMemcpy(d_in_vector,vect,SIZE*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(d_in_mat,mat,SIZE*SIZE*sizeof(int),cudaMemcpyHostToDevice);

    // Start record for gpu_start
    cudaEventCreate(&gpu_start);
    cudaEventCreate(&gpu_stop);
    cudaEventRecord(gpu_start,0);

    // invoke the kernel function
    int blk = SIZE/1024;
    mul<<<blk+1,1024>>>(d_in_vector,d_in_mat,d_out_result);
    // cpy the result back 
    cudaMemcpy(result,d_out_result,SIZE*sizeof(long),cudaMemcpyDeviceToHost);
    
    cudaEventRecord(gpu_stop,0);
    cudaEventSynchronize(gpu_stop);
    cudaEventElapsedTime(&gpu_elapsed_time,gpu_start,gpu_stop);
    cudaEventDestroy(gpu_start);
    cudaEventDestroy(gpu_stop);

    cout<<"The time taken by GPU is :"<<gpu_elapsed_time<<endl;
    
    
    // sequential code
    clock_t startTime = clock();
    for(int i = 0 ; i < SIZE ; i++){
        result[i] = 0;
        for(int j = 0 ; j < SIZE ; j++)
            result[i] += vect[j]*mat[j][i];  
    }
    clock_t endTime = clock();
    printf("\n\nTime for sequential: %.3f",(float)(endTime-startTime)/CLOCKS_PER_SEC);
    // print result
    // for(int i = 0 ; i < SIZE ; i++){
    //     cout<<result[i]<<" ";
    // }
    
    return 0;
}