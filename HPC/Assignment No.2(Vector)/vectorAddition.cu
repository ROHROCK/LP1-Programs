#include<iostream>
#include<time.h>
#define SIZE 100000
using namespace std;

__global__ void addVect(int *vect1 ,int *vect2 , int *resultVect){
    int i = threadIdx.x + blockDim.x * blockIdx.x;
    // printf("Thread id == %d || Block Id == %d\n",threadIdx.x,blockDim.x);
    resultVect[i] = vect1[i] + vect2[i];
}

int main(){
    int *d_inVect1,*d_inVect2,*d_outResultVector;
    int vect1[SIZE],vect2[SIZE];
    int resultVect[SIZE];
    cudaEvent_t gpu_start,gpu_stop;
    float gpu_elapsed_time;
    // Initializing both the vectors
    for(int i = 0 ; i < SIZE ; i++){
        vect1[i] = i;
        vect2[i] = i;
    }
    // Parallel code

    // Allocate memory on GPU for 3 vectors
    cudaMalloc((void**)&d_inVect1,SIZE*(sizeof(int)));
    cudaMalloc((void**)&d_inVect2,SIZE*(sizeof(int)));
    cudaMalloc((void**)&d_outResultVector,SIZE*(sizeof(int)));

    // CPY the vector contents
    cudaMemcpy(d_inVect1,vect1,SIZE*sizeof(int),cudaMemcpyHostToDevice);
    cudaMemcpy(d_inVect2,vect2,SIZE*sizeof(int),cudaMemcpyHostToDevice);

    int blk = SIZE/1024;
    // Call the kernel
    clock_t startTime = clock();
    addVect<<<blk+1,1024>>>(d_inVect1,d_inVect2,d_outResultVector);
    clock_t endTime = clock();
    printf("\n\nTime for sequential: %.4f",(float)(endTime-startTime)/CLOCKS_PER_SEC);
    // cudaDeviceSynchronize();

    // Copy gpu mem to cpu mem
    cudaMemcpy(resultVect,d_outResultVector,SIZE*sizeof(int),cudaMemcpyDeviceToHost);


    cout<<"The time taken by GPU is :"<<gpu_elapsed_time<<endl;
   
    // for(int i = 0 ; i < SIZE ; i++){
    //     cout<<resultVect[i]<<" ";
    // }

    // Sequential code
    startTime = clock();
    int resultVect2[SIZE];
    for(int i = 0 ; i < SIZE ; i++){
        resultVect2[i] = vect1[i] * vect2[i];
    }
    // for(int i = 0 ; i < SIZE ; i++){
    //     cout<<resultVect2[i]<<" ";
    // }
    endTime = clock();
    printf("\n\nTime for sequential: %.4f",(float)(endTime-startTime)/CLOCKS_PER_SEC);

    return 0;
}