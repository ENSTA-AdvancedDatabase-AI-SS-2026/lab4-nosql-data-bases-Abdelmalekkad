/**
 * TP2 - Exercice 4 : Index et Optimisation
 */

use("medical_db");

use("medical_db");

db.patients.dropIndexes();
db.analyses.dropIndexes();

db.patients.createIndex({ "adresse.wilaya": 1, antecedents: 1 });
db.patients.createIndex({ "consultations.date": 1 });
db.patients.createIndex({ "consultations.diagnostic": "text" });
db.analyses.createIndex({ patient_id: 1 });

const requeteTest = { "adresse.wilaya": "Alger", antecedents: "Diabète" };

print("=== Performance Analysis ===");
const stats = db.patients.find(requeteTest).explain("executionStats").executionStats;
print("Docs returned:", stats.nReturned);
print("Docs examined:", stats.totalDocsExamined);
print("Execution time (ms):", stats.executionTimeMillis);

db.analyses.createIndex({ date: 1 }, { expireAfterSeconds: 5 * 365 * 24 * 60 * 60 });
print("✅ Indexes created.");
