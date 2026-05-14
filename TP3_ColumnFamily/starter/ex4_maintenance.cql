USE smartgrid;

-- 4.2 Configurer TWCS pour les mesures
ALTER TABLE mesures_par_capteur
WITH compaction = {
  'class': 'TimeWindowCompactionStrategy',
  'compaction_window_unit': 'DAYS',
  'compaction_window_size': 1
};

-- 4.4 Analyser une partition "hot"
-- On peut utiliser nodetool tablestats ou nodetool toppartitions pour détecter.
-- Correction : Ajouter un "bucket" à la partition key (ex: date_jour, heure) pour subdiviser la partition.
