//
//  ScheduledMedication.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 07/01/2024.
//

import SwiftUI

struct ScheduledMedication: Codable, Identifiable {
    let id: String
    let medication: Medication
    let scheduledTime: Date
}
