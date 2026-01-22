# PA01: Processes and Threads
**Roll Number:** MT25033  
**Course:** Graduate Research Seminar (GRS)  
**Deadline:** January 23, 2026

---

## Overview

This assignment implements and analyzes the performance characteristics of CPU-intensive, memory-intensive, and I/O-intensive workloads using both process-based (fork) and thread-based (pthread) parallelism in C.

---

## Assignment Structure

### Part A: Process and Thread Creation
- **Program A** (`MT25033_Part_A_Program_A.c`): Creates child processes using `fork()`
- **Program B** (`MT25033_Part_A_Program_B.c`): Creates threads using `pthread`

### Part B: Worker Functions
Three worker functions implemented in `MT25033_Part_B_Workers.c`:
- **cpu_worker**: CPU-intensive computation (nested loops with arithmetic operations)
- **mem_worker**: Memory-intensive operations (allocating and accessing 256MB of memory)
- **io_worker**: I/O-intensive operations (writing data to disk files)

Each worker runs for **3000 iterations** (last digit of roll number 3 × 1000).

### Part C: Baseline Performance Testing
Tests all 6 combinations with 2 processes/threads:
- programA + cpu
- programA + mem
- programA + io
- programB + cpu
- programB + mem
- programB + io

Measures: CPU usage, execution time, disk read/write statistics

### Part D: Scalability Analysis
Tests varying numbers of processes/threads:
- **Program A**: 2, 3, 4, 5 processes
- **Program B**: 2, 3, 4, 5, 6, 7, 8 threads

Measures: CPU usage, execution time

---

## Files Included

### Source Code
- `MT25033_Part_A_Program_A.c` - Process-based implementation
- `MT25033_Part_A_Program_B.c` - Thread-based implementation
- `MT25033_Part_B_Workers.c` - Worker function implementations
- `MT25033_Part_B_Workers.h` - Worker function declarations

### Scripts
- `MT25033_Part_C_shell.sh` - Automation script for Part C
- `MT25033_Part_D_shell.sh` - Automation script for Part D

### Plotting Scripts
- `MT25033_Part_D_All_plot.gp` - Generate all plots
- `MT25033_Part_D_CPU_plot.gp` - CPU-specific plots
- `MT25033_Part_D_MEM_plot.gp` - Memory-specific plots
- `MT25033_Part_D_IO_plot.gp` - I/O-specific plots

### Data Files
- `MT25033_Part_C_CSV.csv` - Part C results
- `MT25033_Part_D_CSV.csv` - Part D results

### Documentation
- `README.md` - This file
- `Makefile` - Build and test automation
- `MT25033_Report.pdf` - Complete analysis and results (to be generated)

---

## Prerequisites

### Required Tools
- GCC compiler with pthread support
- GNU Make
- Bash shell (use WSL on Windows)
- `top` command
- `iostat` command (install via `sudo apt-get install sysstat`)
- `time` command (`/usr/bin/time`)
- `taskset` command
- `gnuplot` (for generating plots)

### Installation (Ubuntu/WSL)
```bash
sudo apt-get update
sudo apt-get install build-essential sysstat gnuplot bc
```

---

## Compilation

### Build All Programs
```bash
make
```

### Build Individual Programs
```bash
make programA    # Build Program A only
make programB    # Build Program B only
```

### View Build Options
```bash
make help
```

---

## Usage

### Running Programs Manually

#### Program A (Processes)
```bash
./programA <worker_type> <num_processes>

# Examples:
./programA cpu 2    # Run CPU worker with 2 processes
./programA mem 3    # Run memory worker with 3 processes
./programA io 4     # Run I/O worker with 4 processes
```

#### Program B (Threads)
```bash
./programB <worker_type> <num_threads>

# Examples:
./programB cpu 2    # Run CPU worker with 2 threads
./programB mem 5    # Run memory worker with 5 threads
./programB io 8     # Run I/O worker with 8 threads
```

### Running Automated Tests

#### Part C Tests
```bash
make test_c
# OR
bash MT25033_Part_C_shell.sh
```

#### Part D Tests
```bash
make test_d
# OR
bash MT25033_Part_D_shell.sh
```

#### Generate Plots (Part D)
```bash
make plot_d
```

---

## Implementation Details

### Program A: Fork-based Parallelism
- Creates specified number of child processes using `fork()`
- Each child process executes the selected worker function
- Parent waits for all children to complete using `wait()`
- Each process has its own memory space (no shared memory)

### Program B: Pthread-based Parallelism
- Creates specified number of threads using `pthread_create()`
- Each thread executes the selected worker function
- Main thread waits for all threads using `pthread_join()`
- All threads share the same memory space

### Worker Functions

#### CPU Worker
- Performs intensive arithmetic calculations
- Nested loops computing sum of squares
- Minimal memory and I/O operations
- Expected high CPU usage (~90-100%)

#### Memory Worker
- Allocates 256MB of memory per process/thread
- Repeatedly accesses memory locations
- Tests memory bandwidth and cache performance
- Expected high CPU usage and memory activity

#### I/O Worker
- Creates unique file per process/thread (based on PID)
- Writes 4KB blocks of data repeatedly
- Uses `fflush()` to ensure data is written to disk
- Expected low CPU usage, high I/O wait time

---

## Performance Monitoring

### CPU Pinning
All tests use `taskset -c 0` to pin execution to CPU core 0 for consistent measurements.

### Metrics Collected

#### Part C
- **CPU%**: Average CPU utilization (from `time` command)
- **Exec_Time**: Total execution time in seconds
- **Disk_Read**: Disk read operations (kB/s)
- **Disk_Write**: Disk write operations (kB/s)

#### Part D
- **CPU%**: Average CPU utilization
- **Exec_Time**: Total execution time in seconds
- **Count**: Number of processes/threads

---

## Expected Results

### Part C Analysis

**CPU-intensive tasks:**
- High CPU% (80-100%)
- Low disk I/O
- Similar performance for processes vs threads

**Memory-intensive tasks:**
- High CPU% (90-100%)
- Minimal disk I/O
- Threads may show slight overhead due to shared memory contention

**I/O-intensive tasks:**
- Low CPU% (5-20%)
- High disk write operations
- Processes may show better isolation

### Part D Analysis

**Scalability with Processes (Program A):**
- Higher overhead per process
- Better isolation
- Linear increase in execution time with process count

**Scalability with Threads (Program B):**
- Lower overhead per thread
- Shared resources
- Better scaling up to the number of CPU cores

---

## Cleaning Up

### Remove Executables Only
```bash
make clean
```

### Remove All Generated Files (executables, CSVs, plots)
```bash
make cleanall
```

---

## Troubleshooting

### Permission Issues
If you get permission errors with scripts:
```bash
chmod +x MT25033_Part_C_shell.sh
chmod +x MT25033_Part_D_shell.sh
```

### iostat Command Not Found
```bash
sudo apt-get install sysstat
```

### gnuplot Not Found
```bash
sudo apt-get install gnuplot
```

### Programs Hang or Run Too Long
- Reduce the COUNT value in worker functions
- Verify loop counts are correct (should be 3000)

### Disk Space Issues
The I/O worker creates temporary files. Clean them up:
```bash
rm -f io_*.dat
```

---

## Key Findings & Analysis Guide

### Understanding the Design

**Why Different Process/Thread Ranges?**
- **Processes (2-5)**: Each process has its own memory space, consuming more system resources. Testing fewer processes reflects realistic usage scenarios where process overhead becomes significant.
- **Threads (2-8)**: Threads share memory space within a process, making them lighter. Testing more threads demonstrates their scalability advantage in multi-threaded applications.


### Part C Analysis (Baseline Testing)
When analyzing the 6 combinations, consider:

1. **CPU Usage Patterns**
   - **CPU-intensive workers**: Should show 90-100% CPU usage
   - **Memory-intensive workers**: May show lower CPU% due to memory bottlenecks
   - **I/O-intensive workers**: Typically shows 30-70% CPU due to I/O wait time

2. **Execution Time Comparison**
   - Which is faster: processes or threads? Why?
   - Which worker type takes longest? (Hint: I/O operations are typically slowest)

3. **Resource Efficiency**
   - Do threads complete faster than processes for the same workload?
   - Calculate: `Efficiency = (Process_Time - Thread_Time) / Process_Time × 100%`

### Part D Analysis (Scalability)
When analyzing scalability plots, examine:

1. **Speedup Analysis**
   - Calculate: `Speedup(n) = Time(2) / Time(n)`
   - **Ideal speedup**: Linear (doubling workers halves time)
   - **Real speedup**: Sub-linear due to overhead and contention

2. **Efficiency Metrics**
   - Calculate: `Efficiency(n) = Speedup(n) / n × 100%`
   - **Above 80%**: Excellent scalability
   - **60-80%**: Good scalability
   - **Below 60%**: Poor scalability, overhead dominates

3. **Worker-Specific Observations**
   - **CPU workers**: Should scale well (CPU-bound, minimal contention)
   - **Memory workers**: May show diminishing returns (memory bandwidth limits)
   - **I/O workers**: Poor scaling (disk I/O is serialized, creates bottleneck)

4. **Process vs Thread Performance**
   - At what count do threads significantly outperform processes?
   - **Crossover point**: Number where thread advantage becomes clear
   - **Overhead impact**: Process creation/context switching vs thread synchronization

### Expected Patterns

**Best Case Scenarios:**
- CPU-intensive with threads → Near-linear scaling up to CPU core count
- Memory-intensive with low counts → Good performance before memory bandwidth saturation
- I/O-intensive → Minimal improvement (I/O is the bottleneck, not parallelism)

**Worst Case Scenarios:**
- Many processes with I/O → High overhead, disk contention
- Memory-intensive at high counts → Memory bandwidth exhaustion
- Beyond physical CPU cores → Context switching overhead increases

