// 4.1 Trouver un tuteur (ex: E10 en filière Info, maîtrise Python, note > 14)
MATCH (e:Etudiant)-[:SUIT {note: 15}]->(c:Cours {code: "INFO401"})
MATCH (e)-[:MAITRISE]->(comp:Competence {nom: "Python"})
RETURN e.prenom, e.nom, c.intitule, comp.nom;

// 4.2 Réseau alumni (jusqu'à 3 sauts)
MATCH (moi:Etudiant {id: "E1"})-[:CONNAIT*1..3]-(connexion)
RETURN DISTINCT connexion.prenom, connexion.nom, connexion.universite;

// 4.3 Détection de ponts
// On peut utiliser Betweenness Centrality
CALL gds.graph.project('bridges', 'Etudiant', {CONNAIT: {orientation: 'UNDIRECTED'}});
CALL gds.betweenness.stream('bridges')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).prenom AS etudiant, score
ORDER BY score DESC LIMIT 5;
CALL gds.graph.drop('bridges');

// 4.5 Score de similarité (Jaccard)
MATCH (e1:Etudiant {id: "E1"})-[:SUIT|MAITRISE]->(item)
WITH e1, collect(id(item)) AS items1
MATCH (e2:Etudiant)-[:SUIT|MAITRISE]->(item) WHERE e1 <> e2
WITH e1, items1, e2, collect(id(item)) AS items2
RETURN e1.prenom, e2.prenom, gds.similarity.jaccard(items1, items2) AS similarity
ORDER BY similarity DESC LIMIT 5;
