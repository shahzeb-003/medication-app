//
//  MedicationRow.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 04/01/2024.
//

import SwiftUI

struct MedicationRow: View {
    var medication: Medication // Replace with your actual Medication model
    @ObservedObject var viewModel = MedicationViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showingDeleteMedicationAlert = false
    @State private var medicationToDelete: Medication? = nil

    var body: some View {
        
        HStack(spacing: 17) {
            
            Image(medication.form)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 65, height: 65)

            
            VStack(alignment: .leading, spacing: 2) {
                Text(medication.medicationName.count > 30 ? "\(medication.medicationName.prefix(27).uppercased())..." : medication.medicationName.uppercased())
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)
                    .font(.headline)
                    .padding(.bottom, 5)
                Text("\(medication.dosageAmount) each day")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.secondary)
                if medication.frequency == "X times per week" {
                    Text("Taken \(medication.timesPerWeek) time(s) per week")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.secondary)
                }
                else if medication.frequency == "X times per month"{
                    Text("Taken \(medication.timesPerWeek) time(s) per month")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.secondary)
                }
                else {
                    Text("Taken \(medication.frequency)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.secondary)
                }
            }
            .frame(maxWidth: 300, alignment: .leading)
            .clipped()
        }
    }
}

