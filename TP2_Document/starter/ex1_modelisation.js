/**
 * TP2 - Exercice 1 : Modélisation MongoDB
 * Use Case : HealthCare DZ - Dossiers Médicaux
 */

// Se connecter à la base médicale
use("medical_db");

db.patients.drop();
db.analyses.drop();

db.createCollection("patients", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["cin", "nom", "prenom", "dateNaissance", "sexe"],
      properties: {
        cin: { bsonType: "string" },
        nom: { bsonType: "string" },
        prenom: { bsonType: "string" },
        dateNaissance: { bsonType: "date" },
        sexe: { enum: ["M", "F"] },
        adresse: {
          bsonType: "object",
          required: ["wilaya"],
          properties: {
            wilaya: { bsonType: "string" }
          }
        }
      }
    }
  }
});

const wilayas = ["Alger", "Oran", "Constantine", "Annaba", "Blida", "Setif", "Tlemcen"];
const noms = ["Bensalem", "Mansouri", "Haddad", "Belkacem", "Hamidi", "Ziane", "Abid"];
const prenoms = ["Ahmed", "Fatima", "Mohamed", "Lydia", "Yassine", "Amine", "Meriem"];
const pathologies = ["Diabète", "HTA", "Asthme", "Anémie"];

let patientsList = [];
for (let i = 0; i < 20; i++) {
  let p = {
    cin: "100000000" + i,
    nom: noms[i % noms.length],
    prenom: prenoms[i % prenoms.length],
    dateNaissance: new Date(1960 + i, 0, 1),
    sexe: i % 2 === 0 ? "M" : "F",
    adresse: { wilaya: wilayas[i % wilayas.length], commune: "Commune " + i },
    antecedents: [pathologies[i % pathologies.length]],
    allergies: i % 5 === 0 ? ["Pénicilline"] : [],
    consultations: []
  };
  
  for (let j = 0; j < 3; j++) {
    p.consultations.push({
      id: UUID(),
      date: new Date(2023, i % 12, j + 1),
      medecin: { nom: "Dr. Doctor", specialite: "Généraliste" },
      diagnostic: pathologies[i % pathologies.length],
      tension: { systolique: 120 + i, diastolique: 80 + i },
      medicaments: [{ nom: "Med " + j, dosage: "10mg", duree: "10 jours" }]
    });
  }
  patientsList.push(p);
}

db.patients.insertMany(patientsList);

const allPatients = db.patients.find().toArray();
let analysesList = [];
allPatients.forEach(p => {
  analysesList.push({
    patient_id: p._id,
    date: new Date(),
    type: "Glycémie",
    resultats: { valeur: 1.1 + (Math.random() * 0.5) },
    laboratoire: "Labo Central",
    valide: true
  });
});

db.analyses.insertMany(analysesList);

print("✅ Patients:", db.patients.countDocuments());
print("✅ Analyses:", db.analyses.countDocuments());
