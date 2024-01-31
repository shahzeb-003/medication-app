//
//  LoginView.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 14/11/2023.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack{
            VStack{
                
                Text("Welcome back! Glad to see you, Again!")
                    .font(.system(size: 35, weight: .bold))
                    .foregroundColor(Color.primary)
                    .padding(.top, 20)
                    .multilineTextAlignment(.leading)


                VStack(spacing: 15) {

                    InputView(text: $email, placeholder: "Enter your email", isSecureField: false)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    
                    InputView(text: $password, placeholder: "Enter your password", isSecureField: true)
                    
                }
                .padding(.top, 32)
                
                // sign in button
                Button {
                    Task {
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                } label: {
                    Text("Login")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 343, height: 58)
                }
                .background(Color(red: 0/255, green: 167/255, blue: 255/255))
                .cornerRadius(15)
                .padding(.top, 32)
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
            
                
                
                
                // sign up button
                
                VStack {
                    Spacer() // This pushes everything below it to the bottom

                    NavigationLink {
                        RegistrationView()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarItems(leading: BackButtonView())
                    } label: {
                        HStack(spacing: 2) {
                            Text("Don't have an account?")
                                .foregroundColor(Color.primary)
                                .font(.system(size: 15, weight: .semibold))
                            
                                
                            Text("Sign up")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(red: 0/255, green: 167/255, blue: 255/255))
                        }
                        .font(.system(size: 14))
                    }
                    .padding(.bottom, 20) // Adds padding at the bottom
                }


            }
        }
        .padding(.horizontal, 24)
    }
}

// Mark: - AuthenticationFormProtocol

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

#Preview {
    LoginView()
}
