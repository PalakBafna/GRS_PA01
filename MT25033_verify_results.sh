#!/bin/bash

# Verification script for Part C results
# Checks if all tests completed and data is reasonable

echo "================================================"
echo "Part C Results Verification"
echo "================================================"
echo ""

if [ ! -f MT25033_Part_C_CSV.csv ]; then
    echo "ERROR: MT25033_Part_C_CSV.csv not found!"
    exit 1
fi

# Count number of data rows (should be 6: programA/B x cpu/mem/io)
DATA_ROWS=$(tail -n +2 MT25033_Part_C_CSV.csv | wc -l)

echo "Number of test results: $DATA_ROWS/6"
if [ "$DATA_ROWS" -ne 6 ]; then
    echo "⚠️  WARNING: Expected 6 results, found $DATA_ROWS"
    echo "   Tests may still be running. Please wait..."
    echo ""
fi

echo ""
echo "Current Results:"
echo "================================================"
column -t -s',' MT25033_Part_C_CSV.csv
echo "================================================"
echo ""

# Check for anomalies
echo "Data Validation:"
echo "------------------------------------------------"

ANOMALIES=0

# Check CPU% values
while IFS=',' read -r prog cpu mem io_r io_w time; do
    if [ "$prog" = "Program+Function" ]; then
        continue
    fi
    
    # CPU% should be numeric
    if ! [[ "$cpu" =~ ^[0-9]+$ ]]; then
        echo "⚠️  $prog: Invalid CPU% value: $cpu"
        ((ANOMALIES++))
    fi
    
    # Execution time should be reasonable (not > 1000 seconds for 3000 iterations)
    if [ ! -z "$time" ] && [[ "$time" =~ ^[0-9.]+$ ]]; then
        if (( $(echo "$time > 300" | bc -l) )); then
            echo "⚠️  $prog: Execution time seems too high: ${time}s"
            ((ANOMALIES++))
        fi
    fi
    
    # CPU workers should have high CPU% (>70%)
    if [[ "$prog" =~ cpu ]] && [[ "$cpu" =~ ^[0-9]+$ ]] && [ "$cpu" -lt 70 ]; then
        echo "ℹ️  $prog: CPU% lower than expected: ${cpu}%"
    fi
    
done < MT25033_Part_C_CSV.csv

if [ "$ANOMALIES" -eq 0 ]; then
    echo "✓ All values appear reasonable"
fi

echo "================================================"
echo ""

if [ "$DATA_ROWS" -eq 6 ] && [ "$ANOMALIES" -eq 0 ]; then
    echo "✅ Part C tests completed successfully!"
    echo "   Ready for analysis and report generation."
else
    echo "⚠️  Please review the results above."
fi

echo ""
