#!/usr/bin/env python3
"""
Valkey vs Redis Performance Comparison Analyzer
Parses redis-benchmark CSV output and generates comparison report
"""

import csv
import os
import sys
from pathlib import Path
from collections import defaultdict

def parse_csv(filepath):
    """Parse redis-benchmark CSV output"""
    data = {}
    try:
        with open(filepath, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                command = row.get('test', 'unknown')
                rps = float(row.get('rps', 0))
                data[command] = rps
    except Exception as e:
        print(f"Error parsing {filepath}: {e}")
        return {}
    return data

def compare_results(redis_file, valkey_file, test_name):
    """Compare Redis vs Valkey results"""
    redis_data = parse_csv(redis_file)
    valkey_data = parse_csv(valkey_file)
    
    print(f"\n{'='*60}")
    print(f"Test: {test_name}")
    print(f"{'='*60}")
    print(f"{'Command':<20} {'Redis (ops/s)':<20} {'Valkey (ops/s)':<20} {'Difference':<15}")
    print(f"{'-'*75}")
    
    all_commands = set(redis_data.keys()) | set(valkey_data.keys())
    
    for command in sorted(all_commands):
        redis_rps = redis_data.get(command, 0)
        valkey_rps = valkey_data.get(command, 0)
        
        if redis_rps > 0:
            diff_pct = ((valkey_rps - redis_rps) / redis_rps) * 100
            winner = "↑ Valkey" if diff_pct > 1 else "↓ Redis" if diff_pct < -1 else "≈ Tie"
            diff_str = f"{diff_pct:+.1f}% {winner}"
        else:
            diff_str = "N/A"
        
        print(f"{command:<20} {redis_rps:>18,.0f} {valkey_rps:>18,.0f} {diff_str:<15}")

def main():
    results_dir = Path("/results")
    
    if not results_dir.exists():
        print("Results directory not found. Run benchmark first.")
        sys.exit(1)
    
    print("\n" + "="*60)
    print("VALKEY 7.2 vs REDIS 7.2 PERFORMANCE COMPARISON")
    print("="*60)
    
    # Ping test
    redis_file = results_dir / "redis_ping.csv"
    valkey_file = results_dir / "valkey_ping.csv"
    if redis_file.exists() and valkey_file.exists():
        compare_results(redis_file, valkey_file, "PING")
    
    # Single client
    redis_file = results_dir / "redis_single.csv"
    valkey_file = results_dir / "valkey_single.csv"
    if redis_file.exists() and valkey_file.exists():
        compare_results(redis_file, valkey_file, "SET/GET (1 Client)")
    
    # Multi-client tests
    for clients in [1, 10, 50, 100]:
        redis_file = results_dir / f"redis_clients_{clients}.csv"
        valkey_file = results_dir / f"valkey_clients_{clients}.csv"
        if redis_file.exists() and valkey_file.exists():
            compare_results(redis_file, valkey_file, f"SET/GET ({clients} Clients)")
    
    # Data structure tests
    for ds_type in ["list", "hash", "set"]:
        redis_file = results_dir / f"redis_{ds_type}.csv"
        valkey_file = results_dir / f"valkey_{ds_type}.csv"
        if redis_file.exists() and valkey_file.exists():
            compare_results(redis_file, valkey_file, f"{ds_type.upper()} Operations")
    
    print("\n" + "="*60)
    print("Summary:")
    print("- Higher ops/s = Better performance")
    print("- Positive % = Valkey ahead")
    print("- Negative % = Redis ahead")
    print("="*60 + "\n")

if __name__ == "__main__":
    main()
