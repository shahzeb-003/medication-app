//
//  MedicationView.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 04/01/2024.
//

import SwiftUI

struct MedicationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAddMedication = false
    @ObservedObject var viewModel = MedicationViewModel()
    
    @State private var showingDeleteMedicationAlert = false
    @State private var medicationToDelete: Medication? = nil
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) { // Adds 20 points of spacing between items
                        
                        Text("Medications")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(Color.primary)
                            .padding(.horizontal, 24)
                        
                        
                        ForEach(viewModel.medications) { medication in
                            VStack {
                                HStack {
                                    
                                    MedicationRow(medication: medication)
                                    
                                    Button(action: {
                                        medicationToDelete = medication
                                        showingDeleteMedicationAlert = true
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                            .imageScale(.medium)
                                            .font(.system(size: 25))
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .alert(isPresented: $showingDeleteMedicationAlert) {
                                        Alert(
                                            title: Text("Are you sure you want to delete \(medicationToDelete?.medicationName ?? "")?"),
                                            primaryButton: .destructive(Text("Yes")) {
                                                if let medicationID = medicationToDelete?.id, let userID = authViewModel.currentUser?.id {
                                                    viewModel.deleteMedication(userID: userID, medicationID: medicationID)
                                                    
                                                    viewModel.fetchMedications(for: userID)
                                                    
                                                }
                                            },
                                            secondaryButton: .cancel()
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 15)
                                .background {
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                                }
                                .clipped()
                            }
                            .frame(width: UIScreen.main.bounds.width - 32, alignment: .center)
                        }
                    }
                    .frame(maxWidth: .infinity) // Ensures the VStack takes full width available
                    .padding(.horizontal, 24) // Adds horizontal padding to the ScrollView
                    .padding(.top)
                }
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    if let userID = authViewModel.currentUser?.id {
                        viewModel.fetchMedications(for: userID)
                    }
                }
                
                
                Button(action: {
                    showingAddMedication = true
                }) {
                    Image(systemName: "plus")
                        .imageScale(.large)
                        .foregroundColor(.white)
                        .padding(20)
                        .background(Color(red: 0/255, green: 167/255, blue: 255/255))
                        .clipShape(Circle())
                        .shadow(radius: 10)
                }
                .padding()
            }
        }
        
        .sheet(isPresented: $showingAddMedication) {
            AddMedicationView(viewModel: viewModel)
                .environmentObject(authViewModel)
                .onDisappear {
                    if let userID = authViewModel.currentUser?.id {
                        viewModel.fetchMedications(for: userID)
                    }
                }
        }
    }
}


private func setWindowBackgroundColor(_ color: UIColor) {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let window = windowScene.windows.first
    {
        window.backgroundColor = color
    }
}

#Preview {
    MedicationView()
}
