//
//  Medication.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 04/01/2024.
//

import Foundation

struct Medication: Identifiable, Codable {
    var id: String
    var form: String
    var medicationName: String
    var dosageAmount: Int
    var frequency: String
    var timesPerWeek: Int
    var timesPerMonth: Int
    
}

extension Medication: Equatable {
    static func == (lhs: Medication, rhs: Medication) -> Bool {
        return lhs.id == rhs.id // Assuming 'id' is a unique identifier for each medication
    }
}
