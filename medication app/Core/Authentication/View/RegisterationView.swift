//
//  RegisterationView.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 14/11/2023.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullname = ""
    @State private var confirmPassword = ""
    @State private var password = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var startTime = Date()
    @State private var endTime = Date()


    
    var body: some View {
        NavigationStack{
            VStack {
                
                VStack(alignment: .leading) {
                    Text("Hello! Register to get started!")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundColor(Color.primary)
                        .multilineTextAlignment(.leading)
                    // Add any other left-aligned content here
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                
                
                
                VStack(spacing: 15) {
                    
                    
                    InputView(text: $email,
                              placeholder: "name@example.com")
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    
                    InputView(text: $fullname,
                              placeholder: "Enter your name")
                    
                    DatePicker("Waking Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.horizontal, 18) // Padding around the text field
                        .padding(.top, 11) // Add padding inside the text field
                        .padding(.bottom, 11)// Corner radius
                        .frame(maxWidth: .infinity)
                        .background(Color.primary.opacity(0.1))
                        .cornerRadius(8)

                    // End Time Picker
                    DatePicker("Sleeping Time", selection: $endTime, displayedComponents: .hourAndMinute)
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.horizontal, 18) // Padding around the text field
                        .padding(.top, 11) // Add padding inside the text field
                        .padding(.bottom, 11)// Corner radius
                        .frame(maxWidth: .infinity)
                        .background(Color.primary.opacity(0.1))
                        .cornerRadius(8)
                    
                    InputView(text: $password,
                              placeholder: "Enter your password",
                              isSecureField: true)
                    
                    ZStack(alignment: .trailing) {
                        InputView(text: $confirmPassword,
                                  placeholder: "Confirm your password",
                                  isSecureField: true)
                        
                        if !password.isEmpty && confirmPassword.isEmpty {
                            if password == confirmPassword {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.systemGreen))
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.systemRed))
                            }
                        }
                    }
                    
                }
                .padding(.top, 32)
                
                
                Button {
                    Task {
                        try await viewModel.createUser(withEmail: email, password: password, fullname: fullname, startTime: startTime, endTime: endTime)
                            
                    }
                } label: {
                    Text("Register")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 343, height: 58)
                }
                .background(Color(red: 0/255, green: 167/255, blue: 255/255))
                .cornerRadius(15)
                .padding(.top, 32)
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                
                VStack {
                    Spacer() // This pushes everything below it to the bottom
                    
                    NavigationLink {
                        LoginView()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarItems(leading: BackButtonView())
                    } label: {
                        HStack(spacing: 2) {
                            Text("Already have an account?")
                                .foregroundColor(Color.primary)
                                .font(.system(size: 15, weight: .semibold))
                            
                                
                            Text("Login")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color(red: 0/255, green: 167/255, blue: 255/255))
                        }
                        .font(.system(size: 14))
                    }
                    .padding(.bottom, 20) // Adds padding at the bottom
                    
                }
                
                
            }
            .padding(.horizontal, 24)
            
        }
    }
        
}

// Mark: - AuthenticationFormProtocol

extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && !fullname.isEmpty
        && confirmPassword == password
    }
}
