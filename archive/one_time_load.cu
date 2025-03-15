#include <cuda_runtime.h>
#include <iostream>
#include <chrono>
#include <thread>

// CUDA kernel to load GPU cores
__global__ void gpu_compute_kernel(int iterations) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    float x = 0.0f;
    for (int i = 0; i < iterations; ++i) {
        x += sinf(x) * cosf(x);  // Dummy compute workload
    }
}

// Function to dynamically detect GPU cores & memory
void load_gpu(float core_percent, float mem_percent) {
    // Get GPU properties
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);

    int numSMs = prop.multiProcessorCount; // Total number of SMs
    std::cout << "Number of SMs: " << numSMs << "\n";
    int maxThreadsPerSM = prop.maxThreadsPerMultiProcessor; // Threads per SM. ??? This is never used
    size_t total_mem;
    size_t free_mem;

    cudaMemGetInfo(&free_mem, &total_mem);

    // Compute load based on available SMs
    int threads_per_block = 1024;  // Max CUDA threads per block
    int blocks = numSMs * (core_percent / 100.0) * 8; // 4 blocks per SM for full utilization
    std::cout << "Number of Blocks: " << blocks << "\n";
    int iterations = core_percent * 10000; // More iterations = higher compute load

    // Allocate memory dynamically
    size_t mem_to_allocate = (mem_percent / 100.0) * total_mem;
    float *d_mem;
    cudaMalloc((void**)&d_mem, mem_to_allocate);  // Load memory

    std::cout << "Launching GPU Load: " << core_percent << "% Core, " << mem_percent << "% Memory\n";
    std::cout << "Using " << blocks << " Blocks, " << threads_per_block << " Threads per Block\n";
    std::cout << "Allocating " << mem_to_allocate / (1024.0 * 1024) << " MB GPU Memory\n";
    gpu_compute_kernel<<<blocks, threads_per_block>>>(iterations);
    cudaDeviceSynchronize();
    cudaFree(d_mem);  // Free memory
}

int main() {
    load_gpu(75.0, 75.0);  // Load 50% cores, 75% memory for 60 seconds
    return 0;
}
