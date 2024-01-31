//
//  AppModel.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 09/01/2024.
//

import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class AppModel: ObservableObject {
    static let shared = AppModel()

    @Published var authViewModel = AuthViewModel()
    @Published var medicationViewModel = MedicationViewModel()
    @Published var calendarViewModel = CalendarViewModel()
    @Published var symptomViewModel = SymptomViewModel()

    private init() {
        setupAuthenticationObserver()
    }

    private func setupAuthenticationObserver() {
        $authViewModel
            .compactMap { $0.userSession }
            .sink { [weak self] userSession in
                guard let self = self, let userID = userSession?.uid else { return }
                self.fetchInitialData(for: userID)
            }
            .store(in: &cancellables)
    }

    private func fetchInitialData(for userID: String) {
        // Fetch Medications, Symptoms, Calendar Data, etc.
        medicationViewModel.fetchMedications(for: userID)
        symptomViewModel.fetchSymptoms(for: userID)
        calendarViewModel.fetchMedications(for: userID) {
            self.calendarViewModel.groupMedicationsByTime()
            self.calendarViewModel.scheduleNotifications()
        }
    }

    private var cancellables = Set<AnyCancellable>()
}
