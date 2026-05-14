# Rapport TP3 - Cassandra
## Choix Partition Key
- `mesures_par_capteur`: `(capteur_id, date_jour)` pour éviter les partitions trop larges et distribuer la charge.
- `alertes_par_wilaya`: `(wilaya, date_jour)` pour des requêtes rapides par région.

## Maintenance
- TWCS est idéal pour les séries temporelles car il regroupe les SSTables par fenêtre de temps, facilitant l'expiration des données.
