//
//  MedicationNames.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 20/01/2024.
//

import Foundation

struct MedicationResponse: Decodable {
    let results: [MedicationNames]
}

struct MedicationNames: Decodable, Hashable {
    let brand_name: String
    let generic_name: String?
    
    // Implement Hashable
    static func ==(lhs: MedicationNames, rhs: MedicationNames) -> Bool {
        return lhs.brand_name.lowercased() == rhs.brand_name.lowercased()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(brand_name.lowercased())
    }
}
