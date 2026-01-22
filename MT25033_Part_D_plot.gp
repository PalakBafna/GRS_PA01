# Comprehensive Gnuplot Script for Part D - Enhanced Comparison
# Clear visual distinction between Processes vs Threads
# Roll Number: MT25033

set datafile separator ","

# Color scheme: Blue for Processes, Red for Threads
set style line 1 lc rgb '#0060ad' lt 1 lw 3 pt 7 ps 1.8  # Blue circles - Processes
set style line 2 lc rgb '#dd181f' lt 1 lw 3 pt 5 ps 1.8  # Red squares - Threads

# =============================================================================
# Plot 1: CPU-bound Scaling with Winner Indication
# =============================================================================
set terminal pngcairo size 1200,800 enhanced font 'Arial,12'
set output "MT25033_Part_D_CPU_Scaling.png"

set title "CPU-bound Workload: Processes vs Threads Scaling\n{/*0.8 Lower is Better (Faster Execution)}" font 'Arial,16'
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
# Plot 2: Memory-bound Scaling with Winner Indication
# =============================================================================
set output "MT25033_Part_D_MEM_Scaling.png"

set title "Memory-bound Workload: Processes vs Threads Scaling\n{/*0.8 Lower is Better (Faster Execution)}" font 'Arial,16'
set xlabel "Number of Processes / Threads" font 'Arial,13'
set ylabel "Execution Time (seconds)" font 'Arial,13'

plot \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && strcol(2) eq "mem" ? $3 : 1/0):5 \
    with linespoints ls 1 title "Processes (fork)", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "mem" ? $3 : 1/0):5 \
    with linespoints ls 2 title "Threads (pthread)"

# =============================================================================
# Plot 3: I/O-bound Scaling with Winner Indication
# =============================================================================
set output "MT25033_Part_D_IO_Scaling.png"

set title "I/O-bound Workload: Processes vs Threads Scaling\n{/*0.8 Lower is Better (Faster Execution)}" font 'Arial,16'
set xlabel "Number of Processes / Threads" font 'Arial,13'
set ylabel "Execution Time (seconds)" font 'Arial,13'

plot \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && strcol(2) eq "io" ? $3 : 1/0):5 \
    with linespoints ls 1 title "Processes (fork)", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "io" ? $3 : 1/0):5 \
    with linespoints ls 2 title "Threads (pthread)"

# =============================================================================
# Plot 4: Side-by-Side Bar Comparison (Easy to see winner)
# =============================================================================
set terminal pngcairo size 1400,900 enhanced font 'Arial,12'
set output "MT25033_Part_D_Comparison.png"

set title "Direct Comparison: Processes vs Threads (n=2)\n{/*0.8 Lower Bars = Better Performance}" font 'Arial,16'
set ylabel "Execution Time (seconds)" font 'Arial,13'
set xlabel "Workload Type" font 'Arial,13'

set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.9
set grid ytics

set xtics ("CPU-bound" 0, "Memory-bound" 1, "I/O-bound" 2) font 'Arial,12'
set key top left box font 'Arial,11'

# Extract data for n=2 only
plot \
newhistogram, \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && $3 == 2 && strcol(2) eq "cpu" ? $5 : 1/0) \
    title "Processes (fork)" lc rgb '#0060ad', \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && $3 == 2 && strcol(2) eq "cpu" ? $5 : 1/0) \
    title "Threads (pthread)" lc rgb '#dd181f', \
newhistogram at 1, \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && $3 == 2 && strcol(2) eq "mem" ? $5 : 1/0) \
    notitle lc rgb '#0060ad', \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && $3 == 2 && strcol(2) eq "mem" ? $5 : 1/0) \
    notitle lc rgb '#dd181f', \
newhistogram at 2, \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && $3 == 2 && strcol(2) eq "io" ? $5 : 1/0) \
    notitle lc rgb '#0060ad', \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && $3 == 2 && strcol(2) eq "io" ? $5 : 1/0) \
    notitle lc rgb '#dd181f'

# =============================================================================
# Plot 5: Combined Multi-plot (All workloads together)
# =============================================================================
set terminal pngcairo size 1600,1100 enhanced font 'Arial,11'
set output "MT25033_Part_D_All_Scaling.png"

set multiplot layout 2,2 title "Processes vs Threads Scaling Analysis (Single CPU Pinned)\n{/*0.8 Blue=Processes | Red=Threads | Lower=Better}" font 'Arial,16'

# Subplot 1: CPU-bound
set title "CPU-bound Workload" font 'Arial,13'
set xlabel "Count" font 'Arial,11'
set ylabel "Execution Time (s)" font 'Arial,11'
set grid ytics lt 0 lw 1 lc rgb "#cccccc"
set key left top font 'Arial,10'

plot \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && strcol(2) eq "cpu" ? $3 : 1/0):5 \
    with linespoints ls 1 title "Processes", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "cpu" ? $3 : 1/0):5 \
    with linespoints ls 2 title "Threads"

# Subpl"
print "==============================================="
print "All plots generated successfully!"
print "==============================================="
print "Generated files:"
print "  1. MT25033_Part_D_CPU_Scaling.png - CPU workload comparison"
print "  2. MT25033_Part_D_MEM_Scaling.png - Memory workload comparison"
print "  3. MT25033_Part_D_IO_Scaling.png - I/O workload comparison"
print "  4. MT25033_Part_D_Comparison.png - Side-by-side bar comparison (EASY TO READ)"
print "  5. MT25033_Part_D_All_Scaling.png - Combined multiplot view"
print ""
print "Visual Guide:"
print "  🔵 BLUE = Processes (fork)   |  Lower is Better"
print "  🔴 RED  = Threads (pthread)  |  Lower is Faster"
print "===============================================
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && strcol(2) eq "mem" ? $3 : 1/0):5 \
    with linespoints ls 1 title "Processes", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "mem" ? $3 : 1/0):5 \
    with linespoints ls 2 title "Threads"

# Subplot 3: I/O-bound
set title "I/O-bound Workload" font 'Arial,13'
set xlabel "Count" font 'Arial,11'
set ylabel "Execution Time (s)" font 'Arial,11'

plot \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programA" && strcol(2) eq "io" ? $3 : 1/0):5 \
    with linespoints ls 1 title "Processes", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "io" ? $3 : 1/0):5 \
    with linespoints ls 2 title "Threads"

# Subplot 4: Winner Summary (Percentage Difference)
set title "Performance Winner by Workload\n{/*0.8 Negative = Threads Faster | Positive = Processes Faster}" font 'Arial,13'
set xlabel "Worker Count" font 'Arial,11'
set ylabel "% Difference (Threads - Processes)" font 'Arial,11'
set yrange [-20:20]
set grid ytics xtics
set key right top font 'Arial,9'

# Calculate percentage difference for n=2
set arrow from 2,-20 to 2,20 nohead dt 2 lc rgb "black" lw 1

plot \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "cpu" ? $3 : 1/0):(0) \
    with lines lw 2 lc rgb "black" title "Equal Performance", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "cpu" ? $3 : 1/0):4 \
    with linespoints lw 1.5 pt 5 ps 1 lc rgb '#dd181f' title "CPU worker", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "mem" ? $3 : 1/0):4 \
    with linespoints lw 1.5 pt 6 ps 1 lc rgb '#008800' title "MEM worker", \
"MT25033_Part_D_CSV.csv" using (strcol(1) eq "programB" && strcol(2) eq "io" ? $3 : 1/0):4 \
    with linespoints lw 1.5 pt 4 ps 1 lc rgb '#0060ad' title "IO worker"

unset multiplot

# =============================================================================
print "All plots generated successfully!"
print "Generated files:"
print "  1. MT25033_Part_D_CPU_Scaling.png"
print "  2. MT25033_Part_D_MEM_Scaling.png"
print "  3. MT25033_Part_D_IO_Scaling.png"
print "  4. MT25033_Part_D_All_Scaling.png"
