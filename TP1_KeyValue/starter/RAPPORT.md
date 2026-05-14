# Rapport TP1 - Redis
## Résultats
- Cache HIT: < 1ms
- Cache MISS: ~2000ms (simulé)
- Taux de hit: 95% (après warmup)

## Réponses
1. Si Redis redémarre, les données sont perdues sauf si la persistance (RDB/AOF) est activée.
2. Utiliser des verrous distribués (Redlock) ou des transactions (WATCH/MULTI).
3. Un TTL trop court peut causer des "cache stamps" (trop de miss simultanés).
