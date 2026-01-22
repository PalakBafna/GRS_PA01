#!/bin/bash

# Part D: Test with varying numbers of processes/threads
# Program A: 2, 3, 4, 5 processes
# Program B: 2, 3, 4, 5, 6, 7, 8 threads

OUT="MT25033_Part_D_CSV.csv"
echo "Program,Worker,Count,Avg_CPU,Exec_Time" > $OUT

echo "========================================"
echo "Running Part D: Scalability Testing"
echo "========================================"
echo ""

# Check if programs exist
if [ ! -f programA ] || [ ! -f programB ]; then
    echo "ERROR: Programs not found! Please run 'make' first."
    exit 1
fi

# Clean up old I/O files
rm -f io_*.dat

run_test() {
    PROG=$1
    WORKER=$2
    COUNT=$3
    
    # Clear any old I/O files
    rm -f io_*.dat
    
    # Run program with time measurement, pinned to CPU 0
    TEMP_OUTPUT=$(mktemp)
    /usr/bin/time -v taskset -c 0 ./$PROG $WORKER $COUNT > /dev/null 2> "$TEMP_OUTPUT"
    
    # Extract execution time and CPU percentage
    EXEC_TIME=$(grep "Elapsed (wall clock)" "$TEMP_OUTPUT" | awk '{print $NF}')
    CPU_PCT=$(grep "Percent of CPU" "$TEMP_OUTPUT" | awk '{print $NF}' | tr -d '%')
    
    # Convert time to seconds (handle mm:ss format)
    if [[ "$EXEC_TIME" =~ ^([0-9]+):([0-9]+):([0-9]+\.?[0-9]*)$ ]]; then
        h="${BASH_REMATCH[1]}"
        m="${BASH_REMATCH[2]}"
        s="${BASH_REMATCH[3]}"
        EXEC_TIME=$(echo "scale=2; $h * 3600 + $m * 60 + $s" | bc)
    elif [[ "$EXEC_TIME" =~ ^([0-9]+):([0-9]+\.?[0-9]*)$ ]]; then
        m="${BASH_REMATCH[1]}"
        s="${BASH_REMATCH[2]}"
        EXEC_TIME=$(echo "scale=2; $m * 60 + $s" | bc)
    elif [[ "$EXEC_TIME" =~ ^([0-9]+\.?[0-9]*)$ ]]; then
        EXEC_TIME="${BASH_REMATCH[1]}"
    fi
    
    # Handle empty values
    [ -z "$CPU_PCT" ] && CPU_PCT="0"
    [ -z "$EXEC_TIME" ] && EXEC_TIME="0.00"
    
    rm -f "$TEMP_OUTPUT"
    
    echo "$PROG,$WORKER,$COUNT,$CPU_PCT,$EXEC_TIME" >> $OUT
}

echo "Testing Program A with varying process counts (2-5):"
echo "------------------------------------------------"

# Program A (processes: 2, 3, 4, 5)
TOTAL_TESTS=33  # 3 workers * (4 + 7) counts
CURRENT_TEST=0

for worker in cpu mem io; do
    echo ""
    echo "Worker: $worker"
    for n in 2 3 4 5; do
        ((CURRENT_TEST++))
        printf "  [%2d/%2d] Testing programA + %s worker with %d processes..." $CURRENT_TEST $TOTAL_TESTS $worker $n
        run_test programA $worker $n
        echo " ✓"
    done
done

echo ""
echo "Testing Program B with varying thread counts (2-8):"
echo "------------------------------------------------"

# Program B (threads: 2, 3, 4, 5, 6, 7, 8)
for worker in cpu mem io; do
    echo ""
    echo "Worker: $worker"
    for n in 2 3 4 5 6 7 8; do
        ((CURRENT_TEST++))
        printf "  [%2d/%2d] Testing programB + %s worker with %d threads..." $CURRENT_TEST $TOTAL_TESTS $worker $n
        run_test programB $worker $n
        echo " ✓"
    done
done

# Clean up I/O files
rm -f io_*.dat

echo ""
echo "========================================"
echo "Part D testing complete!"
echo "Results saved to: $OUT"
echo "========================================"
echo ""
echo "Summary:"
cat $OUT | column -t -s','
echo ""
echo "Total tests completed: $CURRENT_TEST"
echo ""
echo "Next steps:"
echo "  1. Generate plots: gnuplot MT25033_Part_D_plot.gp"
echo "  2. Or run: make plot_d"
