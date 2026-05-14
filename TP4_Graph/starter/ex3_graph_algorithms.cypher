// TP4 - Exercice 3 : Algorithmes de Graphe avec GDS
// Prérequis : Plugin Graph Data Science installé (inclus dans docker-compose)

MATCH p = shortestPath(
  (a:Etudiant {id: "E1"})-[:CONNAIT*..10]-(b:Etudiant {id: "E20"})
)
RETURN [n IN nodes(p) | n.prenom + " (" + n.universite + ")"] AS chemin,
       length(p) AS nb_intermediaires;

CALL gds.graph.project(
  'reseau_social',
  'Etudiant',
  {CONNAIT: {orientation: 'UNDIRECTED'}}
);

CALL gds.degree.stream('reseau_social')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).prenom AS etudiant,
       gds.util.asNode(nodeId).universite AS universite,
       score AS nb_connexions
ORDER BY score DESC
LIMIT 10;

CALL gds.louvain.stream('reseau_social')
YIELD nodeId, communityId
WITH communityId, collect(gds.util.asNode(nodeId).prenom) AS membres
RETURN communityId,
       size(membres) AS taille,
       membres[0..5] AS exemple_membres
ORDER BY taille DESC;

MATCH (moi:Etudiant {id: "E1"}), (cible:Etudiant)
WHERE NOT (moi)-[:CONNAIT]-(cible) AND moi <> cible
OPTIONAL MATCH (moi)-[:CONNAIT]-(ami)-[:CONNAIT]-(cible)
WITH cible, count(ami) AS amis_communs
OPTIONAL MATCH (moi)-[:SUIT]->(c:Cours)<-[:SUIT]-(cible)
WITH cible, amis_communs, count(c) AS cours_communs
WHERE amis_communs > 0 OR cours_communs > 0
RETURN cible.prenom AS suggestion, (amis_communs * 3 + cours_communs * 2) AS score
ORDER BY score DESC
LIMIT 5;

CALL gds.graph.drop('reseau_social', false);
