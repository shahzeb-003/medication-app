//
//  SymptomRow.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 08/01/2024.
//

import SwiftUI

struct SymptomRow: View {
    var symptom: Symptom
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel = SymptomViewModel()
    
    @State private var showingDeleteAlert = false
    @State private var symptomToDeleteID: String? = nil


    var body: some View {
        HStack(spacing: 17) {
            VStack(alignment: .leading, spacing: 2) {
                Text(symptom.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)
                    .font(.headline)
                    .padding(.bottom, 5)
                
                Text("Severity: \(symptom.severity)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.secondary)
                
                Text("Reported on: \(symptom.time.formatted(.dateTime.month().day().hour().minute()))")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.secondary)
                
            }
            .frame(maxWidth: 300, alignment: .leading)
            .clipped()
        }
    }
}
