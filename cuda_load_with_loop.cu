//This is the script that is being currently used to generate load
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
    int maxThreadsPerSM = prop.maxThreadsPerMultiProcessor; // Threads per SM
    size_t total_mem;
    size_t free_mem;

    cudaMemGetInfo(&free_mem, &total_mem);

    // Compute load based on available SMs
    int threads_per_block = 1024;  // Max CUDA threads per block
    int blocks = numSMs * (core_percent / 100.0) * 4; // 4 blocks per SM for full utilization
    int iterations = core_percent * 6000; // More iterations = higher compute load
    //1000 --> gives you 75% utilization
    //7000 -- gives you around 98% utilization
    //6000 -- gives you around 95% utilization


    // Allocate memory dynamically
    size_t mem_to_allocate = (mem_percent / 100.0) * total_mem;
    float *d_mem;
    cudaMalloc((void**)&d_mem, mem_to_allocate);  // Load memory

    std::cout << "Launching GPU Load: " << core_percent << "% Core, " << mem_percent << "% Memory\n";
    std::cout << "Using " << blocks << " Blocks, " << threads_per_block << " Threads per Block\n";
    std::cout << "Allocating " << mem_to_allocate / (1024.0 * 1024) << " MB GPU Memory\n";

    auto start = std::chrono::high_resolution_clock::now();

    // Load GPU with compute & memory for infinite duration
    while (true) {
        gpu_compute_kernel<<<blocks, threads_per_block>>>(iterations);
        cudaDeviceSynchronize();
        std::this_thread::sleep_for(std::chrono::milliseconds(10));  // Adjust to control GPU utilization
    }

    cudaFree(d_mem);  // Free memory
}

int main() {
    load_gpu(50.0, 75.0);  // Load 50% cores, 75% memory for 60 seconds
    return 0;
}
