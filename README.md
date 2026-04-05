# Valkey 7.2 vs Redis 7.2 Performance Benchmark

Complete setup for comparing Valkey and Redis performance using Docker and `redis-benchmark`.

## Quick Start

### 1. Start the containers
```bash
cd /Users/botbabai/.openclaw/workspace/valkey-redis-benchmark
docker-compose up -d
```

### 2. Run the benchmark
```bash
docker-compose exec benchmark bash /scripts/run_benchmark.sh
```

This will:
- Test PING latency
- Run SET/GET operations with 1, 10, 50, and 100 concurrent clients
- Test LIST, HASH, and SET data structures
- Save results as CSV files

### 3. Analyze results
```bash
docker-compose exec benchmark python3 /scripts/analyze_results.py
```

This generates a comparison report showing:
- Operations per second (ops/s) for each command
- Performance difference as a percentage
- Which server is faster for each operation

## What's Being Tested

### PING Test
- Basic latency measurement
- Single request/response round-trip

### SET/GET Operations
- Core read/write performance
- Tests with 1, 10, 50, 100 concurrent clients
- 100,000 requests per test

### Data Structures
- **LIST**: `lpush` and `lrange` operations
- **HASH**: `hset` and `hget` operations
- **SET**: `sadd` and `smembers` operations

## Configuration

Edit `docker-compose.yml` to adjust:
- Port mappings (currently Redis: 6379, Valkey: 6380)
- Alpine vs full image (current: alpine for speed)

Edit `scripts/run_benchmark.sh` to adjust:
- `REQUESTS`: Number of requests per test (default: 100,000)
- `DATA_SIZE`: Size of values in bytes (default: 256)
- `CLIENTS`: Concurrency levels to test

## Viewing Results

Results are stored as CSV files. You can:

1. **View raw CSV**
   ```bash
   cat /results/redis_clients_10.csv
   ```

2. **Run analysis script**
   ```bash
   python3 /scripts/analyze_results.py
   ```

3. **Export results**
   ```bash
   docker cp benchmark:/results ./benchmark_results
   ```

## Cleanup

```bash
docker-compose down -v  # Remove volumes too
```

## Performance Tips

- Run tests multiple times for consistency
- Ensure no other heavy processes on the host
- Use `docker stats` to monitor resource usage during benchmarks
- Consider running individual tests if full suite takes too long

## Common Issues

**"Connection refused"**
- Ensure containers are running: `docker-compose ps`
- Check ports aren't already in use: `lsof -i :6379`

**"redis-benchmark not found"**
- Rebuild: `docker-compose down && docker-compose up -d --build`

**CSV parsing errors**
- Ensure both Redis and Valkey are fully started
- Check logs: `docker-compose logs redis` / `docker-compose logs valkey`
