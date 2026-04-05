#!/bin/sh
set -e

RESULTS_DIR="/results-valkey"
mkdir -p $RESULTS_DIR

echo "==========================================="
echo "Valkey Benchmark Tool Comparison"
echo "Valkey 7.2 vs Redis 7.2"
echo "==========================================="
echo ""

# Single client
echo "=== Single Client (1 connection) ==="
redis-benchmark -h redis -p 6379 -c 1 -n 100000 -d 256 -q --csv > $RESULTS_DIR/redis_single.csv && echo "✓ Redis single"
redis-benchmark -h valkey -p 6379 -c 1 -n 100000 -d 256 -q --csv > $RESULTS_DIR/valkey_single.csv && echo "✓ Valkey single"

# Concurrent clients
for clients in 10 50 100 500; do
    echo ""
    echo "=== $clients Concurrent Clients ==="
    redis-benchmark -h redis -p 6379 -c $clients -n 100000 -d 256 -q --csv > $RESULTS_DIR/redis_${clients}.csv && echo "✓ Redis $clients"
    redis-benchmark -h valkey -p 6379 -c $clients -n 100000 -d 256 -q --csv > $RESULTS_DIR/valkey_${clients}.csv && echo "✓ Valkey $clients"
done

# Pipelined requests
echo ""
echo "=== Pipelined Requests (100 depth) ==="
redis-benchmark -h redis -p 6379 -c 10 -n 100000 -d 256 -P 100 -q --csv > $RESULTS_DIR/redis_pipeline.csv && echo "✓ Redis pipeline"
redis-benchmark -h valkey -p 6379 -c 10 -n 100000 -d 256 -P 100 -q --csv > $RESULTS_DIR/valkey_pipeline.csv && echo "✓ Valkey pipeline"

# Different data sizes
echo ""
echo "=== Data Size Tests ==="
redis-benchmark -h redis -p 6379 -c 10 -n 100000 -d 64 -q --csv > $RESULTS_DIR/redis_small.csv && echo "✓ Redis 64B"
redis-benchmark -h valkey -p 6379 -c 10 -n 100000 -d 64 -q --csv > $RESULTS_DIR/valkey_small.csv && echo "✓ Valkey 64B"

redis-benchmark -h redis -p 6379 -c 10 -n 100000 -d 1024 -q --csv > $RESULTS_DIR/redis_large.csv && echo "✓ Redis 1KB"
redis-benchmark -h valkey -p 6379 -c 10 -n 100000 -d 1024 -q --csv > $RESULTS_DIR/valkey_large.csv && echo "✓ Valkey 1KB"

# Command-specific
echo ""
echo "=== Command Tests ==="
for cmd in SET GET LPUSH RPUSH HSET SADD; do
    redis-benchmark -h redis -p 6379 -c 10 -n 100000 -t $cmd -q --csv > $RESULTS_DIR/redis_cmd_${cmd}.csv
    redis-benchmark -h valkey -p 6379 -c 10 -n 100000 -t $cmd -q --csv > $RESULTS_DIR/valkey_cmd_${cmd}.csv
    echo "✓ $cmd tested"
done

echo ""
echo "==========================================="
echo "Complete! Results in $RESULTS_DIR"
echo "==========================================="
