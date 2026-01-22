#!/bin/bash

# Interactive Menu for PA01 - MT25033
# Provides user-friendly interface for running programs

clear

show_menu() {
    echo "=========================================="
    echo "   PA01: Processes and Threads"
    echo "   Roll Number: MT25033"
    echo "=========================================="
    echo ""
    echo "Main Menu:"
    echo "  1) Run Program A (Processes) - Interactive"
    echo "  2) Run Program B (Threads) - Interactive"
    echo "  3) Quick test both programs (CPU, 2 count)"
    echo "  4) Run Part C tests (All 6 combinations)"
    echo "  5) Run Part D tests (Scalability analysis)"
    echo "  6) Generate all plots "
    echo "  7) Performance analysis report"
    echo "  8) View Part C results"
    echo "  9) View Part D results"
    echo " 10) Clean temporary files"
    echo "  0) Exit"
    echo ""
}

run_program_a() {
    clear
    echo "=========================================="
    echo "   Program A: Process-based Execution"
    echo "=========================================="
    echo ""
    echo "Available worker types:"
    echo "  1) cpu - CPU-intensive workload"
    echo "  2) mem - Memory-intensive workload"
    echo "  3) io  - I/O-intensive workload"
    echo ""
    read -p "Select worker type (1-3): " worker_choice
    
    case $worker_choice in
        1) worker="cpu" ;;
        2) worker="mem" ;;
        3) worker="io" ;;
        *)
            echo "Invalid choice!"
            read -p "Press Enter to continue..."
            return
            ;;
    esac
    
    read -p "Enter number of child processes (minimum 2): " num_proc
    
    if [ "$num_proc" -lt 2 ] 2>/dev/null; then
        echo "Error: Must be at least 2!"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo ""
    echo "Executing: ./programA $worker $num_proc"
    echo "----------------------------------------"
    ./programA $worker $num_proc
    echo "----------------------------------------"
    echo "Execution complete!"
    echo ""
    read -p "Press Enter to continue..."
}

run_program_b() {
    clear
    echo "=========================================="
    echo "   Program B: Thread-based Execution"
    echo "=========================================="
    echo ""
    echo "Available worker types:"
    echo "  1) cpu - CPU-intensive workload"
    echo "  2) mem - Memory-intensive workload"
    echo "  3) io  - I/O-intensive workload"
    echo ""
    read -p "Select worker type (1-3): " worker_choice
    
    case $worker_choice in
        1) worker="cpu" ;;
        2) worker="mem" ;;
        3) worker="io" ;;
        *)
            echo "Invalid choice!"
            read -p "Press Enter to continue..."
            return
            ;;
    esac
    
    read -p "Enter number of threads (minimum 2): " num_threads
    
    if [ "$num_threads" -lt 2 ] 2>/dev/null; then
        echo "Error: Must be at least 2!"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo ""
    echo "Executing: ./programB $worker $num_threads"
    echo "----------------------------------------"
    ./programB $worker $num_threads
    echo "----------------------------------------"
    echo "Execution complete!"
    echo ""
    read -p "Press Enter to continue..."
}

quick_test() {
    clear
    echo "=========================================="
    echo "   Quick Test Mode"
    echo "=========================================="
    echo ""
    echo "Testing both programs with CPU worker and 2 count..."
    echo ""
    
    echo "[1/2] Program A (Processes):"
    echo "----------------------------------------"
    ./programA cpu 2
    echo ""
    
    echo "[2/2] Program B (Threads):"
    echo "----------------------------------------"
    ./programB cpu 2
    echo ""
    
    echo "Quick test complete!"
    read -p "Press Enter to continue..."
}

run_part_c() {
    clear
    echo "=========================================="
    echo "   Part C: Baseline Performance Tests"
    echo "=========================================="
    echo ""
    
    # Run the Part C script which has its own interactive menu
    bash MT25033_Part_C_shell.sh
    echo ""
    echo "Part C complete! Results saved to MT25033_Part_C_CSV.csv"
    read -p "Press Enter to continue..."
}

run_part_d() {
    clear
    echo "=========================================="
    echo "   Part D: Scalability Analysis"
    echo "=========================================="
    echo ""
    
    # Run the Part D script
    bash MT25033_Part_D_shell.sh
    echo ""
    read -p "Press Enter to continue..."
}

generate_plots() {
    clear
    echo "=========================================="
    echo "   Generate All Plots"
    echo "=========================================="
    echo ""
    
    if [ ! -f "MT25033_Part_D_CSV.csv" ]; then
        echo "Error: MT25033_Part_D_CSV.csv not found!"
        echo "Please run Part D tests first (Option 5)."
        read -p "Press Enter to continue..."
        return
    fi
    
    if ! command -v gnuplot &> /dev/null; then
        echo "Error: gnuplot not installed!"
        echo "Install with: sudo apt-get install gnuplot"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo "Plot Generation Options:"
    echo "  1) All data points (Processes: 2-5, Threads: 2-8)"
    echo "  2) Custom range (specify which counts to include)"
    echo ""
    read -p "Select option (1-2): " plot_option
    
    if [ "$plot_option" = "2" ]; then
        echo ""
        echo "Available process counts in data: 2, 3, 4, 5"
        read -p "Enter process counts to plot (e.g., 2 3 5): " proc_counts
        
        echo "Available thread counts in data: 2, 3, 4, 5, 6, 7, 8"
        read -p "Enter thread counts to plot (e.g., 2 4 6 8): " thread_counts
        
        # Create filtered CSV
        echo "Program,Worker,Count,Avg_CPU,Exec_Time" > MT25033_Part_D_filtered.csv
        
        # Filter process data
        for count in $proc_counts; do
            awk -F, -v cnt="$count" 'NR>1 && $1=="programA" && $3==cnt {print}' MT25033_Part_D_CSV.csv >> MT25033_Part_D_filtered.csv
        done
        
        # Filter thread data
        for count in $thread_counts; do
            awk -F, -v cnt="$count" 'NR>1 && $1=="programB" && $3==cnt {print}' MT25033_Part_D_CSV.csv >> MT25033_Part_D_filtered.csv
        done
        
        # Temporarily use filtered data
        mv MT25033_Part_D_CSV.csv MT25033_Part_D_CSV_backup.csv
        mv MT25033_Part_D_filtered.csv MT25033_Part_D_CSV.csv
    fi
    
    echo ""
    echo "Generating standard plots..."
    gnuplot MT25033_Part_D_plot.gp
    echo ""
    echo "Generating advanced plots..."
    gnuplot MT25033_Part_D_Advanced_plot.gp
    
    # Restore original data if filtered
    if [ "$plot_option" = "2" ]; then
        mv MT25033_Part_D_CSV.csv MT25033_Part_D_filtered.csv
        mv MT25033_Part_D_CSV_backup.csv MT25033_Part_D_CSV.csv
        echo ""
        echo "Note: Plots generated with custom range:"
        echo "  Processes: $proc_counts"
        echo "  Threads: $thread_counts"
    fi
    
    echo ""
    echo "==============================================="
    echo "All plots generated successfully!"
    echo "==============================================="
    echo ""
    echo "Standard Plots (Required):"
    echo "  ✓ MT25033_Part_D_CPU_Scaling.png"
    echo "  ✓ MT25033_Part_D_MEM_Scaling.png"
    echo "  ✓ MT25033_Part_D_IO_Scaling.png"
    echo "  ✓ MT25033_Part_D_Comparison.png (Bar Chart)"
    echo "  ✓ MT25033_Part_D_All_Scaling.png (Combined)"
    echo ""
    echo "Advanced Plots (Creative):"
    echo "  ✓ MT25033_Part_D_Speedup_Analysis.png"
    echo "  ✓ MT25033_Part_D_CPU_Efficiency.png"
    echo "  ✓ MT25033_Part_D_Heatmap.png"
    echo ""
    echo "Total: 8 plots generated!"
    read -p "Press Enter to continue..."
}

generate_advanced_plots() {
    # This function is kept for backward compatibility but now just calls generate_plots
    generate_plots
}

performance_analysis() {
    clear
    echo "=========================================="
    echo "   Performance Analysis Report"
    echo "=========================================="
    echo ""
    
    if [ ! -f "MT25033_Part_D_CSV.csv" ]; then
        echo "Error: MT25033_Part_D_CSV.csv not found!"
        echo "Please run Part D tests first (Option 5)."
        read -p "Press Enter to continue..."
        return
    fi
    
    if [ ! -x "analyze_performance.sh" ]; then
        chmod +x analyze_performance.sh
    fi
    
    bash analyze_performance.sh
    echo ""
    read -p "Press Enter to continue..."
}

clean_files() {
    clear
    echo "=========================================="
    echo "   Clean Temporary Files"
    echo "=========================================="
    echo ""
    echo "This will remove:"
    echo "  - Temporary I/O files (io_*.dat)"
    echo "  - Object files (*.o)"
    echo ""
    read -p "Continue? (y/n): " confirm
    
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        return
    fi
    
    rm -f io_*.dat *.o
    echo ""
    echo "✓ Cleanup complete!"
    read -p "Press Enter to continue..."
}

view_part_c() {
    clear
    echo "=========================================="
    echo "   Part C Results"
    echo "=========================================="
    echo ""
    
    if [ ! -f "MT25033_Part_C_CSV.csv" ]; then
        echo "No results found. Run Part C tests first (Option 4)."
    else
        cat MT25033_Part_C_CSV.csv | column -t -s ','
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

view_part_d() {
    clear
    echo "=========================================="
    echo "   Part D Results"
    echo "=========================================="
    echo ""
    
    if [ ! -f "MT25033_Part_D_CSV.csv" ]; then
        echo "No results found. Run Part D tests first (Option 5)."
    else
        echo "Showing first 20 rows (total: $(wc -l < MT25033_Part_D_CSV.csv) lines)"
        echo ""
        head -20 MT25033_Part_D_CSV.csv | column -t -s ','
        echo ""
        echo "(Use 'cat MT25033_Part_D_CSV.csv' to view all results)"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    clear
    show_menu
    read -p "Enter your choice (0-10): " choice
    
    case $choice in
        1) run_program_a ;;
        2) run_program_b ;;
        3) quick_test ;;
        4) run_part_c ;;
        5) run_part_d ;;
        6) generate_plots ;;
        7) performance_analysis ;;
        8) view_part_c ;;
        9) view_part_d ;;
        10) clean_files ;;
        0)
            clear
            echo "Thank you for using PA01 interactive menu!"
            echo "Good luck with your assignment!"
            exit 0
            ;;
        *)
            echo "Invalid choice! Please enter 0-10."
            sleep 2
            ;;
    esac
done
