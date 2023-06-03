#include <stdio.h>
#include <cuda_runtime.h>
#define N 1024

__global__ void decrypt(char* data, int size);

int main(int argc, char** argv) {
   
    if (argc != 2) {
        printf("Error: Incorrect number of arguments.\n");
        return 1;
    }

   
    FILE* file = fopen(argv[1], "r");
    if (!file) {
        printf("File does not exist %s\n", argv[1]);
        return 1;
    }
    fseek(file, 0, SEEK_END);
    int size = ftell(file);
    fseek(file, 0, SEEK_SET);

 
    char* hostData = (char*)malloc(size);
    char* deviceData;
    cudaMalloc((void**)&deviceData, size);

    
    fread(hostData, 1, size, file);

    cudaMemcpy(deviceData, hostData, size, cudaMemcpyHostToDevice);

    int blocks = (size + N - 1) / N;
    decrypt<<<blocks, N>>>(deviceData, size);


    cudaMemcpy(hostData, deviceData, size, cudaMemcpyDeviceToHost);
    cudaDeviceSynchronize(); 

    printf("Decoded data:\n%.*s", size, hostData);

    fclose(file);
    free(hostData);
    cudaFree(deviceData);

    exit(0);
}
__global__ void decrypt(char* data, int size) {
    int i = threadIdx.x + blockDim.x * blockIdx.x;
    if (i < size) {
        data[i] -= 1;
    }
}