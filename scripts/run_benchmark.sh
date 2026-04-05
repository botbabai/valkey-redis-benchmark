#!/bin/sh

# Valkey vs Redis 7.2 Performance Comparison
# Uses redis-benchmark to test both servers

set -e

REDIS_HOST="redis"
REDIS_PORT="6379"
VALKEY_HOST="valkey"
VALKEY_PORT="6379"

RESULTS_DIR="/results"
mkdir -p $RESULTS_DIR

echo "==========================================="
echo "Valkey 7.2 vs Redis 7.2 Performance Test"
echo "==========================================="
echo ""

# Test configurations
REQUESTS=100000
DATA_SIZE=256

run_benchmark() {
    local name=$1
    local host=$2
    local port=$3
    local clients=$4
    local output_file=$5
    
    echo "Testing $name with $clients clients..."
    redis-benchmark -h $host -p $port \
        -c $clients \
        -n $REQUESTS \
        -d $DATA_SIZE \
        -q \
        --csv > $output_file
    echo "✓ Completed"
}

# PING test
echo ""
echo "=== PING Test ==="
run_benchmark "Redis" $REDIS_HOST $REDIS_PORT 1 $RESULTS_DIR/redis_ping.csv
run_benchmark "Valkey" $VALKEY_HOST $VALKEY_PORT 1 $RESULTS_DIR/valkey_ping.csv

# Single client SET/GET
echo ""
echo "=== Single Client SET/GET ==="
run_benchmark "Redis" $REDIS_HOST $REDIS_PORT 1 $RESULTS_DIR/redis_single.csv
run_benchmark "Valkey" $VALKEY_HOST $VALKEY_PORT 1 $RESULTS_DIR/valkey_single.csv

# Multi-client tests
for clients in 1 10 50 100; do
    echo ""
    echo "=== $clients Concurrent Clients ==="
    run_benchmark "Redis" $REDIS_HOST $REDIS_PORT $clients $RESULTS_DIR/redis_clients_${clients}.csv
    run_benchmark "Valkey" $VALKEY_HOST $VALKEY_PORT $clients $RESULTS_DIR/valkey_clients_${clients}.csv
done

# List operations
echo ""
echo "=== LIST Operations ==="
redis-benchmark -h $REDIS_HOST -p $REDIS_PORT -c 10 -n 100000 -q --csv -t lpush,lrange > $RESULTS_DIR/redis_list.csv
redis-benchmark -h $VALKEY_HOST -p $VALKEY_PORT -c 10 -n 100000 -q --csv -t lpush,lrange > $RESULTS_DIR/valkey_list.csv

# Hash operations
echo ""
echo "=== HASH Operations ==="
redis-benchmark -h $REDIS_HOST -p $REDIS_PORT -c 10 -n 100000 -q --csv -t hset,hget > $RESULTS_DIR/redis_hash.csv
redis-benchmark -h $VALKEY_HOST -p $VALKEY_PORT -c 10 -n 100000 -q --csv -t hset,hget > $RESULTS_DIR/valkey_hash.csv

# Set operations
echo ""
echo "=== SET Operations ==="
redis-benchmark -h $REDIS_HOST -p $REDIS_PORT -c 10 -n 100000 -q --csv -t sadd,smembers > $RESULTS_DIR/redis_set.csv
redis-benchmark -h $VALKEY_HOST -p $VALKEY_PORT -c 10 -n 100000 -q --csv -t sadd,smembers > $RESULTS_DIR/valkey_set.csv

echo ""
echo "==========================================="
echo "Benchmark complete!"
echo "Results saved to $RESULTS_DIR"
echo "==========================================="
