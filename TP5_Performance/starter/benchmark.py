"""
TP5 - Benchmark Comparatif NoSQL
Mesurer les performances de Redis, MongoDB, Cassandra, Neo4j
"""
import time
import statistics
import json
from typing import Callable, List, Tuple
import redis
from pymongo import MongoClient
from cassandra.cluster import Cluster
from neo4j import GraphDatabase

# ─── Utilitaires de mesure ────────────────────────────────────────────────────

def measure_latency(fn: Callable, iterations: int = 1000) -> dict:
    """
    Exécuter fn iterations fois et retourner les statistiques
    """
    latencies = []
    for _ in range(iterations):
        start = time.perf_counter()
        fn()
        latencies.append((time.perf_counter() - start) * 1000)  # en ms
    
    latencies.sort()
    return {
        "mean_ms": statistics.mean(latencies),
        "p50_ms": latencies[int(0.50 * len(latencies))],
        "p95_ms": latencies[int(0.95 * len(latencies))],
        "p99_ms": latencies[int(0.99 * len(latencies))],
        "max_ms": max(latencies),
        "throughput_rps": 1000 / statistics.mean(latencies)
    }


def print_results(name: str, results: dict):
    print(f"\n{'='*50}")
    print(f" {name}")
    print(f"{'='*50}")
    for k, v in results.items():
        print(f"  {k:20s}: {v:.2f}")


# ─── Ex1 : Benchmark Écriture ─────────────────────────────────────────────────

def benchmark_write_redis(n: int = 10000):
    r = redis.Redis(host='localhost', port=6379)
    start = time.perf_counter()
    pipe = r.pipeline()
    for i in range(n):
        pipe.set(f"bench:{i}", "value")
        if i % 1000 == 0:
            pipe.execute()
    pipe.execute()
    elapsed = time.perf_counter() - start
    print(f"Redis write: {n/elapsed:.2f} rps")

def benchmark_write_mongodb(n: int = 10000):
    client = MongoClient("mongodb://admin:admin123@localhost:27017/")
    db = client["benchmark"]
    col = db["test"]
    col.delete_many({})
    docs = [{"_id": i, "val": "value"} for i in range(n)]
    start = time.perf_counter()
    col.insert_many(docs)
    elapsed = time.perf_counter() - start
    print(f"MongoDB write: {n/elapsed:.2f} rps")

def benchmark_write_cassandra(n: int = 10000):
    cluster = Cluster(['localhost'])
    session = cluster.connect()
    session.execute("CREATE KEYSPACE IF NOT EXISTS bench WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1}")
    session.execute("CREATE TABLE IF NOT EXISTS bench.test (id int PRIMARY KEY, val text)")
    query = session.prepare("INSERT INTO bench.test (id, val) VALUES (?, ?)")
    start = time.perf_counter()
    for i in range(n):
        session.execute_async(query, (i, "value"))
    elapsed = time.perf_counter() - start
    print(f"Cassandra write (async): {n/elapsed:.2f} rps")

def benchmark_read_redis(n=1000):
    r = redis.Redis(host='localhost', port=6379)
    start = time.perf_counter()
    for i in range(n):
        r.get(f"bench:{i}")
    elapsed = time.perf_counter() - start
    print(f"Redis read: {n/elapsed:.2f} rps")

def benchmark_read_mongodb(n=1000):
    client = MongoClient("mongodb://admin:admin123@localhost:27017/")
    db = client["benchmark"]
    col = db["test"]
    start = time.perf_counter()
    for i in range(n):
        col.find_one({"_id": i})
    elapsed = time.perf_counter() - start
    print(f"MongoDB read: {n/elapsed:.2f} rps")

if __name__ == "__main__":
    print("Benchmark NoSQL")
    N = 5000
    benchmark_write_redis(N)
    benchmark_write_mongodb(N)
    benchmark_write_cassandra(N)
    benchmark_read_redis(1000)
    benchmark_read_mongodb(1000)
