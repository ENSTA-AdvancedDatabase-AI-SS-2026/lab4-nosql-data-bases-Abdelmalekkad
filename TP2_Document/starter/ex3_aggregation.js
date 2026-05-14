/**
 * TP2 - Exercice 3 : Pipelines d'Agrégation
 * Use Case : Statistiques médicales HealthCare DZ
 */

use("medical_db");

use("medical_db");

print("=== 3.1 : Top diagnostics par wilaya ===");
const diagParWilaya = db.patients.aggregate([
  { $unwind: "$consultations" },
  { $group: { _id: { wilaya: "$adresse.wilaya", diagnostic: "$consultations.diagnostic" }, count: { $sum: 1 } } },
  { $sort: { count: -1 } },
  { $limit: 20 }
]).toArray();
printjson(diagParWilaya);

print("\n=== 3.2 : Top médicaments par spécialité ===");
const medsParSpecialite = db.patients.aggregate([
  { $unwind: "$consultations" },
  { $unwind: "$consultations.medicaments" },
  { $group: { _id: { spec: "$consultations.medecin.specialite", med: "$consultations.medicaments.nom" }, count: { $sum: 1 } } },
  { $sort: { count: -1 } },
  { $group: { _id: "$_id.spec", topMed: { $first: "$_id.med" }, count: { $first: "$count" } } }
]).toArray();
printjson(medsParSpecialite);

print("\n=== 3.3 : Consultations par mois (12 derniers mois) ===");
const evolutionMensuelle = db.patients.aggregate([
  { $unwind: "$consultations" },
  { $group: { _id: { year: { $year: "$consultations.date" }, month: { $month: "$consultations.date" } }, count: { $sum: 1 } } },
  { $sort: { "_id.year": 1, "_id.month": 1 } }
]).toArray();
printjson(evolutionMensuelle);

print("\n=== 3.4 : Profil patients à risque élevé ===");
const patientsRisque = db.patients.aggregate([
  { $match: { antecedents: { $in: ["Diabète", "HTA"] } } },
  { $addFields: { num_cons: { $size: "$consultations" } } },
  { $group: { _id: null, avg_cons: { $avg: "$num_cons" }, count: { $sum: 1 } } }
]).toArray();
printjson(patientsRisque);

print("\n=== 3.5 : Top 5 médecins & taux de ré-consultation ===");
const rapportMedecins = db.patients.aggregate([
  { $unwind: "$consultations" },
  { $group: { _id: "$consultations.medecin.nom", total_cons: { $sum: 1 }, patients: { $addToSet: "$_id" } } },
  { $addFields: { unique_patients: { $size: "$patients" } } },
  { $addFields: { recons_rate: { $cond: [{ $gt: ["$unique_patients", 0] }, { $multiply: [{ $divide: [{ $subtract: ["$total_cons", "$unique_patients"] }, "$unique_patients"] }, 100] }, 0] } } },
  { $sort: { total_cons: -1 } },
  { $limit: 5 }
]).toArray();
printjson(rapportMedecins);
