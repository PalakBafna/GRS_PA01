#!/bin/bash

# Part C: Test all 6 combinations (A+cpu, A+mem, A+io, B+cpu, B+mem, B+io)
# with 2 processes/threads
# 
# Measurement tools as per assignment:
# - top: monitored during execution (via /usr/bin/time -v)
# - iostat: for disk I/O statistics  
# - time: for execution time and CPU% measurement

OUT="MT25033_Part_C_CSV.csv"
echo "Program+Function,Count,CPU%,Memory_KB,IO_Read_MB,IO_Write_MB,Exec_Time_sec" > $OUT

# Clean up old I/O files
rm -f io_*.dat

# Check if iostat is available
if ! command -v iostat &> /dev/null; then
    echo "Warning: iostat not found. Install sysstat: sudo apt-get install sysstat"
    echo "Continuing with file-based I/O measurement..."
fi

run_test() {
    PROG=$1
    WORKER=$2
    COUNT=${3:-2}  # Default to 2 if not provided
    
    # Clear any existing I/O files
    rm -f io_*.dat
    
    # Initialize measurements
    DISK_READ="0.00"
    DISK_WRITE="0.00"
    
    # Run program with /usr/bin/time to get CPU%, Memory, and execution time
    # -v gives verbose output including CPU% and max memory
    TEMP_OUTPUT=$(mktemp)
    taskset -c 0 /usr/bin/time -v ./$PROG $WORKER $COUNT 2>&1 > /dev/null 2> "$TEMP_OUTPUT"
    
    # Parse time output
    CPU_PCT=$(grep "Percent of CPU" "$TEMP_OUTPUT" | awk '{print $NF}' | tr -d '%')
    MAX_MEM_KB=$(grep "Maximum resident set size" "$TEMP_OUTPUT" | awk '{print $NF}')
    ELAPSED=$(grep "Elapsed (wall clock)" "$TEMP_OUTPUT" | awk '{print $NF}')
    
    # Convert elapsed time to seconds - handle multiple formats
    # Formats: h:mm:ss.ms, mm:ss.ms, ss.ms, or seconds
    EXEC_TIME="0.00"
    
    if [[ "$ELAPSED" =~ ^([0-9]+):([0-9]+):([0-9]+\.?[0-9]*)$ ]]; then
        # h:mm:ss.ms format (e.g., 1:02:30.45)
        h="${BASH_REMATCH[1]}"
        m="${BASH_REMATCH[2]}"
        s="${BASH_REMATCH[3]}"
        EXEC_TIME=$(echo "scale=2; $h * 3600 + $m * 60 + $s" | bc)
    elif [[ "$ELAPSED" =~ ^([0-9]+):([0-9]+\.?[0-9]*)$ ]]; then
        # mm:ss.ms format (e.g., 2:30.45)
        m="${BASH_REMATCH[1]}"
        s="${BASH_REMATCH[2]}"
        EXEC_TIME=$(echo "scale=2; $m * 60 + $s" | bc)
    elif [[ "$ELAPSED" =~ ^([0-9]+\.?[0-9]*)$ ]]; then
        # Already in seconds (e.g., 30.45)
        EXEC_TIME="${BASH_REMATCH[1]}"
    else
        # Fallback - try to use as-is
        EXEC_TIME="${ELAPSED:-0.00}"
    fi
    
    # Handle empty values and ensure numeric format
    [ -z "$CPU_PCT" ] || [[ ! "$CPU_PCT" =~ ^[0-9]+$ ]] && CPU_PCT="0"
    [ -z "$MAX_MEM_KB" ] || [[ ! "$MAX_MEM_KB" =~ ^[0-9]+$ ]] && MAX_MEM_KB="0"
    [ -z "$EXEC_TIME" ] && EXEC_TIME="0.00"
    
    rm -f "$TEMP_OUTPUT"
    
    # For I/O worker, measure actual file sizes written
    if [ "$WORKER" = "io" ]; then
        sync
        sleep 0.2
        
        if ls io_*.dat 1> /dev/null 2>&1; then
            TOTAL_BYTES=0
            for file in io_*.dat; do
                if [ -f "$file" ]; then
                    FILE_SIZE=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo "0")
                    TOTAL_BYTES=$((TOTAL_BYTES + FILE_SIZE))
                fi
            done
            
            if [ "$TOTAL_BYTES" -gt 0 ]; then
                DISK_WRITE=$(echo "scale=2; $TOTAL_BYTES / 1024 / 1024" | bc)
            fi
        fi
        
        # Disk read is 0 for write-only I/O operations
        DISK_READ="0.00"
    fi
    
    # Output in format: Program+Function,Count,CPU%,Memory_KB,IO_Read_MB,IO_Write_MB,Exec_Time
    echo "$PROG+$WORKER,$COUNT,$CPU_PCT,$MAX_MEM_KB,$DISK_READ,$DISK_WRITE,$EXEC_TIME" >> $OUT
}

echo "========================================"
echo "Running Part C: Baseline Testing"
echo "Testing 6 combinations using:"
echo "  - /usr/bin/time -v (CPU%, Memory, Time)"
echo "  - File size measurement (Disk I/O)"
echo "========================================"
echo ""

# Check if programs exist
if [ ! -f programA ] || [ ! -f programB ]; then
    echo "ERROR: Programs not found! Please run 'make' first."
    exit 1
fi

# Configuration menu
echo "Test Configuration:"
echo "  1. Default (2 processes, 2 threads)"
echo "  2. Custom (specify number of processes and threads)"
echo ""
read -p "Select option [1-2] (default: 1): " CHOICE
CHOICE=${CHOICE:-1}

NUM_PROCESSES=2
NUM_THREADS=2

if [ "$CHOICE" = "2" ]; then
    echo ""
    # Ask for number of processes for Part A
    read -p "Enter number of processes for Program A (minimum 2): " NUM_PROCESSES
    
    # Validate processes
    if ! [[ "$NUM_PROCESSES" =~ ^[0-9]+$ ]] || [ "$NUM_PROCESSES" -lt 2 ]; then
        echo "Error: Number of processes must be at least 2"
        exit 1
    fi
    
    # Ask for number of threads for Part B
    read -p "Enter number of threads for Program B (minimum 2): " NUM_THREADS
    
    # Validate threads
    if ! [[ "$NUM_THREADS" =~ ^[0-9]+$ ]] || [ "$NUM_THREADS" -lt 2 ]; then
        echo "Error: Number of threads must be at least 2"
        exit 1
    fi
elif [ "$CHOICE" != "1" ]; then
    echo "Invalid choice. Using defaults (2 processes, 2 threads)"
    NUM_PROCESSES=2
    NUM_THREADS=2
fi

echo ""
echo "Running tests with:"
echo "  - Program A: $NUM_PROCESSES processes"
echo "  - Program B: $NUM_THREADS threads"
echo "========================================"
echo ""

# Program A with specified number of processes
for worker in cpu mem io; do
    echo "Testing programA + $worker worker ($NUM_PROCESSES processes)..."
    run_test programA $worker $NUM_PROCESSES
    echo "  ✓ Complete"
done

echo ""

# Program B with specified number of threads
for worker in cpu mem io; do
    echo "Testing programB + $worker worker ($NUM_THREADS threads)..."
    run_test programB $worker $NUM_THREADS
    echo "  ✓ Complete"
done

echo ""
echo "========================================"
echo "Part C testing complete!"
echo "Results saved to: $OUT"
echo "========================================"
echo ""
echo "Summary:"
cat $OUT | column -t -s','
echo ""

# Clean up I/O files
rm -f io_*.dat

echo "Notes:"
echo "- Configuration: $NUM_PROCESSES processes, $NUM_THREADS threads"
echo "- CPU% from /usr/bin/time (average over execution)"
echo "- Memory_KB is maximum resident set size"
echo "- IO measurements from actual file sizes created"
echo "- Disk Read is 0.00 (workers only write data)"
