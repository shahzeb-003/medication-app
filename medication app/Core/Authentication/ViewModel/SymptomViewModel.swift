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

// ViewModel for managing symptoms related data
class SymptomViewModel: ObservableObject {
    // Published property to update the UI when the symptoms array changes
    @Published var symptoms: [Symptom] = []
    private var db = Firestore.firestore() // Reference to the Firestore database
    
    // Deletes a symptom from Firestore and updates the local symptoms array
    func deleteSymptom(userID: String, symptomID: String) {
        // Reference to the specific symptom document in Firestore
        let userSymptomRef = Firestore.firestore().collection("users").document(userID).collection("symptoms")
        userSymptomRef.document(symptomID).delete { error in // Firestore delete operation
            if let error = error { // Checks if there was an error during the delete operation
                print("Error removing symptom: \(error)")
            } else { // If deletion is successful
                print("Medication successfully removed!") // This message should say "Symptom" instead of "Medication"
                DispatchQueue.main.async { // Ensures UI updates are performed on the main thread
                    self.symptoms.removeAll { $0.id == symptomID } // Removes the symptom from the local array
                }
            }
        }
    }
    
    // Adds a new symptom document to Firestore and optionally updates the local symptoms array
    func addSymptom(for userID: String, title: String, description: String, severity: Int, time: Date) {
        let symptomData: [String: Any] = [ // Dictionary representing the symptom data
            "title": title, // Symptom title
            "description": description, // Symptom description
            "severity": severity, // Symptom severity level
            "time": Timestamp(date: time) // Symptom timestamp, converting Date to Firestore Timestamp
        ]

        // Adds a new document to the user's symptoms collection in Firestore
        db.collection("users").document(userID).collection("symptoms").addDocument(data: symptomData) { error in
            if let error = error { // Checks if there was an error during the add operation
                print("Error adding symptom: \(error)")
            } else { // If the document is successfully added
                print("Symptom added successfully!")
                // Optionally, the local symptoms array could be updated here to reflect the addition
            }
        }
    }

    // Fetches the symptoms from Firestore and updates the local symptoms array
    func fetchSymptoms(for userID: String) {
        // Reference to the user's symptoms collection in Firestore
        let userSymptomsRef = Firestore.firestore().collection("users").document(userID).collection("symptoms")

        // Fetches documents from the symptoms collection
        userSymptomsRef.getDocuments { (querySnapshot, error) in
            if let error = error { // Checks if there was an error during the fetch operation
                print("Error getting symptoms: \(error)")
            } else { // If the documents are successfully fetched
                // Maps Firestore documents to Symptom objects and updates the symptoms array
                self.symptoms = querySnapshot?.documents.compactMap { document in
                    let data = document.data()
                    let time = (data["time"] as? Timestamp)?.dateValue() ?? Date() // Converts Timestamp to Date
                    return Symptom(
                        id: document.documentID,
                        title: data["title"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        severity: data["severity"] as? Int ?? 1,
                        time: time
                    )
                } ?? []
            }
        }
    }
}
