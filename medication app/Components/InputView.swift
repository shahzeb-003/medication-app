//
//  InputView.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 14/11/2023.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let placeholder: String
    var isSecureField = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text("")
                    .font(.system(size: 15, weight: .semibold)) // Custom font for placeholder
                    .foregroundColor(Color.primary)
                    .padding(.leading, 15)
                
            }
            
            if isSecureField {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 15, weight: .semibold))
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 15, weight: .semibold))
            }
        }
        .padding(.horizontal, 18) // Padding around the text field
        .padding(.top, 18) // Add padding inside the text field
        .padding(.bottom, 18)
        .background(Color.primary.opacity(0.05)) // Custom background color
        .cornerRadius(8) // Corner radius
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1) // Stroke with custom color
        )
        
        

    }
}

