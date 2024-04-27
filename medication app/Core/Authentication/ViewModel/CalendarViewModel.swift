//
//  CalendarViewModel.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 12/12/2023.
//

import Foundation
import FirebaseFirestore
import UserNotifications
import Combine

@MainActor
class CalendarViewModel: ObservableObject {
    
    @Published var needsRefresh: Bool = true
    
    private var db = Firestore.firestore()
    @Published var medications: [Medication] = []
    @Published var medicationsByTime: [Date: [Medication]] = [:]
    
    @Published var startTime: Date = Date()  // Default values, update from Firebase
    @Published var endTime: Date = Date()
    
    @Published var completedMedications: Set<String> = []
    
    private let calendar = Calendar.current
    
    @Published var completionPercentage: Int = 0
    

    init() {
        loadCompletedMedications()
    }

    func completionPercentageForToday() -> Int {
        let currentDate = Date()

        // Recalculate the total scheduled instances for today.
        let totalMedicationsToday = medications.flatMap { medication in
            determineNotificationTimes(for: medication)
        }.filter { calendar.isDate($0, inSameDayAs: currentDate) }.count

        // Ensure completedMedications only contains entries for existing medications.
        let validCompletedMedications = completedMedications.filter { (key) in
            let medicationId = key.components(separatedBy: "_").first ?? ""
            return medications.contains { $0.id == medicationId }
        }

        // Count completed instances for today.
        let completedMedicationsToday = validCompletedMedications.compactMap { key -> Date? in
            if let timeInterval = TimeInterval(key.components(separatedBy: "_").last ?? "") {
                return Date(timeIntervalSince1970: timeInterval)
            }
            return nil
        }.filter { calendar.isDate($0, inSameDayAs: currentDate) }.count

        guard totalMedicationsToday > 0 else { return 0 }
        let percentage = Double(completedMedicationsToday) / Double(totalMedicationsToday) * 100
        return Int(round(percentage))
    }

    
    func completeMedication(withId id: String, at time: Date) {
        let key = "\(id)_\(time.timeIntervalSince1970)"
        completedMedications.insert(key)
        saveCompletedMedications()
        groupMedicationsByTime()
    }

    func isMedicationCompleted(withId id: String, at time: Date) -> Bool {
        let key = "\(id)_\(time.timeIntervalSince1970)"
        return completedMedications.contains(key)
    }

    // Modify groupMedicationsByTime to filter out completed medications
    func groupMedicationsByTime() {
        var groupedMedications: [Date: [Medication]] = [:]
        for medication in medications {
            let times = determineNotificationTimes(for: medication)
            for time in times where !isMedicationCompleted(withId: medication.id, at: time) {
                groupedMedications[time, default: []].append(medication)
            }
        }
        self.medicationsByTime = groupedMedications
    }

    

    func fetchMedications(for userID: String, completion: @escaping () -> Void = {}) {
        let userDocumentRef = Firestore.firestore().collection("users").document(userID)
        
        userDocumentRef.getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error getting user data: \(error)")
            } else if let documentSnapshot = document, documentSnapshot.exists {
                // Fetch and convert startTime and endTime
                let userData = documentSnapshot.data()
                self?.startTime = self?.convertToTimeDate(userData?["startTime"] as? String) ?? Date()
                self?.endTime = self?.convertToTimeDate(userData?["endTime"] as? String) ?? Date()
            }

            // Fetch medications
            let userMedicationsRef = Firestore.firestore().collection("users").document(userID).collection("medications")
            userMedicationsRef.getDocuments { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error getting medications: \(error)")
                } else {
                    let allMedications: [Medication] = querySnapshot?.documents.compactMap { document in
                        let data = document.data()
                        return Medication(id: document.documentID,
                                          form: data["form"] as? String ?? "",
                                          medicationName: data["medicationName"] as? String ?? "",
                                          dosageAmount: data["dosageAmount"] as? Int ?? 1,
                                          frequency: data["frequency"] as? String ?? "",
                                          timesPerWeek: data["timesPerWeek"] as? Int ?? 1,
                                          timesPerMonth: data["timesPerMonth"] as? Int ?? 1)
                    } ?? []
                    
                    self?.medications = self?.filterMedications(medications: allMedications) ?? []
                    completion()
                }
            }
        }
    }
    
    private func convertToTimeDate(_ timeString: String?) -> Date? {
        guard let timeString = timeString else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"  // Match the format stored in Firebase
        return dateFormatter.date(from: timeString)
    }
    
    func filterMedications(medications: [Medication]) -> [Medication] {
        let currentDate = Date()

        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: currentDate)
        
        
        let filteredMedications = medications.filter { medication in
            switch medication.frequency {
            case "Daily":
                return true
            case "Weekly":
                // Assuming '1' is Sunday, '2' is Monday, etc.
                return dayOfWeek == 2 // Example: Only show on Mondays
            case "Monthly":
                let dayOfMonth = calendar.component(.day, from: currentDate)
                return dayOfMonth == 1
            case "x times per week":
                return medication.timesPerWeek > 0
            case "x times per month":
                return medication.timesPerMonth > 0
            default:
                return false
            }
        }
        
        return filteredMedications
    }
    
    func scheduleNotifications() {
        let filteredMeds = filterMedications(medications: medications)

        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            guard let self = self, granted, error == nil else {
                print("Notifications permission denied or error occurred: \(error?.localizedDescription ?? "")")
                return
            }

            // Clear existing notifications
            self.clearExistingNotifications()

            DispatchQueue.main.async {
                for medication in filteredMeds {
                    self.scheduleNotificationForMedication(medication)
                }
            }
        }
    }

    func clearExistingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let idsToRemove = requests.filter { $0.content.categoryIdentifier == "medicationReminder" }
                                      .map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idsToRemove)
        }
    }

    func scheduleNotificationForMedication(_ medication: Medication) {
        let notificationTimes = determineNotificationTimes(for: medication)

        for time in notificationTimes {
            let content = UNMutableNotificationContent()
            content.title = "Medication Reminder"
            content.body = "It's time to take your medication: \(medication.medicationName)"
            content.sound = .default
            content.categoryIdentifier = "medicationReminder" // Identifier for categorizing

            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current

            var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: time)
            if let currentDate = calendar.date(from: dateComponents), currentDate < Date() {
                dateComponents.day! += 1
            }

            let identifier = self.notificationIdentifier(for: medication, dateComponents: dateComponents)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            // Schedule the notification
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled for \(dateComponents)")
                }
            }
        }
    }

    private func notificationIdentifier(for medication: Medication, dateComponents: DateComponents) -> String {
        return "\(medication.medicationName)_\(dateComponents.year!)_\(dateComponents.month!)_\(dateComponents.day!)_\(dateComponents.hour!)_\(dateComponents.minute!)"
    }
    
    private func determineNotificationTimes(for medication: Medication) -> [Date] {
        let calendar = Calendar.current
        var times: [Date] = []

        // Adjust the startTime by adding 1 hour and rounding to the nearest half hour
        let adjustedStartTime = roundToNearestHalfHour(startTime, adjustingHours: 1)
        // Adjust the endTime by subtracting 1 hour and rounding to the nearest half hour
        let adjustedEndTime = roundToNearestHalfHour(endTime, adjustingHours: -1)

        let startComponents = calendar.dateComponents([.hour, .minute], from: adjustedStartTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: adjustedEndTime)

        guard let startHour = startComponents.hour, let endHour = endComponents.hour else {
            return []  // Return an empty array if hours can't be extracted
        }

        // Check if medication dosage amount is 1 to avoid division by zero
        if medication.dosageAmount == 1 {
            if let time = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: Date()) {
                times.append(time)
            }
            return times
        }

        let interval = (endHour - startHour) / (medication.dosageAmount - 1)
        
        for i in 0..<medication.dosageAmount {
            if let time = calendar.date(bySettingHour: startHour + (i * interval), minute: 0, second: 0, of: Date()) {
                times.append(time)
            }
        }
        
        return times
    }
    private func roundToNearestHalfHour(_ date: Date, adjustingHours hours: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        // Adjust hours
        components.hour? += hours
        
        // Round to nearest half hour
        if let minute = components.minute, minute % 30 != 0 {
            if minute < 30 {
                components.minute = 30
            } else {
                components.hour? += 1
                components.minute = 0
            }
        }
        
        // Safely unwrap the hour and minute components
        guard let roundedDate = calendar.date(from: components) else {
            return date // Return the original date if unwrapping fails
        }
        
        return roundedDate
    }
           


}

extension CalendarViewModel {
    func saveCompletedMedications() {
        UserDefaults.standard.set(Array(completedMedications), forKey: "completedMedications")
    }

    func loadCompletedMedications() {
        if let savedData = UserDefaults.standard.array(forKey: "completedMedications") as? [String] {
            completedMedications = Set(savedData)
        }
    }
}


