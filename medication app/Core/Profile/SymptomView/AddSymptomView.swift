//
//  AddSymptomView.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 08/01/2024.
//

import SwiftUI

struct AddSymptomView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var severity: Int = 1
    @State private var time = Date()

    @ObservedObject var viewModel: SymptomViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var currentPage = 1

    var body: some View {
        NavigationView {
            VStack {
                // Page views...
                if currentPage == 1 {
                    VStack {
                        SymPageOneView(currentPage: $currentPage, description: $description)
                        
                        Spacer()
                        
                        NextButtonSection
                    }
                    
                } else if currentPage == 2 {
                    VStack {
                        SymPageTwoView(currentPage: $currentPage, severity: $severity)
                        
                        Spacer()
                        
                        NextButtonSection
                    }
                    
                } else if currentPage == 3 {
                    VStack {
                        SymPageThreeView(currentPage: $currentPage, time: $time)
                        
                        Spacer()
                        
                        NextButtonSection
                    }
                    
                } else if currentPage == 4 {
                    VStack {
                        SymPageFourView(currentPage: $currentPage, title: $title)
                        
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
                    viewModel.addSymptom(
                        for: userID,
                        title: title,
                        description: description,
                        severity: severity,
                        time: time
                    )
                }
                
                dismiss()
            }) {
                Text("Add Symptom")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 343, height: 58)
            }
            .background(title.isEmpty ? Color.gray : Color(red: 0/255, green: 167/255, blue: 255/255))
            .cornerRadius(15)
            .padding(.top, 32)

        }
    }
    
    var NextButtonSection: some View {
        Section {
            Spacer()
            
            Button(action: {
                currentPage += 1
            }) {
                Text("Next")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 343, height: 58)
            }
            .background(description.isEmpty ? Color.gray : Color(red: 0/255, green: 167/255, blue: 255/255))
            .cornerRadius(15)
            .disabled(description.isEmpty) // Disable the button if the description is empty
            .padding(.top, 32)
        }
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


struct SymPageOneView: View {
    @Binding var currentPage: Int
    @Binding var description: String
    
    var body: some View {
        VStack(spacing: 20) {
            
            VStack(spacing: 5) {
                
                Text("What are you experiencing?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("We recommend going into full detail.")
                    .font(.system(size: 10, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color.secondary)
            }
            
            
            TextEditor(text: $description)
                .frame(minHeight: 45, maxHeight: .infinity) // Allow dynamic height
                .padding(.horizontal, 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary, lineWidth: 1) // Stroke with custom color
                )
        }
        .padding(.horizontal, 24)
        
    }
}

struct SymPageTwoView: View {
    
    @Binding var currentPage: Int
    @Binding var severity: Int

    
    @State private var sliderValue: Double

    init(currentPage: Binding<Int>, severity: Binding<Int>) {
        self._currentPage = currentPage
        self._severity = severity
        self._sliderValue = State(initialValue: Double(severity.wrappedValue))
    }
    
    // Emojis for each severity level
    let emojis = ["😄", "🙂", "🤗", "😐", "😕", "😟", "🙁", "😮", "😠", "😡"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How severe is this symptom?")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Numbers above the slider
            HStack {
                ForEach(1...10, id: \.self) { number in
                    Text("\(number)")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.primary)
                }
            }
            
            CustomSlider(value: $sliderValue, range: (1, 10), step: 1)
                .frame(height: 25)
                .onChange(of: sliderValue) { newValue in
                    severity = Int(newValue)
                }
            
            // Emojis below the slider
            HStack {
                ForEach(emojis.indices, id: \.self) { index in
                    Text(emojis[index])
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 24)
        
    }

}


struct CustomSlider: View {
    @Binding var value: Double // Expecting a value between 0 and 1 for simplicity
    var range: (Double, Double) // The range of your slider (e.g., 1...10)
    var step: Double
    
    private func normalizeValue(_ value: Double) -> Double {
        // Normalize value to a 0-1 scale based on the range
        return (value - range.0) / (range.1 - range.0)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 5)
                    .foregroundColor(Color.secondary)
                
                Rectangle()
                    .frame(width: 30, height: 17)
                    .foregroundColor(Color(red: 0/255, green: 167/255, blue: 255/255))
                    .offset(x: normalizeValue(self.value) * geometry.size.width - 12.5) // Offset to center the thumb
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged({ drag in
                                // Calculate value based on drag location
                                let sliderPos = drag.location.x / geometry.size.width
                                let sliderValue = sliderPos * (range.1 - range.0) + range.0
                                // Adjust to step if needed
                                self.value = round(sliderValue / step) * step
                            })
                    )
            }
        }
    }
}

struct SymPageThreeView: View {
    @Binding var currentPage: Int
    @Binding var time: Date
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 5) {
                Text("When did you experience this?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("We recommend being as exact as possible")
                    .font(.system(size: 10, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color.secondary)
            }
            
            // Set the maximum date to today for the date picker
            DatePicker("Date", selection: $time, in: ...Date(), displayedComponents: .date)
            // Assuming you want to keep the time picker unrestricted since it's based on the same $time binding
            DatePicker("Time", selection: $time, in: ...Date(), displayedComponents: .hourAndMinute)
        }
        .padding(.horizontal, 24)
        
    }
    
}

struct SymPageFourView: View {
    @Binding var currentPage: Int
    @Binding var title: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Give this a title:")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Title Here", text: $title)
                .frame(width: UIScreen.main.bounds.width - 50, height: 45)
                .padding(.horizontal, 12)
                .background(Color(UIColor.systemGray4).opacity(0.7)) // Custom background color
                .cornerRadius(40) // Corner radius
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.secondary, lineWidth: 1) // Stroke with custom color
                )
        }
        .padding(.horizontal, 24)
        
    }
    
}
