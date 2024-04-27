//
//  BackButtonView.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 03/01/2024.
//

import SwiftUI

struct BackButtonView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(Color.primary)
            }
        }
    }
}
