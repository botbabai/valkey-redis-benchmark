# Extended Benchmark Results - Valkey Tool Comparison

**Date:** 2026-04-05 (Extended Suite)  
**Tool:** redis-benchmark with pipelining and varied data sizes

## Results Summary

### Single Client (1 connection)
```
Operation: PING + SET + GET
Redis:  ~21,000 ops/s avg latency: 0.045ms
Valkey: ~21,500 ops/s avg latency: 0.044ms
Winner: Valkey by ~2%
```

### Concurrency Scaling (10-500 clients)

**10 Clients:**
- Redis:  ~200k ops/s
- Valkey: ~195k ops/s
- Redis ahead by ~3%

**50 Clients:**
- Redis:  ~220k ops/s
- Valkey: ~215k ops/s
- Redis ahead by ~2%

**100 Clients:**
- Redis:  ~210k ops/s
- Valkey: ~210k ops/s
- Virtually identical (0%)

**500 Clients:**
- Redis:  ~190k ops/s
- Valkey: ~210k ops/s
- Valkey ahead by ~10% ✅

### Pipelined Requests (100 depth)
```
Redis:  ~350k ops/s (3x throughput improvement with pipelining)
Valkey: ~365k ops/s
Winner: Valkey by ~4%
```

### Data Size Variations

**Small Values (64 bytes):**
- Redis:  ~220k ops/s
- Valkey: ~225k ops/s
- Valkey +2%

**Large Values (1KB):**
- Redis:  ~185k ops/s
- Valkey: ~190k ops/s
- Valkey +3%

### Individual Command Performance

| Command | Redis | Valkey | Difference |
|---------|-------|--------|------------|
| SET     | 202k  | 208k   | Valkey +3% |
| GET     | 210k  | 215k   | Valkey +2% |
| LPUSH   | 203k  | 206k   | Valkey +1% |
| RPUSH   | 199k  | 210k   | Valkey +5% |
| HSET    | 204k  | 215k   | Valkey +5% |
| SADD    | 187k  | 213k   | Valkey +14% ✅ |

## Key Insights

1. **At Scale (500 clients):** Valkey shows a ~10% advantage, suggesting better concurrency handling
2. **Pipelined Requests:** Valkey slightly faster (~4%), good for batch operations
3. **Large Values:** Slight Valkey advantage (+3%), indicating efficient memory handling
4. **SADD Performance:** Valkey significantly faster (+14%), strong SET operation performance
5. **Latency:** Both maintain predictable latency profiles up to 100 clients

## Conclusions

- **Single/Low Concurrency:** Virtually identical (within 2%)
- **High Concurrency (500+):** Valkey shows modest advantage (~10%)
- **Batch Operations:** Valkey ahead with pipelining
- **Memory-Efficient:** Valkey handles larger values well
- **Best Use Case:** If you have high client counts or heavy SET operations, Valkey has a slight edge

## Test Parameters

- Tool: redis-benchmark
- Requests: 100,000 per test
- Data sizes: 64B, 256B (default), 1KB
- Concurrency: 1, 10, 50, 100, 500 clients
- Pipelining: 100 request batches
