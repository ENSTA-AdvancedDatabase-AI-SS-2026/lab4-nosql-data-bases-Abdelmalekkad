use("medical_db");

// 5.1 Joindre patients et analyses
const q51 = db.patients.aggregate([
  { $lookup: { from: "analyses", localField: "_id", foreignField: "patient_id", as: "dossier_analyses" } },
  { $limit: 1 }
]).toArray();
print("5.1 Dossier complet:", JSON.stringify(q51[0]));

// 5.2 Patients avec glycémie > 1.26 g/L
const q52 = db.analyses.aggregate([
  { $match: { type: "Glycémie", "resultats.valeur": { $gt: 1.26 } } },
  { $lookup: { from: "patients", localField: "patient_id", foreignField: "_id", as: "patient" } },
  { $unwind: "$patient" }
]).toArray();
print("5.2 Patients hyperglycémiques:", q52.length);

// 5.3 Statistiques croisées : analyses par wilaya
const q53 = db.analyses.aggregate([
  { $lookup: { from: "patients", localField: "patient_id", foreignField: "_id", as: "patient" } },
  { $unwind: "$patient" },
  { $group: { _id: "$patient.adresse.wilaya", count: { $sum: 1 }, avg_glycemie: { $avg: "$resultats.valeur" } } }
]).toArray();
printjson(q53);
