//
//  MainView.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 29/11/2023.
//
import Combine
import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAddMedication = false
    @ObservedObject var viewModel = CalendarViewModel()
    @ObservedObject var MedviewModel = MedicationViewModel()
    

    var body: some View {
        NavigationView {
            List {
                
                VStack(spacing: 7) {
                    
                    if let user = authViewModel.currentUser {
                        Text("Hey, \(user.fullname)")
                            .font(.system(.subheadline, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    
                    Text("Today")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color.primary)
                }
                .listRowSeparator(.hidden)
                
                VStack {
                    HStack(spacing: 20) {
                        Text(completionText(percentage: viewModel.completionPercentageForToday()))
                            .font(.system(size: 24, weight: .bold))
                            .listRowSeparator(.hidden)
                            .foregroundColor(Color.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        PercentageCircleView(percentage: viewModel.completionPercentageForToday())
                            .frame(width: 86, height: 86) // Adjust size as needed
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .listRowSeparator(.hidden)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .padding(.horizontal,24)
                .background {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color(.sRGB, red: 236/255, green: 237/255, blue: 239/255), lineWidth: 1)
                }
                .listRowSeparator(.hidden)
                    
                
                ForEach(Array(viewModel.medicationsByTime.keys.sorted()), id: \.self) { time in
                    Section {
                        Text("\(time, formatter: dateFormatter)")
                            .foregroundColor(Color.primary)
                            .font(.system(size: 16, weight: .semibold))
                            
                        
                        ForEach(viewModel.medicationsByTime[time] ?? [], id: \.id) { medication in
                            SwipeableMedicationRow(medication: medication, time: time) {
                            }
                            .padding(.bottom, 5)
                        }
                    }
                    .foregroundColor(Color.primary)
                    .padding(.vertical, 5)
                }
                .listRowInsets(EdgeInsets())
                .padding(.horizontal, 24)
                .listRowSeparator(.hidden)

            }
            .frame(maxWidth: .infinity)
            .listStyle(PlainListStyle())
            .listRowInsets(EdgeInsets())

        }
        .onAppear {
            if let userID = authViewModel.currentUser?.id {
                viewModel.fetchMedications(for: userID) {
                    viewModel.groupMedicationsByTime()
                    
                    viewModel.scheduleNotifications()
                }
            }
        }
        .environmentObject(viewModel)
    }

    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    private func completionText(percentage: Int) -> String {
        switch percentage {
        case 0:
            return "Get started for the day!"
        case 1...50:
            return "Keep going!"
        case 51...99:
            return "You're almost done!"
        case 100:
            return "Congratulations!"
        default:
            return ""
        }
    }
}

struct SwipeableMedicationRow: View {
    var medication: Medication
    var time: Date
    var onSwipe: () -> Void
    @EnvironmentObject var viewModel: CalendarViewModel

    
    @State var showingSwipeToTrigger = true

    var body: some View {
        VStack{
            if showingSwipeToTrigger {
                SwipeView {
                    HStack {
                        MainViewRow(medication: medication)
                            .frame(width: UIScreen.main.bounds.width - 52, alignment: .center)
                    }
                    .padding(.horizontal, 10)
                    .background {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                    }
                    
                } leadingActions: { _ in
                    SwipeAction(systemImage: "checkmark", backgroundColor: Color(red: 0/255, green: 167/255, blue: 255/255)) {
                        withAnimation(.spring()) {
                            showingSwipeToTrigger = false
                            viewModel.completeMedication(withId: medication.id, at: time)
                        }
                    }
                    .allowSwipeToTrigger()
                }
            }
        }
    }
}

struct PercentageCircleView: View {
    var percentage: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10.0)
                .opacity(0.1)
                .foregroundColor(Color.primary)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.percentage, 100)) / 100.0)
                .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color(red: 0/255, green: 167/255, blue: 255/255))
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: percentage)
            
            HStack(alignment: .top, spacing: 2) {
                Text("\(self.percentage)")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundColor(Color(red: 0/255, green: 167/255, blue: 255/255))
                
                Text("%")
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(Color(red: 0/255, green: 167/255, blue: 255/255))
                    .padding(.top, 2)
            }
            .padding(3)
        }
    }
}



