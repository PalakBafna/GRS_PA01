#!/bin/bash

# Performance Analysis Script
# Calculates additional metrics from CSV data

CSV_FILE="MT25033_Part_D_CSV.csv"

if [ ! -f "$CSV_FILE" ]; then
    echo "Error: $CSV_FILE not found. Run Part D tests first."
    exit 1
fi

echo "================================================"
echo "  Advanced Performance Analysis"
echo "  Roll Number: MT25033"
echo "================================================"
echo ""

# Analysis 1: Calculate average execution time per worker type
echo "1. Average Execution Time by Worker Type"
echo "----------------------------------------"
for worker in cpu mem io; do
    for prog in programA programB; do
        avg=$(awk -F, -v prog="$prog" -v work="$worker" \
            'NR>1 && $1==prog && $2==work {sum+=$5; count++} END {if(count>0) printf "%.4f", sum/count; else print "N/A"}' \
            "$CSV_FILE")
        echo "$prog - $worker: $avg seconds"
    done
done
echo ""

# Analysis 2: CPU efficiency
echo "2. CPU Efficiency Analysis"
echo "----------------------------------------"
for worker in cpu mem io; do
    echo "Worker: $worker"
    for prog in programA programB; do
        avg_cpu=$(awk -F, -v prog="$prog" -v work="$worker" \
            'NR>1 && $1==prog && $2==work {sum+=$4; count++} END {if(count>0) printf "%.2f", sum/count; else print "N/A"}' \
            "$CSV_FILE")
        echo "  $prog: $avg_cpu%"
    done
    echo ""
done

# Analysis 3: Overhead calculation (time increase per additional worker)
echo "3. Overhead per Additional Worker"
echo "----------------------------------------"
for worker in cpu mem io; do
    echo "Worker: $worker"
    
    # Processes overhead
    time_2=$(awk -F, -v prog="programA" -v work="$worker" \
        'NR>1 && $1==prog && $2==work && $3==2 {print $5}' "$CSV_FILE")
    time_5=$(awk -F, -v prog="programA" -v work="$worker" \
        'NR>1 && $1==prog && $2==work && $3==5 {print $5}' "$CSV_FILE")
    
    if [ -n "$time_2" ] && [ -n "$time_5" ]; then
        overhead=$(echo "scale=4; ($time_5 - $time_2) / 3" | bc)
        echo "  Processes: $overhead sec/worker"
    fi
    
    # Threads overhead
    time_2=$(awk -F, -v prog="programB" -v work="$worker" \
        'NR>1 && $1==prog && $2==work && $3==2 {print $5}' "$CSV_FILE")
    time_8=$(awk -F, -v prog="programB" -v work="$worker" \
        'NR>1 && $1==prog && $2==work && $3==8 {print $5}' "$CSV_FILE")
    
    if [ -n "$time_2" ] && [ -n "$time_8" ]; then
        overhead=$(echo "scale=4; ($time_8 - $time_2) / 6" | bc)
        echo "  Threads: $overhead sec/worker"
    fi
    echo ""
done

# Analysis 4: Best and worst performers
echo "4. Performance Winners"
echo "----------------------------------------"
echo "Fastest execution (overall):"
awk -F, 'NR>1 {print $1","$2","$3","$5}' "$CSV_FILE" | sort -t, -k4 -n | head -1 | \
    awk -F, '{printf "  %s with %s worker (%s count): %.4f seconds\n", $1, $2, $3, $4}'

echo ""
echo "Most CPU efficient:"
awk -F, 'NR>1 {print $1","$2","$3","$4}' "$CSV_FILE" | sort -t, -k4 -nr | head -1 | \
    awk -F, '{printf "  %s with %s worker (%s count): %s%% CPU\n", $1, $2, $3, $4}'

echo ""
echo "================================================"

# Analysis 5: Speedup and Efficiency Metrics
echo ""
echo "5. Speedup and Efficiency Analysis"
echo "================================================"
echo ""

calculate_metrics() {
    PROG=$1
    WORKER=$2
    PROG_NAME=$3
    
    echo "[$PROG_NAME - ${WORKER^^} Worker]"
    echo "----------------------------------------"
    
    # Get baseline (count=2) time
    BASELINE=$(awk -F, -v prog="$PROG" -v work="$WORKER" \
        'NR>1 && $1==prog && $2==work && $3==2 {print $5}' "$CSV_FILE")
    
    if [ -z "$BASELINE" ]; then
        echo "  No data available"
        echo ""
        return
    fi
    
    echo "  Baseline (n=2): ${BASELINE}s"
    printf "  %-6s %-10s %-10s %-12s %-10s\n" "Count" "Time(s)" "Speedup" "Efficiency%" "CPU%"
    printf "  %-6s %-10s %-10s %-12s %-10s\n" "------" "----------" "----------" "------------" "----------"
    
    awk -F, -v prog="$PROG" -v work="$WORKER" -v base="$BASELINE" \
        'NR>1 && $1==prog && $2==work {
            speedup = base / $5
            efficiency = (speedup / $3) * 100
            printf "  %-6s %-10.4f %-10.2f %-12.1f %-10s\n", $3, $5, speedup, efficiency, $4
        }' "$CSV_FILE"
    echo ""
}

# Analyze all combinations
calculate_metrics "programA" "cpu" "Processes"
calculate_metrics "programA" "mem" "Processes"
calculate_metrics "programA" "io" "Processes"

calculate_metrics "programB" "cpu" "Threads"
calculate_metrics "programB" "mem" "Threads"
calculate_metrics "programB" "io" "Threads"

echo "================================================"
echo "6. Process vs Thread Comparison (at Count=5)"
echo "================================================"
echo ""

for worker in cpu mem io; do
    PROC_TIME=$(awk -F, -v prog="programA" -v work="$worker" \
        'NR>1 && $1==prog && $2==work && $3==5 {print $5}' "$CSV_FILE")
    THREAD_TIME=$(awk -F, -v prog="programB" -v work="$worker" \
        'NR>1 && $1==prog && $2==work && $3==5 {print $5}' "$CSV_FILE")
    
    if [ -n "$PROC_TIME" ] && [ -n "$THREAD_TIME" ]; then
        ADVANTAGE=$(echo "scale=1; (($PROC_TIME - $THREAD_TIME) / $PROC_TIME) * 100" | bc)
        
        echo -n "${worker^^} Worker: "
        if [ $(echo "$ADVANTAGE > 0" | bc) = "1" ]; then
            echo "Threads are ${ADVANTAGE}% faster (Process: ${PROC_TIME}s, Thread: ${THREAD_TIME}s)"
        else
            ADVANTAGE=$(echo "scale=1; -1 * $ADVANTAGE" | bc)
            echo "Processes are ${ADVANTAGE}% faster (Process: ${PROC_TIME}s, Thread: ${THREAD_TIME}s)"
        fi
    fi
done

echo ""
echo "================================================"
echo "7. Key Insights for Report"
echo "================================================"
echo ""
echo "INTERPRETATION GUIDE:"
echo ""
echo "Speedup:"
echo "  - Ideal: Linear (n workers = n× speedup)"
echo "  - Reality: Sub-linear due to overhead"
echo "  - Good: >0.7n for n workers"
echo ""
echo "Efficiency:"
echo "  - >80%: Excellent scalability"
echo "  - 60-80%: Good scalability"
echo "  - <60%: Poor scalability, overhead dominates"
echo ""
echo "Expected CPU Patterns:"
echo "  - CPU worker: 95-100% (computation bound)"
echo "  - Memory worker: 70-90% (memory bandwidth bound)"
echo "  - I/O worker: 30-60% (I/O wait time)"
echo ""
echo "Scalability Expectations:"
echo "  - CPU: Should scale well (near-linear)"
echo "  - Memory: Moderate (limited by bandwidth)"
echo "  - I/O: Poor (disk serialization bottleneck)"
echo ""
echo "================================================"
echo "Analysis complete! Use these metrics in your report."
echo "================================================"
