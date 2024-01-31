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
            // Remove duplicates
            let uniqueResults = Set(results).sorted { $0.brand_name < $1.brand_name }
            self.results = uniqueResults.map(MedicationNamesViewModel.init)
        } catch {
            print(error)
        }
    }

}

struct MedicationNamesViewModel {
    
    let medicationNames: MedicationNames
    
    var brand_name: String {
        medicationNames.brand_name
    }
}
