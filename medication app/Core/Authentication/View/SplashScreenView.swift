//
//  SplashScreenView.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 14/01/2024.
//

import SwiftUI


struct SplashScreenView: View {
    
    var body: some View {
        // Design your splash screen here
        ZStack {
            // Color(red: 0/255, green: 174/255, blue: 240/255)
            Color(UIColor.systemBackground)
            
            Image("SSDark") // Replace with your logo image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100) // Adjust size as needed
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            // Add any additional logic if needed for initialization
        }
    }
}


