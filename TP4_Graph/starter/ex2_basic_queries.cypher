// 2.1 Amis de Prenom1
MATCH (e:Etudiant {id: "E1"})-[:CONNAIT]-(ami)
RETURN ami.prenom, ami.nom;

// 2.2 Amis d'amis de Prenom1 (non directs)
MATCH (moi:Etudiant {id: "E1"})-[:CONNAIT*2]-(fof)
WHERE NOT (moi)-[:CONNAIT]-(fof) AND moi <> fof
RETURN DISTINCT fof.prenom, fof.nom;

// 2.3 Suivent même cours que E2 mais ne connaissent pas E2
MATCH (e2:Etudiant {id: "E2"})-[:SUIT]->(c:Cours)<-[:SUIT]-(autre)
WHERE NOT (e2)-[:CONNAIT]-(autre) AND e2 <> autre
RETURN DISTINCT autre.prenom, autre.nom;

// 2.4 Cours les plus populaires
MATCH (c:Cours)<-[:SUIT]-()
RETURN c.intitule, count(*) AS membres
ORDER BY membres DESC;

// 2.5 Profil complet E1
MATCH (e:Etudiant {id: "E1"})
OPTIONAL MATCH (e)-[:CONNAIT]-(ami)
OPTIONAL MATCH (e)-[:SUIT]->(c)
OPTIONAL MATCH (e)-[:MAITRISE]->(comp)
RETURN e, collect(DISTINCT ami.prenom) AS amis, collect(DISTINCT c.intitule) AS cours, collect(DISTINCT comp.nom) AS competences;
