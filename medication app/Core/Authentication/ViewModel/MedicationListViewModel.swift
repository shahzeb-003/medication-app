//
//  MedicationListViewModel.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 20/01/2024.
//

import Foundation

@MainActor
class MedicationListViewModel: ObservableObject {
    
    @Published var results: [MedicationNamesViewModel] = []
    
    func search(name: String) async {
        do {
            let results = try await Webservice().getNames(searchTerm: name)
            // Since results are already strings, we assume MedicationNamesViewModel can be initialized with a string.
            // This step removes duplicates and creates view models for each unique medication name.
            let uniqueResults = Array(Set(results)).sorted() // Sort the unique results alphabetically
            self.results = uniqueResults.map { MedicationNamesViewModel(medicationName: $0) }
        } catch {
            print(error)
        }
    }


}

struct MedicationNamesViewModel {
    let medicationName: String
    
    // Assuming an initializer that accepts a medication name
    init(medicationName: String) {
        self.medicationName = medicationName
    }
}
