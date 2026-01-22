# Advanced Creative Plots for Part D
# Additional analysis beyond basic requirements

set datafile separator ","

# =============================================================================
# Plot 5: Speedup Analysis (shows efficiency of parallelization)
# =============================================================================
set terminal pngcairo size 1000,700 enhanced font 'Arial,12'
set output "MT25033_Part_D_Speedup_Analysis.png"

set title "Speedup vs Number of Workers (Single CPU - Shows Overhead)" font 'Arial,14'
set xlabel "Number of Processes / Threads" font 'Arial,12'
set ylabel "Speedup Factor" font 'Arial,12'
set grid
set key right bottom

# Ideal speedup would be 1x (flat line) since we're on single CPU
# Values > 1 indicate overhead, < 1 would indicate benefit (unlikely on single CPU)

# Get baseline times (n=2) for each program
baseline_A = 0.04  # programA cpu at n=2
baseline_B = 0.04  # programB cpu at n=2

plot \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && strcol(2) eq "cpu" ? $3 : 1/0):(baseline_A/$5) \
    with linespoints lw 2 pt 7 ps 1.5 lc rgb '#0060ad' title "Processes (CPU)", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "cpu" ? $3 : 1/0):(baseline_B/$5) \
    with linespoints lw 2 pt 5 ps 1.5 lc rgb '#dd181f' title "Threads (CPU)", \
1 with lines lw 2 dt 2 lc rgb "black" title "Ideal (No Overhead)"

# =============================================================================
# Plot 6: CPU Efficiency Comparison
# =============================================================================
set output "MT25033_Part_D_CPU_Efficiency.png"

set title "CPU Efficiency: Processes vs Threads" font 'Arial,14'
set xlabel "Number of Workers" font 'Arial,12'
set ylabel "Average CPU Usage (%)" font 'Arial,12'
set yrange [0:100]
set grid
set key right top

plot \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && strcol(2) eq "cpu" ? $3 : 1/0):4 \
    with linespoints lw 2 pt 7 ps 1.5 title "Processes - CPU worker", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && strcol(2) eq "mem" ? $3 : 1/0):4 \
    with linespoints lw 2 pt 9 ps 1.5 title "Processes - MEM worker", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && strcol(2) eq "io" ? $3 : 1/0):4 \
    with linespoints lw 2 pt 11 ps 1.5 title "Processes - IO worker", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "cpu" ? $3 : 1/0):4 \
    with linespoints lw 2 pt 5 ps 1.5 title "Threads - CPU worker", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "mem" ? $3 : 1/0):4 \
    with linespoints lw 2 pt 6 ps 1.5 title "Threads - MEM worker", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "io" ? $3 : 1/0):4 \
    with linespoints lw 2 pt 4 ps 1.5 title "Threads - IO worker"

# =============================================================================
# Plot 7: Execution Time Heatmap Style
# =============================================================================
set output "MT25033_Part_D_Heatmap.png"

set title "Execution Time Comparison Matrix" font 'Arial,14'
set xlabel "Worker Type" font 'Arial,12'
set ylabel "Count" font 'Arial,12'
set grid

set xtics ("CPU" 1, "MEM" 2, "IO" 3)
set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.9

plot \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && $3 == 2 ? (strcol(2) eq "cpu" ? 1 : strcol(2) eq "mem" ? 2 : 3) : 1/0):5 \
    with boxes lc rgb "blue" title "Processes (n=2)", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && $3 == 2 ? (strcol(2) eq "cpu" ? 1 : strcol(2) eq "mem" ? 2 : 3) : 1/0):5 \
    with boxes lc rgb "red" title "Threads (n=2)"

# =============================================================================
print "Advanced plots generated successfully!"
print "  5. MT25033_Part_D_Speedup_Analysis.png"
print "  6. MT25033_Part_D_CPU_Efficiency.png"
print "  7. MT25033_Part_D_Heatmap.png"
