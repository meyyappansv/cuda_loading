#include <cuda_runtime.h>
#include <iostream>

// Example kernel (can be any kernel you want to analyze)
__global__ void myKernel() {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    // Perform some dummy work
    float value = 0.0f;
    for (int i = 0; i < 100; i++) {
        value += sinf(idx) * cosf(idx);
    }
}

int main() {
    // Set device (if you have multiple GPUs, choose appropriately)
    int device = 0;
    cudaSetDevice(device);

    // Get device properties for additional information
    cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp, device);
    std::cout << "Device: " << deviceProp.name << std::endl;

    // Set desired block size for occupancy query
    int blockSize = 256;  // You can adjust this based on your kernel design.
    int dynamicSMemBytes = 0; // Set to the amount of dynamic shared memory per block if used

    int maxActiveBlocks = 0;
    cudaError_t err = cudaOccupancyMaxActiveBlocksPerMultiprocessor(&maxActiveBlocks, myKernel, blockSize, dynamicSMemBytes);
    if (err != cudaSuccess) {
        std::cerr << "Error: " << cudaGetErrorString(err) << std::endl;
        return 1;
    }

    std::cout << "Max active blocks per SM: " << maxActiveBlocks << std::endl;

    return 0;
}
