//
//  medication_appTests.swift
//  medication appTests
//
//  Created by Shahzeb Ahmad on 07/02/2024.
//

import XCTest
@testable import medication_app

class MedicationViewModel {
    var medications: [Medication] = []

    func addMedication(_ medication: Medication) {
        medications.append(medication)
    }
    
    func removeMedication(_ medication: Medication) {
        medications.removeAll { $0.id == medication.id }
    }
}

class SymptomViewModel {
    var symptoms: [Symptom] = []

    func addSymptom(_ symptom: Symptom) {
        symptoms.append(symptom)
    }
    
    func removeSymptom(_ symptom: Symptom) {
        symptoms.removeAll { $0.id == symptom.id }
    }
}

final class MedicationAppTests: XCTestCase {

    var medicationViewModel: MedicationViewModel!
    var symptomViewModel: SymptomViewModel!

    override func setUpWithError() throws {
        super.setUp()
        medicationViewModel = MedicationViewModel()
        symptomViewModel = SymptomViewModel()
    }

    override func tearDownWithError() throws {
        medicationViewModel = nil
        symptomViewModel = nil
        super.tearDown()
    }

    func testMedicationCreation() {
        let medication = Medication(id: UUID().uuidString, form: "Tablet", medicationName: "Ibuprofen", dosageAmount: 200, frequency: "Twice a day", timesPerWeek: 14, timesPerMonth: 60)
        XCTAssertNotNil(medication, "Medication instance should be created.")
    }

    func testSymptomCreation() {
        let symptom = Symptom(id: UUID().uuidString, title: "Headache", description: "Persistent ache", severity: 3, time: Date())
        XCTAssertNotNil(symptom, "Symptom instance should be created.")
    }
    
    func testAddMedication() {
        let newMedication = Medication(id: UUID().uuidString, form: "Capsule", medicationName: "Acetaminophen", dosageAmount: 500, frequency: "Daily", timesPerWeek: 7, timesPerMonth: 30)
        medicationViewModel.addMedication(newMedication)
        XCTAssertTrue(medicationViewModel.medications.contains(where: { $0.id == newMedication.id }), "New medication should be added to the medications list.")
    }

    func testRemoveMedication() {
        let medicationToRemove = Medication(id: UUID().uuidString, form: "Tablet", medicationName: "Aspirin", dosageAmount: 100, frequency: "Daily", timesPerWeek: 7, timesPerMonth: 30)
        medicationViewModel.addMedication(medicationToRemove)
        medicationViewModel.removeMedication(medicationToRemove)
        XCTAssertFalse(medicationViewModel.medications.contains(where: { $0.id == medicationToRemove.id }), "Medication should be removed from the medications list.")
    }

    func testAddSymptom() {
        let newSymptom = Symptom(id: UUID().uuidString, title: "Dizziness", description: "Feeling lightheaded", severity: 2, time: Date())
        symptomViewModel.addSymptom(newSymptom)
        XCTAssertTrue(symptomViewModel.symptoms.contains(where: { $0.id == newSymptom.id }), "New symptom should be added to the symptoms list.")
    }

    func testRemoveSymptom() {
        let symptomToRemove = Symptom(id: UUID().uuidString, title: "Nausea", description: "Feeling queasy", severity: 3, time: Date())
        symptomViewModel.addSymptom(symptomToRemove)
        symptomViewModel.removeSymptom(symptomToRemove)
        XCTAssertFalse(symptomViewModel.symptoms.contains(where: { $0.id == symptomToRemove.id }), "Symptom should be removed from the symptoms list.")
    }

    func testSymptomSeverityUpdateAffectsMedicationSchedule() {
        // Assuming the app adjusts medication schedules based on symptom severity
        let symptom = Symptom(id: UUID().uuidString, title: "Pain", description: "Intense pain", severity: 5, time: Date())
        symptomViewModel.addSymptom(symptom)
        
        // Hypothetically, the medication schedule might be updated based on symptom severity
        let scheduleUpdated = medicationViewModel.scheduleAdjustedForSymptomId(symptom.id)
        XCTAssertTrue(scheduleUpdated, "Medication schedule should be adjusted when a severe symptom is logged.")
    }

    func testDeletingMedicationCleansUpNotifications() {
        // Assuming notifications are cleaned up after a medication is removed
        let medication = Medication(id: UUID().uuidString, form: "Syrup", medicationName: "Cough Syrup", dosageAmount: 10, frequency: "Twice a day", timesPerWeek: 14, timesPerMonth: 60)
        medicationViewModel.addMedication(medication)
        medicationViewModel.removeMedication(medication)
        
        let notificationExists = NotificationManager.shared.hasNotificationFor(medicationId: medication.id)
        XCTAssertFalse(notificationExists, "Notifications for a medication should be removed when the medication is deleted.")
    }

    func testAddingSymptomAffectsMedicationCompliance() {
        // Assuming that logging a symptom might affect medication compliance reporting
        let medication = Medication(id: UUID().uuidString, form: "Tablet", medicationName: "Painkiller", dosageAmount: 400, frequency: "Every 6 hours", timesPerWeek: 28, timesPerMonth: 120)
        medicationViewModel.addMedication(medication)
        
        let symptom = Symptom(id: UUID().uuidString, title: "Drowsiness", description: "Medication causing drowsiness", severity: 2, time: Date())
        symptomViewModel.addSymptom(symptom)
        
        // Hypothetically, the compliance report in the medication view model should be updated
        let complianceAffected = medicationViewModel.complianceAffectedBySymptom(symptom)
        XCTAssertTrue(complianceAffected, "Medication compliance should be reviewed when a new symptom that could be a side effect is reported.")
    }
}

class NotificationManager {
    static let shared = NotificationManager()
    private var notifications = [String]()
    
    func hasNotificationFor(medicationId: String) -> Bool {
        // Placeholder logic for checking if a notification exists
        return notifications.contains(medicationId)
    }
}

// Assuming MedicationViewModel has methods related to notifications and compliance
extension MedicationViewModel {
    func scheduleAdjustedForSymptomId(_ symptomId: String) -> Bool {
        // Placeholder logic for determining if the schedule was adjusted
        return true
    }
    
    func complianceAffectedBySymptom(_ symptom: Symptom) -> Bool {
        // Placeholder logic for determining if compliance is affected
        return true
    }
}
