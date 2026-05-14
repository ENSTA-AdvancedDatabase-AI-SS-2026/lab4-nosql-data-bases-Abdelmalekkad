use("medical_db");

// 2.1 Patients diabétiques > 50 ans à Alger
const q21 = db.patients.find({
  antecedents: "Diabète",
  dateNaissance: { $lt: new Date("1974-01-01") },
  "adresse.wilaya": "Alger"
}).toArray();
print("2.1 Patients:", q21.length);

// 2.2 Allergiques Pénicilline avec >= 3 consultations
const q22 = db.patients.find({
  allergies: "Pénicilline",
  "consultations.2": { $exists: true }
}).toArray();
print("2.2 Patients:", q22.length);

// 2.3 Projection Nom, Prénom, Dernière consultation
const q23 = db.patients.find({}, {
  nom: 1,
  prenom: 1,
  consultations: { $slice: -1 }
}).limit(5).toArray();
print("2.3 Result example:", JSON.stringify(q23[0]));

// 2.4 Sans antécédents, tension > 140
const q24 = db.patients.find({
  antecedents: { $size: 0 },
  "consultations.tension.systolique": { $gt: 140 }
}).toArray();
print("2.4 Patients:", q24.length);

// 2.5 Recherche textuelle
db.patients.createIndex({ "consultations.diagnostic": "text" });
const q25 = db.patients.find({ $text: { $search: "Diabète" } }).toArray();
print("2.5 Search results:", q25.length);
