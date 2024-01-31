//
//  SymptomViewModel.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 23/12/2023.
//

import Foundation
import Combine
import FirebaseFirestore
import Firebase

class SymptomViewModel: ObservableObject {
    @Published var symptoms: [Symptom] = []
    private var db = Firestore.firestore()
    
    
    func deleteSymptom(userID: String, symptomID: String) {
        let userSymptomRef = Firestore.firestore().collection("users").document(userID).collection("symptoms")
        userSymptomRef.document(symptomID).delete { error in
            if let error = error {
                print("Error removing symptom: \(error)")
            } else {
                print("Medication successfully removed!")
                DispatchQueue.main.async {
                    self.symptoms.removeAll { $0.id == symptomID }
                }
            }
        }

    }
    
    func addSymptom(for userID: String, title: String, description: String, severity: Int, time: Date) {
        let symptomData: [String: Any] = [
            "title": title,
            "description": description,
            "severity": severity,
            "time": Timestamp(date: time)
        ]

        db.collection("users").document(userID).collection("symptoms").addDocument(data: symptomData) { error in
            if let error = error {
                print("Error adding symptom: \(error)")
            } else {
                print("Symptom added successfully!")
            }
        }
    }

    func fetchSymptoms(for userID: String) {
        let userSymptomsRef = Firestore.firestore().collection("users").document(userID).collection("symptoms")

        userSymptomsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting symptoms: \(error)")
            } else {
                self.symptoms = querySnapshot?.documents.compactMap { document in
                    let data = document.data()
                    let time = (data["time"] as? Timestamp)?.dateValue() ?? Date()
                    return Symptom(id: document.documentID,
                                   title: data["title"] as? String ?? "",
                                   description: data["description"] as? String ?? "",
                                   severity: data["severity"] as? Int ?? 1,
                                   time: time)
                } ?? []
            }
        }
    }
}
