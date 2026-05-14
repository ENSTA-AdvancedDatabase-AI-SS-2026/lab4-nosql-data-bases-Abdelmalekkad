USE smartgrid;

-- 3.1 Mesures d'un capteur spécifique sur les dernières 6 heures
-- SELECT * FROM mesures_par_capteur WHERE capteur_id = ... AND date_jour = ... AND timestamp >= ...;

-- 3.2 Dernière mesure de chaque capteur d'une wilaya
-- SELECT * FROM mesures_par_capteur WHERE capteur_id = ... AND date_jour = ... LIMIT 1;

-- 3.3 Alertes d'Alger aujourd'hui
SELECT count(*) FROM alertes_par_wilaya WHERE wilaya = 'Alger' AND date_jour = '2024-05-14';

-- 3.4 Consommation totale par heure
SELECT * FROM agregats_horaires WHERE wilaya = 'Alger' LIMIT 24;

-- 3.5 Anomalies (tension hors [200, 240])
-- SELECT * FROM mesures_par_capteur WHERE tension_v < 200 OR tension_v > 240 ALLOW FILTERING;

-- 3.7 Pourquoi éviter ALLOW FILTERING ?
-- Car cela force Cassandra à scanner toutes les partitions, ce qui tue les performances.
-- Solution : créer une table dédiée indexée par tension si c'est une requête fréquente.
