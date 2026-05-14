// TP4 - Exercice 1 : Création du graphe UniConnect DZ
// Effacer la base pour partir propre
MATCH (n) DETACH DELETE n;

// ─── 1.1 : Contraintes d'unicité ─────────────────────────────────────────────
CREATE CONSTRAINT etudiant_id IF NOT EXISTS FOR (e:Etudiant) REQUIRE e.id IS UNIQUE;
CREATE CONSTRAINT cours_code IF NOT EXISTS FOR (c:Cours) REQUIRE c.code IS UNIQUE;
CREATE CONSTRAINT competence_nom IF NOT EXISTS FOR (c:Competence) REQUIRE c.nom IS UNIQUE;

// ─── 1.2 : Créer les compétences ──────────────────────────────────────────────
UNWIND [
  {nom: "Python", categorie: "Programmation"},
  {nom: "Java", categorie: "Programmation"},
  {nom: "SQL", categorie: "Bases de Données"},
  {nom: "NoSQL", categorie: "Bases de Données"},
  {nom: "Machine Learning", categorie: "IA"},
  {nom: "Deep Learning", categorie: "IA"},
  {nom: "React", categorie: "Web"},
  {nom: "Docker", categorie: "DevOps"},
  {nom: "Linux", categorie: "Systèmes"},
  {nom: "Réseaux", categorie: "Infrastructure"}
] AS comp
MERGE (:Competence {nom: comp.nom, categorie: comp.categorie});

// ─── 1.3 : Créer les cours ────────────────────────────────────────────────────
UNWIND [
  {code: "INFO401", intitule: "Bases de Données Avancées", credits: 6, dept: "Informatique"},
  {code: "INFO402", intitule: "Intelligence Artificielle", credits: 6, dept: "Informatique"},
  {code: "INFO403", intitule: "Développement Web", credits: 4, dept: "Informatique"},
  {code: "INFO404", intitule: "Systèmes Distribués", credits: 5, dept: "Informatique"},
  {code: "INFO405", intitule: "Cloud Computing", credits: 4, dept: "Informatique"}
] AS cours
MERGE (:Cours {code: cours.code, intitule: cours.intitule, 
               credits: cours.credits, departement: cours.dept});

UNWIND range(1, 50) AS i
WITH i, ["USTHB", "UMBB", "USTO", "UMC", "UBMA"][i % 5] AS uni,
     ["Informatique", "Mathématiques", "Electronique", "Telecoms", "GL"][i % 5] AS fil,
     ["Alger", "Oran", "Constantine", "Annaba", "Blida"][i % 5] AS ville
MERGE (e:Etudiant {id: "E" + i})
SET e.prenom = "Prenom" + i, e.nom = "Nom" + i, e.universite = uni, e.filiere = fil, e.annee = (i % 5) + 1, e.ville = ville;

MATCH (e1:Etudiant), (e2:Etudiant)
WHERE e1.id <> e2.id AND (toInteger(substring(e1.id, 1)) % 10 = toInteger(substring(e2.id, 1)) % 10 OR toInteger(substring(e1.id, 1)) + 1 = toInteger(substring(e2.id, 1)))
MERGE (e1)-[:CONNAIT {depuis: 2020}]-(e2);

MATCH (e:Etudiant), (c:Cours)
WHERE toInteger(substring(e.id, 1)) % 5 = toInteger(substring(c.code, 4)) % 5
MERGE (e)-[:SUIT {note: 10 + (toInteger(substring(e.id, 1)) % 10)}]-(c);

MATCH (e:Etudiant), (comp:Competence)
WHERE toInteger(substring(e.id, 1)) % 3 = 0
MERGE (e)-[:MAITRISE {niveau: "Intermédiaire"}]-(comp);
