import Foundation
import Combine
import FirebaseFirestore

class MedicationViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var medicationName: String = ""
    
    @Published var medicationSuggestions: [String] = []
    @Published var allMedications: [String] = []
    private var cancellables = Set<AnyCancellable>()
    private var db = Firestore.firestore()
    @Published var medications: [Medication] = []
    @Published var selectedForm: String = ""

    private let jsonFileName = "drug-ndc-0001-of-0001"
    private let jsonFileExtension = "json"
    private var dataTask: URLSessionDataTask?
    
    private var cachedMedications: CachedMedications?

    func fetchMedications(for userID: String) {
        let userMedicationsRef = Firestore.firestore().collection("users").document(userID).collection("medications")
        
        userMedicationsRef.getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting medications: \(error)")
            } else {
                self?.medications = querySnapshot?.documents.compactMap { document in
                    let data = document.data()
                    return Medication(id: document.documentID,
                                      form: data["form"] as? String ?? "",
                                      medicationName: data["medicationName"] as? String ?? "",
                                      dosageAmount: data["dosageAmount"] as? Int ?? 1,
                                      frequency: data["frequency"] as? String ?? "",
                                      timesPerWeek: data["timesPerWeek"] as? Int ?? 1,
                                      timesPerMonth: data["timesPerMonth"] as? Int ?? 1)
                } ?? []

                // Update the cached data
                self?.updateCachedMedications()
            }
        }
    }

    private func updateCachedMedications() {
        cachedMedications = CachedMedications(medications: medications)
        if let encoded = try? JSONEncoder().encode(cachedMedications) {
            UserDefaults.standard.set(encoded, forKey: "cachedMedications")
        }
    }
    
    func deleteMedication(userID: String, medicationID: String) {
        let userMedicationsRef = Firestore.firestore().collection("users").document(userID).collection("medications")
        userMedicationsRef.document(medicationID).delete { error in
            if let error = error {
                print("Error removing medication: \(error)")
            } else {
                print("Medication successfully removed!")
                DispatchQueue.main.async {
                    self.medications.removeAll { $0.id == medicationID }
                }
            }
        }
    }

    func addMedication(for userID: String, medicationName: String, dosageAmount: Int, form: String, frequency: String, timesPerWeek: Int?, timesPerMonth: Int?) {
        var medicationData: [String: Any] = [
            "form": form,
            "medicationName": medicationName,
            "dosageAmount": dosageAmount,
            "frequency": frequency
        ]
        
        if let times = timesPerWeek {
            medicationData["timesPerWeek"] = times
        }
        
        if let times = timesPerMonth {
            medicationData["timesPerMonth"] = times
        }
        
        db.collection("users").document(userID).collection("medications").addDocument(data: medicationData) { [weak self] error in
            if let error = error {
                print("Error adding medication: \(error)")
            } else {
                print("Medication added successfully!")
                // Assuming NotificationManager is a class you have for handling notifications
                NotificationManager.shared.scheduleNotificationForMedication(medicationName: medicationName)
            }
        }
    }
}

// Assuming the NotificationManager looks something like this
class NotificationManager {
    static let shared = NotificationManager()
    
    func scheduleNotificationForMedication(medicationName: String) {
        // Logic to schedule a notification
        print("Scheduling notification for medication: \(medicationName)")
    }
}
