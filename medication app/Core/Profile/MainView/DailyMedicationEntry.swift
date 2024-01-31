//
//  DailyMedicationEntry.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 05/01/2024.
//

import SwiftUI

struct DailyMedicationEntry: Identifiable {
    var id: String // A unique identifier, possibly combining medication ID and time
    var medication: Medication
    var intakeTime: Date
    var isCompleted: Bool = false
}
