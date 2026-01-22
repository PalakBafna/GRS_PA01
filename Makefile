# Makefile for PA01: Processes and Threads
# Roll Number: MT25033

CC = gcc
CFLAGS = -Wall -Wextra -pthread -O2
LDFLAGS = -pthread

# Source files
PROG_A_SRC = MT25033_Part_A_Program_A.c
PROG_B_SRC = MT25033_Part_A_Program_B.c
WORKERS_SRC = MT25033_Part_B_Workers.c
WORKERS_HDR = MT25033_Part_B_Workers.h

# Executables
PROG_A = programA
PROG_B = programB

# Default target: build all programs
all: $(PROG_A) $(PROG_B)

# Build Program A (processes)
$(PROG_A): $(PROG_A_SRC) $(WORKERS_SRC) $(WORKERS_HDR)
	@echo "Compiling Program A (fork-based)..."
	$(CC) $(CFLAGS) -o $(PROG_A) $(PROG_A_SRC) $(WORKERS_SRC) $(LDFLAGS)
	@echo "Program A compiled successfully."

# Build Program B (threads)
$(PROG_B): $(PROG_B_SRC) $(WORKERS_SRC) $(WORKERS_HDR)
	@echo "Compiling Program B (pthread-based)..."
	$(CC) $(CFLAGS) -o $(PROG_B) $(PROG_B_SRC) $(WORKERS_SRC) $(LDFLAGS)
	@echo "Program B compiled successfully."

# Interactive menu for running programs
run: all
	@chmod +x interactive_menu.sh
	@bash interactive_menu.sh

# Run Part C tests
test_c: all
	@echo "Running Part C tests..."
	bash MT25033_Part_C_shell.sh

# Run Part D tests
test_d: all
	@echo "Running Part D tests..."
	bash MT25033_Part_D_shell.sh

# Generate plots for Part D
plot_d: test_d
	@echo "Generating plots for Part D..."
	@if command -v gnuplot > /dev/null; then \
		gnuplot MT25033_Part_D_All_plot.gp; \
		echo "Plots generated successfully."; \
	else \
		echo "Error: gnuplot not found. Please install gnuplot to generate plots."; \
	fi

# Clean build artifacts and generated files
clean:
	@echo "Cleaning up..."
	rm -f $(PROG_A) $(PROG_B)
	rm -f io_*.dat
	rm -f *.o
	@echo "Clean complete."

# Clean all generated data and plots
cleanall: clean
	@echo "Cleaning all generated files..."
	rm -f MT25033_Part_C_CSV.csv
	rm -f MT25033_Part_D_CSV.csv
	rm -f *.png *.pdf
	@echo "All files cleaned."

# Help target
help:
	@echo "Makefile for PA01 - MT25033"
	@echo "Available targets:"
	@echo "  all       - Build all programs (default)"
	@echo "  programA  - Build Program A (fork-based)"
	@echo "  programB  - Build Program B (pthread-based)"
	@echo "  run       - Quick test of both programs with CPU worker"
	@echo "  test_c    - Build and run Part C tests"
	@echo "  test_d    - Build and run Part D tests"
	@echo "  plot_d    - Run Part D tests and generate plots"
	@echo "  clean     - Remove executables and temporary files"
	@echo "  cleanall  - Remove all generated files including CSVs and plots"
	@echo "  help      - Show this help message"

.PHONY: all run test_c test_d plot_d clean cleanall help
