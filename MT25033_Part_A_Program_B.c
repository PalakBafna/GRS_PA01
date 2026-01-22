#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <string.h>
#include "MT25033_Part_B_Workers.h"

#define COUNT (3 * 1000)

typedef struct {
    char type[4];
} thread_arg;

void* thread_runner(void *arg) {
    thread_arg *t = (thread_arg*)arg;

    if (strcmp(t->type, "cpu") == 0)
        cpu_worker(COUNT);
    else if (strcmp(t->type, "mem") == 0)
        mem_worker(COUNT);
    else if (strcmp(t->type, "io") == 0)
        io_worker(COUNT);
    else {
        fprintf(stderr, "Error: Invalid worker type '%s'\n", t->type);
        pthread_exit(NULL);
    }

    return NULL;
}

int main(int argc, char *argv[]) {
    char worker_type[10];
    int num;

    // Interactive mode: prompt user for input
    if (argc == 1) {
        printf("====================================\n");
        printf(" Program B: Thread-based Execution\n");
        printf("====================================\n\n");
        
        printf("Available worker types:\n");
        printf("  cpu - CPU-intensive workload\n");
        printf("  mem - Memory-intensive workload\n");
        printf("  io  - I/O-intensive workload\n\n");
        
        printf("Enter worker type (cpu/mem/io): ");
        if (scanf("%9s", worker_type) != 1) {
            fprintf(stderr, "Error: Invalid input\n");
            exit(1);
        }
        
        printf("Enter number of threads (minimum 2): ");
        if (scanf("%d", &num) != 1) {
            fprintf(stderr, "Error: Invalid number\n");
            exit(1);
        }
        
        if (num < 2) {
            fprintf(stderr, "\nError: Number of threads must be at least 2 (provided: %d)\n", num);
            exit(1);
        }
        
        printf("\nCreating %d threads with '%s' worker...\n\n", num, worker_type);
    }
    // Command-line mode: use arguments
    else if (argc == 3) {
        strncpy(worker_type, argv[1], sizeof(worker_type) - 1);
        worker_type[sizeof(worker_type) - 1] = '\0';
        num = atoi(argv[2]);
        
        if (num < 2) {
            fprintf(stderr, "Error: Number of threads must be at least 2 (provided: %d)\n", num);
            exit(1);
        }
    }
    // Invalid usage
    else {
        fprintf(stderr, "Usage: %s [<cpu|mem|io> <num_threads>]\n", argv[0]);
        fprintf(stderr, "  Run without arguments for interactive mode\n");
        fprintf(stderr, "  Or provide:\n");
        fprintf(stderr, "    <cpu|mem|io>   : Type of worker function\n");
        fprintf(stderr, "    <num_threads>  : Number of threads (minimum: 2)\n");
        exit(1);
    }

    pthread_t threads[num];
    thread_arg arg;
    strncpy(arg.type, worker_type, sizeof(arg.type) - 1);
    arg.type[sizeof(arg.type) - 1] = '\0';

    for (int i = 0; i < num; i++)
        pthread_create(&threads[i], NULL, thread_runner, &arg);

    for (int i = 0; i < num; i++)
        pthread_join(threads[i], NULL);

    return 0;
}
