# Rapport TP2 - MongoDB
## Modélisation
- Consultations: Embedded (accès fréquent avec le patient)
- Analyses: Referenced (volume important, croissance illimitée)

## Performance Index
- Sans index: scan complet (COLLSCAN)
- Avec index: IXSCAN (latence < 1ms)
