//
//  Symptom.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 08/01/2024.
//

import SwiftUI

struct Symptom: Identifiable {
    var id: String
    var title: String
    var description: String
    var severity: Int
    var time: Date
}
