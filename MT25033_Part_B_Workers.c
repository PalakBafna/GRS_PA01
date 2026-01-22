#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

/*
 * mem_worker: Memory-intensive workload
 * 
 * Design rationale:
 * - Allocates 256MB to exceed typical L3 cache (~few MB), forcing memory access
 * - Stride of 64 bytes matches typical cache line size, ensuring cache misses
 * - Repeated access pattern stresses memory bandwidth, not computation
 * - This tests memory subsystem throughput, not CPU speed
 * 
 * Performance characteristics:
 * - Bottleneck: Memory bandwidth (RAM speed)
 * - Scalability: Limited by memory channels (typically 2-4 per CPU)
 * - Expected CPU%: 70-90% (CPU waits for memory more than pure computation)
 */
void mem_worker(int count) {
    size_t size =  1024 * 1024 * 256; // 256 MB - large enough to avoid cache
    
    printf("[PID %d] Starting memory-intensive workload...\n", getpid());
    printf("[PID %d] Allocating %zu MB of memory\n", getpid(), size / (1024 * 1024));
    
    char *store = malloc(size);
    if (!store) {
        fprintf(stderr, "[PID %d] Memory allocation failed!\n", getpid());
        exit(1);
    }

    printf("[PID %d] Memory allocated. Starting %d iterations...\n", getpid(), count);
    
    for (int j = 1; j <= count; j++) {
        // Access every 64 bytes (cache line size) to maximize memory traffic
        // This ensures each access likely requires fetching from main memory
        for (size_t i = 0; i < size; i += 64) {
            store[i] = (char)i;  // Write operation stresses memory bandwidth
        }
        
        // Show progress every 500 iterations
        if (j % 500 == 0) {
            printf("[PID %d] Memory worker progress: %d/%d iterations\n", getpid(), j, count);
        }
    }

    free(store);
    printf("[PID %d] Memory worker completed successfully!\n", getpid());
}

/*
 * io_worker: I/O-intensive workload
 * 
 * Design rationale:
 * - Writes 4KB blocks (typical filesystem page size) to force actual disk I/O
 * - fflush() after each write prevents OS buffering, ensuring synchronous I/O
 * - Each process writes to unique file (using PID) to avoid file lock contention
 * - Small buffer size (4KB) maximizes I/O syscall overhead vs. computation
 * 
 * Performance characteristics:
 * - Bottleneck: Disk I/O throughput (even SSD has ~100-500 MB/s limit)
 * - Scalability: Poor - disk I/O is serialized by OS/hardware controllers
 * - Expected CPU%: 30-60% (CPU mostly waits for I/O completion)
 * - Context switching: High (processes sleep during I/O wait)
 */
void io_worker(int count) {
    char fname[128];
    snprintf(fname, sizeof(fname), "io_%d.dat", getpid());

    printf("[PID %d] Starting I/O-intensive workload...\n", getpid());
    printf("[PID %d] Creating file: %s\n", getpid(), fname);
    
    FILE *fp = fopen(fname, "w");
    if (!fp) {
        fprintf(stderr, "[PID %d] File creation failed!\n", getpid());
        exit(1);
    }

    char buf[4096];
    memset(buf, 'A', sizeof(buf));

    printf("[PID %d] Writing %d blocks of 4KB...\n", getpid(), count);
    
    for (int i = 1; i <= count; i++) {
        fwrite(buf, sizeof(buf), 1, fp);
        fflush(fp);  // Critical: Force immediate disk write, prevent buffering
        
        // Show progress every 500 iterations
        if (i % 500 == 0) {
            printf("[PID %d] I/O worker progress: %d/%d blocks written\n", getpid(), i, count);
        }
    }

    fclose(fp);
    
    long total_bytes = (long)count * sizeof(buf);
    printf("[PID %d] I/O worker completed! Total written: %.2f MB\n", 
           getpid(), total_bytes / (1024.0 * 1024.0));
}

/*
 * cpu_worker: CPU-intensive workload
 * 
 * Design rationale:
 * - Nested loops create O(n²) computational complexity
 * - 'volatile' keyword prevents compiler optimization (ensures actual computation)
 * - Arithmetic operations (multiplication, addition) stress ALU (Arithmetic Logic Unit)
 * - No memory/I/O access - purely computational
 * 
 * Performance characteristics:
 * - Bottleneck: CPU speed (clock frequency, IPC)
 * - Scalability: Excellent (near-linear) up to number of physical CPU cores
 * - Expected CPU%: 95-100% (CPU constantly executing instructions)
 * - Best case for parallelism: No shared resources or contention
 */
void cpu_worker(int count) {
    printf("[PID %d] Starting CPU-intensive workload (%d iterations)...\n", getpid(), count);
    
    for (int i = 1; i <= count; i++) {
        volatile long sum = 0;  // volatile prevents compiler from optimizing away loop
        for (int j = 0; j < 10000; j++) {
            sum = sum +  j * j;  // Arithmetic operations keep CPU busy
        }
        
        // Show progress every 500 iterations
        if (i % 500 == 0) {
            printf("[PID %d] CPU worker progress: %d/%d iterations\n", getpid(), i, count);
        }
    }
    
    printf("[PID %d] CPU worker completed successfully!\n", getpid());
}
