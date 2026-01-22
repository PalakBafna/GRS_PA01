# Comprehensive Gnuplot Script for Part D - All Plots Combined
# Roll Number: MT25033

set datafile separator ","

# Color scheme
set style line 1 lc rgb '#0060ad' lt 1 lw 3 pt 7 ps 1.8  # Blue - Processes
set style line 2 lc rgb '#dd181f' lt 1 lw 3 pt 5 ps 1.8  # Red - Threads
set style line 3 lc rgb '#00aa00' lt 1 lw 2 pt 9 ps 1.5  # Green
set style line 4 lc rgb '#ff8800' lt 1 lw 2 pt 11 ps 1.5 # Orange

# =============================================================================
# Plot 1: CPU-bound Workload Scaling
# =============================================================================
set terminal pngcairo size 1200,800 enhanced font 'Arial,12'
set output "MT25033_Part_D_CPU_Scaling.png"

set title "CPU-Bound Workload: Execution Time vs Count\n{/*0.8 Lower is Better (Faster)}" font 'Arial,16'
set xlabel "Number of Processes / Threads" font 'Arial,13'
set ylabel "Execution Time (seconds)" font 'Arial,13'
set grid ytics lt 0 lw 1 lc rgb "#cccccc"
set grid xtics lt 0 lw 1 lc rgb "#cccccc"
set key left top box font 'Arial,11'

plot \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && strcol(2) eq "cpu" ? $3 : 1/0):5 \
    with linespoints ls 1 title "Processes (fork)", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "cpu" ? $3 : 1/0):5 \
    with linespoints ls 2 title "Threads (pthread)"

# =============================================================================
# Plot 2: Memory-bound Workload Scaling
# =============================================================================
set output "MT25033_Part_D_MEM_Scaling.png"

set title "Memory-Bound Workload: Execution Time vs Count\n{/*0.8 Lower is Better (Faster)}" font 'Arial,16'

plot \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && strcol(2) eq "mem" ? $3 : 1/0):5 \
    with linespoints ls 1 title "Processes (fork)", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "mem" ? $3 : 1/0):5 \
    with linespoints ls 2 title "Threads (pthread)"

# =============================================================================
# Plot 3: I/O-bound Workload Scaling
# =============================================================================
set output "MT25033_Part_D_IO_Scaling.png"

set title "I/O-Bound Workload: Execution Time vs Count\n{/*0.8 Lower is Better (Faster)}" font 'Arial,16'

plot \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && strcol(2) eq "io" ? $3 : 1/0):5 \
    with linespoints ls 1 title "Processes (fork)", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "io" ? $3 : 1/0):5 \
    with linespoints ls 2 title "Threads (pthread)"

# =============================================================================
# Plot 4: CPU Efficiency Comparison
# =============================================================================
set output "MT25033_Part_D_CPU_Efficiency.png"

set title "CPU Utilization: Processes vs Threads" font 'Arial,14'
set xlabel "Number of Workers" font 'Arial,12'
set ylabel "Average CPU Usage (%)" font 'Arial,12'
set yrange [0:110]
set grid

plot \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && strcol(2) eq "cpu" ? $3 : 1/0):4 \
    with linespoints ls 1 title "Processes - CPU", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "cpu" ? $3 : 1/0):4 \
    with linespoints ls 2 title "Threads - CPU", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && strcol(2) eq "mem" ? $3 : 1/0):4 \
    with linespoints ls 3 title "Processes - MEM", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "mem" ? $3 : 1/0):4 \
    with linespoints ls 4 title "Threads - MEM"

# =============================================================================
# Plot 5: Combined Comparison (All Workers)
# =============================================================================
set terminal pngcairo size 1600,1000 enhanced font 'Arial,11'
set output "MT25033_Part_D_All_Comparison.png"

set multiplot layout 2,2 title "Complete Scalability Analysis - Processes vs Threads\n{/*0.8 MT25033 | Single CPU Pinned (taskset -c 0)}" font 'Arial,16'

# Subplot 1: CPU-bound
set title "CPU-Bound Worker" font 'Arial,13'
set xlabel "Count" font 'Arial,11'
set ylabel "Time (s)" font 'Arial,11'
set grid
set key left top font 'Arial,9'

plot \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && strcol(2) eq "cpu" ? $3 : 1/0):5 \
    with linespoints ls 1 title "Processes", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "cpu" ? $3 : 1/0):5 \
    with linespoints ls 2 title "Threads"

# Subplot 2: Memory-bound
set title "Memory-Bound Worker" font 'Arial,13'
set xlabel "Count" font 'Arial,11'
set ylabel "Time (s)" font 'Arial,11'

plot \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && strcol(2) eq "mem" ? $3 : 1/0):5 \
    with linespoints ls 1 title "Processes", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "mem" ? $3 : 1/0):5 \
    with linespoints ls 2 title "Threads"

# Subplot 3: I/O-bound
set title "I/O-Bound Worker" font 'Arial,13'
set xlabel "Count" font 'Arial,11'
set ylabel "Time (s)" font 'Arial,11'

plot \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && strcol(2) eq "io" ? $3 : 1/0):5 \
    with linespoints ls 1 title "Processes", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "io" ? $3 : 1/0):5 \
    with linespoints ls 2 title "Threads"

# Subplot 4: CPU Efficiency
set title "CPU Utilization (%)" font 'Arial,13'
set xlabel "Count" font 'Arial,11'
set ylabel "CPU%" font 'Arial,11'
set yrange [0:110]

plot \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && strcol(2) eq "cpu" ? $3 : 1/0):4 \
    with linespoints lw 2 pt 7 title "Proc-CPU", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "cpu" ? $3 : 1/0):4 \
    with linespoints lw 2 pt 5 title "Thrd-CPU"

unset multiplot

# =============================================================================
print ""
print "========================================"
print "All Part D Plots Generated Successfully!"
print "========================================"
print ""
print "Generated Files:"
print "  1. MT25033_Part_D_CPU_Scaling.png"
print "  2. MT25033_Part_D_MEM_Scaling.png"
print "  3. MT25033_Part_D_IO_Scaling.png"
print "  4. MT25033_Part_D_CPU_Efficiency.png"
print "  5. MT25033_Part_D_All_Comparison.png"
print ""
print "Use these plots in your report for Part D analysis."
print "========================================"
print ""
