//
//  InitialView.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 03/01/2024.
//

import SwiftUI

struct InitialView: View {
    var body: some View {
        NavigationStack{
            VStack{
                Image("InitlalImage")
                    .resizable()
                    .frame(width: 100, height: 80) // Set the frame size of the image
                
                Text("Never forget your medication again")
                    .font(.system(.title, weight: .heavy))
                    .foregroundColor(Color.primary)
                    .padding(.top, 20)
                    .multilineTextAlignment(.center)
                
                
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                        .navigationBarItems(leading: BackButtonView())
                } label: {
                    Text("Sign up")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.width - 32, height: 58)
                }
                .background(Color(red: 0/255, green: 167/255, blue: 255/255))
                .cornerRadius(15)
                .padding(.top, 110)
                
                
                NavigationLink {
                    LoginView()
                        .navigationBarBackButtonHidden(true)
                        .navigationBarItems(leading: BackButtonView())
                } label: {
                    Text("Log in")
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)
                        .frame(width: UIScreen.main.bounds.width - 32, height: 58)
                }
                .padding(.top, 10)
                
                
            }
        }
        .navigationBarItems(leading: BackButtonView())
        
        
        // Text: "Never forget your medication again"
        
        // Sign up button
        
        // Log in button
        
    }
        
        
        
        
}
