#include<iostream>
#define SIZE 100

using namespace std;

void bubbleSort (int arr[SIZE]){
    cout<<"Before sorting: "<<endl;
    for(int i ; i < SIZE ; i++){
        cout<<arr[i]<<" ";
    }
    #pragma omp parallel for
    for(int i=0 ; i < SIZE ; i++){
        for(int j = 0 ; j < SIZE - i - 1; j++){
            if(arr[j] < arr[j+1]){
                int temp = arr[j];
                arr[j] = arr[j+1];
                arr[j+1] = temp;
            }
        }
    }
    cout<<"After sorting: "<<endl;
    for(int i ; i < SIZE ; i++){
        cout<<arr[i]<<" ";
    }
}
int main(){
    int arr[SIZE];
    for(int i = 0 ; i < SIZE ; i++){
        arr[i] = i;
    }
    bubbleSort(arr);
    return 0;
}