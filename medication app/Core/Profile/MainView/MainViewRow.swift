//
//  MainViewRow.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 05/01/2024.
//

import SwiftUI

struct MainViewRow: View {
    var medication: Medication // Replace with your actual Medication model

    var body: some View {
        
        HStack(spacing: 17) {
            Image(medication.form)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 65, height: 65)

            
            VStack(alignment: .leading, spacing: 2) {
                Text(medication.medicationName.uppercased())
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)
                    .font(.headline)
                    .padding(.bottom, 5)
            }
            .frame(maxWidth: 300, alignment: .leading)
            .clipped()
        }
        .clipped()
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
}

