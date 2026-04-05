# Benchmark Results - Valkey 7.2 vs Redis 7.2

**Date:** 2026-04-05  
**Environment:** Docker (Alpine Linux)

## Summary

Comprehensive performance comparison between Valkey 7.2 and Redis 7.2 using identical Docker configurations.

## Key Findings

### PING Performance (Single Client)
- **Redis:** ~22,000 ops/s
- **Valkey:** ~22,000 ops/s
- **Result:** Virtually identical (≈0% difference)

### SET/GET Operations

#### Single Client
- **Redis SET:** 21,249 ops/s | **Redis GET:** 21,190 ops/s
- **Valkey SET:** 21,459 ops/s | **Valkey GET:** 21,748 ops/s
- **Result:** Valkey slightly faster (~1% advantage)

#### 10 Concurrent Clients
- **Redis SET:** 201,612 ops/s | **Redis GET:** 208,333 ops/s
- **Valkey SET:** 179,856 ops/s | **Valkey GET:** 191,938 ops/s
- **Result:** Redis faster (~10-12% advantage)

#### 50 Concurrent Clients
- **Redis SET:** 224,215 ops/s | **Redis GET:** 194,174 ops/s
- **Valkey SET:** 218,818 ops/s | **Valkey GET:** 212,314 ops/s
- **Result:** Very competitive (~3-8% variance)

#### 100 Concurrent Clients
- **Redis SET:** 217,864 ops/s | **Redis GET:** 210,084 ops/s
- **Valkey SET:** 196,850 ops/s | **Valkey GET:** 214,592 ops/s
- **Result:** Performance within ~5-10% (mixed)

### Data Structures

#### HASH Operations (HSET)
- **Redis:** 204,498 ops/s
- **Valkey:** 215,053 ops/s
- **Result:** Valkey ~5% faster

#### SET Operations (SADD)
- **Redis:** 187,265 ops/s
- **Valkey:** 213,675 ops/s
- **Result:** Valkey ~14% faster ✅

#### LIST Operations
- **LPUSH:** Nearly identical (~202-203k ops/s both)
- **LRANGE_100:** Virtually tied (~58.6k ops/s both)
- **LRANGE_300:** Valkey ~0.3% faster (26ms vs 25ms avg latency)

## Latency Analysis

Both systems show consistent latencies:
- Single client: ~0.044-0.045ms avg
- 10 clients: ~0.030-0.035ms avg
- 50 clients: ~0.120ms avg
- 100 clients: ~0.240-0.260ms avg

**Observation:** Latency profiles are nearly identical. No significant advantage for either system.

## Conclusions

1. **Performance:** Functionally equivalent across most operations
   - Single-client scenarios: Nearly identical
   - Multi-client (10-100): Within 5-15% variance, no consistent winner
   
2. **Data Structures:** Valkey shows slight edge for HASH and SET operations
   - SADD: Valkey +14% (significant)
   - HSET: Valkey +5%
   - LIST: Equivalent

3. **Latency:** Both stable and predictable at all concurrency levels

4. **Recommendation:**
   - For pure throughput: No meaningful difference
   - For SET operations: Redis slightly ahead under high concurrency
   - For HASH/SET ops: Valkey slightly ahead
   - **Migration viable:** Either system will perform similarly in production

## Test Configuration

- **Docker Images:** redis:7.2-alpine, valkey/valkey:7.2-alpine
- **Benchmark Tool:** redis-benchmark (included with Redis 7.2)
- **Test Parameters:**
  - Requests per test: 100,000
  - Value size: 256 bytes
  - Concurrency levels: 1, 10, 50, 100

## Files

All raw CSV results are in the `results/` directory with detailed metrics for:
- PING operations
- SET/GET at various concurrency levels
- LIST, HASH, SET operations
- Full latency distributions (min, p50, p95, p99, max)
