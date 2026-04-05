#!/bin/sh

# Valkey vs Redis 7.2 using Valkey's native benchmark tool
# Run from the valkey container which has valkey-benchmark

set -e

REDIS_HOST="redis"
REDIS_PORT="6379"
VALKEY_HOST="valkey"
VALKEY_PORT="6379"

RESULTS_DIR="/results-valkey"
mkdir -p $RESULTS_DIR

echo "==========================================="
echo "Valkey Benchmark Tool Comparison"
echo "Valkey 7.2 vs Redis 7.2"
echo "==========================================="
echo ""

run_benchmark() {
    local name=$1
    local host=$2
    local port=$3
    local clients=$4
    local output_file=$5
    local extra_args=${6:-""}
    
    echo "Testing $name with $clients clients..."
    redis-benchmark -h $host -p $port \
        -c $clients \
        -n 100000 \
        -d 256 \
        -q \
        --csv $extra_args > $output_file
    echo "✓ Completed"
}

# Single client
echo ""
echo "=== Single Client (1 connection) ==="
run_benchmark "Redis" $REDIS_HOST $REDIS_PORT 1 $RESULTS_DIR/redis_single.csv
run_benchmark "Valkey" $VALKEY_HOST $VALKEY_PORT 1 $RESULTS_DIR/valkey_single.csv

# Concurrent clients
for clients in 10 50 100 500; do
    echo ""
    echo "=== $clients Concurrent Clients ==="
    run_benchmark "Redis" $REDIS_HOST $REDIS_PORT $clients $RESULTS_DIR/redis_${clients}.csv
    run_benchmark "Valkey" $VALKEY_HOST $VALKEY_PORT $clients $RESULTS_DIR/valkey_${clients}.csv
done

# Pipelined requests
echo ""
echo "=== Pipelined Requests (100 depth) ==="
redis-benchmark -h $REDIS_HOST -p $REDIS_PORT -c 10 -n 100000 -d 256 -P 100 -q --csv > $RESULTS_DIR/redis_pipeline.csv
redis-benchmark -h $VALKEY_HOST -p $VALKEY_PORT -c 10 -n 100000 -d 256 -P 100 -q --csv > $RESULTS_DIR/valkey_pipeline.csv

# Different data sizes
echo ""
echo "=== Small Values (64 bytes) ==="
redis-benchmark -h $REDIS_HOST -p $REDIS_PORT -c 10 -n 100000 -d 64 -q --csv > $RESULTS_DIR/redis_small.csv
redis-benchmark -h $VALKEY_HOST -p $VALKEY_PORT -c 10 -n 100000 -d 64 -q --csv > $RESULTS_DIR/valkey_small.csv

echo ""
echo "=== Large Values (1024 bytes) ==="
redis-benchmark -h $REDIS_HOST -p $REDIS_PORT -c 10 -n 100000 -d 1024 -q --csv > $RESULTS_DIR/redis_large.csv
redis-benchmark -h $VALKEY_HOST -p $VALKEY_PORT -c 10 -n 100000 -d 1024 -q --csv > $RESULTS_DIR/valkey_large.csv

# Specific command tests
echo ""
echo "=== Command-Specific Benchmarks ==="
for cmd in SET GET LPUSH RPUSH HSET SADD; do
    redis-benchmark -h $REDIS_HOST -p $REDIS_PORT -c 10 -n 100000 -t $cmd -q --csv > $RESULTS_DIR/redis_cmd_${cmd}.csv
    redis-benchmark -h $VALKEY_HOST -p $VALKEY_PORT -c 10 -n 100000 -t $cmd -q --csv > $RESULTS_DIR/valkey_cmd_${cmd}.csv
    echo "✓ $cmd tested"
done

echo ""
echo "==========================================="
echo "Benchmark complete!"
echo "Results saved to $RESULTS_DIR"
echo "==========================================="
