//
//  AddMedicationView.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 04/01/2024.
//

import SwiftUI

struct AddMedicationView: View {
    
    @State private var selectedFrequency: Frequency = .daily
    @State private var timesPerWeek: Int = 1
    @State private var timesPerMonth: Int = 1
    @State private var medicationName: String = ""
    @State private var dosageAmount: Int = 1
    @State private var currentPage = 1
    @State private var selectedForm: String = ""
    
    let sharedViewModel = SharedViewModel()
    
    @ObservedObject var viewModel = MedicationViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                // Page views...
                if currentPage == 1 {
                    PageOneView(selectedForm: $selectedForm, currentPage: $currentPage)
                } else if currentPage == 2 {
                    PageTwoView(medicationName: $medicationName, currentPage: $currentPage, viewModel: viewModel, selectedForm: $selectedForm)
                } else if currentPage == 3 {
                    PageThreeView(selectedFrequency: $selectedFrequency, currentPage: $currentPage, SviewModel: sharedViewModel, viewModel: viewModel, authViewModel: authViewModel)
                } else if currentPage == 4 {
                    VStack {
                        PageFourView(
                            timesPerWeek: $timesPerWeek,
                            timesPerMonth: $timesPerMonth,
                            currentPage: $currentPage,
                            SviewModel: sharedViewModel,
                            viewModel: viewModel,
                            authViewModel: authViewModel
                        )

                        Spacer()

                        NextButtonSection
                    }

                } else if currentPage == 5 {
                    VStack {
                        PageFiveView(
                            dosageAmount: $dosageAmount,
                            currentPage: $currentPage,
                            SviewModel: sharedViewModel,
                            viewModel: viewModel,
                            authViewModel: authViewModel
                        )

                        Spacer()

                        addButtonSection
                    }
                }

                Spacer()
            
            }
            .background(Color(UIColor.systemBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if currentPage > 1 {
                        backButton
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.primary)
                    }

                }
            }
            
        }
        .background(Color(UIColor.systemBackground))
        
        
        
        
    }
    
    var addButtonSection: some View {
        Section {
            
            Button(action: {
                // Action for adding medication
                if let userID = authViewModel.currentUser?.id {
                    let frequencyValue = selectedFrequency.rawValue

                    viewModel.addMedication(
                        for: userID,
                        medicationName: medicationName,
                        dosageAmount: dosageAmount,
                        form: selectedForm,
                        frequency: frequencyValue,
                        timesPerWeek: timesPerWeek,
                        timesPerMonth: timesPerMonth
                    )
                    
                    dismiss()
                }
            }) {
                Text("Add Medication")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 343, height: 58)
            }
            .background(Color(red: 0/255, green: 167/255, blue: 255/255))
            .cornerRadius(15)
            .padding(.top, 32)

        }
    }
    
    var NextButtonSection: some View {
        Section {
            Spacer()
            
            Button(action: {
                // Action for adding medication
                currentPage += 1
            }) {
                Text("Next")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 343, height: 58)
            }
            .background(Color(red: 0/255, green: 167/255, blue: 255/255))
            .cornerRadius(15)
            .padding(.top, 32)

        }
        .background(Color.white)
    }
    
    var backButton: some View {
        Button(action: {
            // Decrease currentPage to navigate back
            if currentPage > 1 {
                if currentPage == 5 {
                    currentPage -= 2
                } else{
                    currentPage -= 1
                }
            }
                
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(Color.primary)
        }
    }
}



struct PageOneView: View {
    @Binding var selectedForm: String
    @Binding var currentPage: Int

    var body: some View {
        // Content for Page 1
        VStack(alignment: .leading, spacing: 30) {
            Text("What kind of medication is it?")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .center) {
                                
                Image("Pill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .padding(7)
                    .background(
                        Circle()
                            .foregroundColor(Color(UIColor.systemGray4))
                            .frame(width: 75, height: 75)
                        
                    )
                    .onTapGesture{
                        selectedForm = "Pill"
                        currentPage = 2
                    }
                
                Spacer()
                
                Image("Oint")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .padding(7)
                    .background(
                        Circle()
                            .foregroundColor(Color(UIColor.systemGray4))
                            .frame(width: 75, height: 75)
                        
                    )
                    .onTapGesture{
                        selectedForm = "Oint"
                        currentPage = 2
                    }
                
                Spacer()
                
                Image("Solution")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .padding(7)
                    .background(
                        Circle()
                            .foregroundColor(Color(UIColor.systemGray4))
                            .frame(width: 75, height: 75)
                    )
                    .onTapGesture{
                        selectedForm = "Solution"
                        currentPage = 2
                    }
                
                Spacer()
                
                Image("Gas")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .padding(7)
                    .background(
                        Circle()
                            .foregroundColor(Color(UIColor.systemGray4))
                            .frame(width: 75, height: 75)
                        
                    )
                    .onTapGesture{
                        selectedForm = "Gas"
                        currentPage = 2
                    }
            }
            .frame(maxWidth: .infinity) // Make HStack take the full width
            .padding(.horizontal, 12)
        }
        .padding(.horizontal, 24)
    }
}

//struct zPageTwoView: View {
//    @Binding var medicationName: String
//    @Binding var currentPage: Int
//    @ObservedObject var viewModel: MedicationViewModel
//    @Binding var selectedForm: String
//    
//    @StateObject private var medicationListVM = MedicationListViewModel()
//    @State private var searchText: String = ""
//
//    var body: some View {
//        NavigationView {
//            VStack(alignment: .leading, spacing: 20) {
//                Text("What's the name of the medication?")
//                    .font(.system(size: 20, weight: .bold))
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .foregroundColor(Color.primary)
//                    .padding(.horizontal, 24)
//                
//                
//                List(medicationListVM.results, id: \.brand_name) { medication in
//                    HStack {
//                        Text(medication.brand_name)
//                            .foregroundColor(Color.primary)
//                            .font(.system(size: 18))
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                        Image(systemName: "chevron.right")
//                    }
//                    .padding(.vertical, 9)
//                    .overlay(
//                        Rectangle()
//                            .frame(height: 1)
//                            .foregroundColor(Color(UIColor.systemGray5)), alignment: .bottom
//                    )
//                }
//                .listStyle(.plain)
//                .searchable(text: $searchText)
//                .onChange(of: searchText) { value in
//                    Task.init {
//                        if !value.isEmpty && value.count > 2 {
//                            await medicationListVM.search(name: value)
//                        } else {
//                            medicationListVM.results.removeAll()
//                        }
//                    }
//                }
//            }
//            .padding(.top, 20)
//        }
//    }
//}

struct PageTwoView: View {
    @Binding var medicationName: String
    @Binding var currentPage: Int
    @ObservedObject var viewModel: MedicationViewModel
    @Binding var selectedForm: String
    
    @StateObject private var medicationListVM = MedicationListViewModel()
    @State private var searchText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What's the name of the medication?")
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.primary)
                .padding(.horizontal, 24)
            
            VStack(alignment: .center) {
                TextField("Type medication name", text: $medicationName)
                    .foregroundColor(Color.primary)
                    .frame(width: UIScreen.main.bounds.width - 50, height: 45)
                    .padding(.horizontal, 12)
                    .background(Color(UIColor.systemGray4).opacity(0.7)) // Custom background color
                    .cornerRadius(40) // Corner radius
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color(UIColor.systemGray4), lineWidth: 1) // Stroke with custom color
                    )
            }
            .frame(maxWidth: .infinity)
            .onChange(of: medicationName) { value in
                Task.init {
                    if !value.isEmpty && value.count > 2 {
                        await medicationListVM.search(name: value)
                    } else {
                        medicationListVM.results.removeAll()
                    }
                }
            }

            
            ScrollView {
                VStack(alignment: .leading, spacing: 9) {
                    ForEach(medicationListVM.results, id: \.medicationName) { suggestion in
                        HStack {
                            Text(suggestion.medicationName)
                                .foregroundColor(Color.primary)
                                .font(.system(size: 18))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Image(systemName: "chevron.right")
                        }
                        .padding(.bottom, 9)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(UIColor.systemGray5)), alignment: .bottom
                        )
                        .onTapGesture {
                            medicationName = suggestion.medicationName
                            currentPage = 3
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
            .listRowInsets(EdgeInsets()) // Remove default padding from the List or Form
            .listRowBackground(Color.clear)
        }
        .padding(.top, 20) // Add padding at the top of the VStack if needed
    }
}


enum Frequency: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case timesPerWeek = "X times per week"
    case timesPerMonth = "X times per month"
    
    var id: String { self.rawValue }
}

struct PageThreeView: View {
    
    
    @Binding var selectedFrequency: Frequency
    @Binding var currentPage: Int
    @ObservedObject var SviewModel: SharedViewModel
    var viewModel: MedicationViewModel
    var authViewModel: AuthViewModel

    let phrases = [
        "I take it everyday",
        "I take it once a week",
        "I take it multiple times a week",
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How often do you take this?")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack{
                ForEach(phrases, id: \.self) { phrase in
                    HStack {
                        Text(phrase)
                            .font(.system(size: 18))
                            .foregroundColor(Color.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "chevron.right")
                    }
                    .padding(.bottom, 9)
                    .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
                    .onTapGesture {
                        
                        
                        if phrase.contains("I take it multiple times a week") {
                            SviewModel.MFreq = "week"
                            selectedFrequency = .timesPerWeek
                            currentPage = 4
                        } else if phrase.contains("I take it multiple times a month") {
                            SviewModel.MFreq = "month"
                            selectedFrequency = .timesPerMonth
                            currentPage = 4
                        } else if phrase.contains("I take it everyday") {
                            selectedFrequency = .daily
                            currentPage = 5
                        } else if phrase.contains("I take it once a week") {
                            selectedFrequency = .weekly
                            currentPage = 5
                        } else if phrase.contains("I take it multiple times a month") {
                            selectedFrequency = .monthly
                            currentPage = 5
                        }
                    }
                    
                }
                
            }
        }
        .padding(.horizontal, 24)
    }
}

struct PageFourView: View {
    
    @Binding var timesPerWeek: Int
    @Binding var timesPerMonth: Int
    @State private var selectedNumberForWeek: Int = 1
    @State private var selectedNumberForMonth: Int = 1
    @Binding var currentPage: Int
    
    @ObservedObject var SviewModel: SharedViewModel
    var viewModel: MedicationViewModel
    var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How many times a \(SviewModel.MFreq)?")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .center) {
                ForEach(1...4, id: \.self) { number in
                    Text("\(number)")
                        .frame(width: 40, height: 40)
                        .background(Circle().foregroundColor(getCircleColor(for: number)))
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .onTapGesture {
                            if SviewModel.MFreq == "week" {
                                timesPerWeek = number
                                selectedNumberForWeek = number
                            } else if SviewModel.MFreq == "month" {
                                timesPerMonth = number
                                selectedNumberForMonth = number
                            }
                        }
                    if number < 4 {
                        Spacer()
                    }
                }
            }

            VStack(alignment: .center) {
                if SviewModel.MFreq == "week" {
                    Stepper("Times per week: \(timesPerWeek)", value: $timesPerWeek, in: 1...7)
                        .onChange(of: timesPerWeek) { newValue in
                            selectedNumberForWeek = newValue
                        }
                } else if SviewModel.MFreq == "month" {
                    Stepper("Times per month: \(timesPerMonth)", value: $timesPerMonth, in: 1...31)
                        .onChange(of: timesPerMonth) { newValue in
                            selectedNumberForMonth = newValue
                        }
                }
            }
            .frame(maxWidth: .infinity)
            
        }
        .padding(.horizontal, 24)
        
    }
    
    private func getCircleColor(for number: Int) -> Color {
            if SviewModel.MFreq == "week" && selectedNumberForWeek == number {
                return Color(red: 0/255, green: 167/255, blue: 255/255)
            } else if SviewModel.MFreq == "month" && selectedNumberForMonth == number {
                return Color(red: 0/255, green: 167/255, blue: 255/255)
            } else {
                return Color.gray
            }
        }
}

struct PageFiveView: View {
    
    @Binding var dosageAmount: Int
    @Binding var currentPage: Int
    @State private var selectedNumber: Int = 1
    
    @ObservedObject var SviewModel: SharedViewModel
    var viewModel: MedicationViewModel
    var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How many times per day do you take this medication?")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .center) {
                ForEach(1...4, id: \.self) { number in
                    Text("\(number)")
                        .frame(width: 40, height: 40)
                        .background(Circle().foregroundColor(selectedNumber == number ? Color(red: 0/255, green: 167/255, blue: 255/255) : Color.gray)) // Conditional background color
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .onTapGesture {
                            selectedNumber = number
                            dosageAmount = number
                        }

                    if number < 4 {
                        Spacer()
                    }
                }
            }
            
            VStack(alignment: .center) {
                Stepper("Times per day: \(dosageAmount)", value: $dosageAmount, in: 1...10)
                    .onChange(of: dosageAmount) { newValue in
                        selectedNumber = newValue
                    }
            }
            .frame(maxWidth: .infinity)
            
        }
        .padding(.horizontal, 24)
        
    }
}


class SharedViewModel: ObservableObject {
    @Published var MFreq: String = ""
    
    
}
