//
//  ProfileView.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 14/11/2023.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var showTimePicker = false
    @State private var tempStartTime: Date = Date()
    @State private var tempEndTime: Date = Date()
    // DateFormatter to convert times
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    @State private var tempFullName: String = ""
    @State private var tempEmail: String = ""
    @State private var currentPassword: String = "" // For re-authentication

    
    var body: some View {
        if let user = viewModel.currentUser {
            ScrollView {
                VStack(alignment: .leading) {
                    
                    Text("Profile")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(Color.primary)
                        .padding(.horizontal, 24)

                    VStack {

                        HStack {
                            Text(user.initials)
                                .foregroundColor(Color.primary)
                                .font(.system(.title, weight: .semibold))
                        }
                    }
                    .padding(.horizontal, 24)
                    .frame(width: UIScreen.main.bounds.width - 24, height: 200)
                    .background {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.secondary, lineWidth: 1)
                    }

                    VStack(alignment: .leading) {
                        // Existing user details display
                        Text(viewModel.currentUser?.fullname ?? "")
                            .font(.system(.subheadline, weight: .semibold))
                            .padding(.top, 4)
                            .foregroundColor(Color.primary)
                        
                        Text(viewModel.currentUser?.email ?? "")
                            .font(.footnote)
                            .foregroundColor(Color.secondary)
                        
                        // Display current start and end times
                        Text("Start Time: \(viewModel.currentUser?.startTime ?? "")")
                            .font(.footnote)
                            .foregroundColor(Color.secondary)
                        Text("End Time: \(viewModel.currentUser?.endTime ?? "")")
                            .font(.footnote)
                            .foregroundColor(Color.secondary)
                        
                        Spacer()
                        
                        // Unified Change Time Button
                        Button("Change Times") {
                            // Initialize tempStartTime and tempEndTime with current values
                            if let startTimeStr = viewModel.currentUser?.startTime,
                               let startTime = timeFormatter.date(from: startTimeStr),
                               let endTimeStr = viewModel.currentUser?.endTime,
                               let endTime = timeFormatter.date(from: endTimeStr) {
                                self.tempStartTime = startTime
                                self.tempEndTime = endTime
                            }
                            showTimePicker.toggle()
                        }
                    }
                    .padding()
                    .sheet(isPresented: $showTimePicker) {
                        // TimePickerView for changing both start and end times
                        TimeChangeView(isPresented: self.$showTimePicker, tempStartTime: self.$tempStartTime, tempEndTime: self.$tempEndTime, onSave: {
                            Task {
                                await viewModel.updateUserTimes(start: self.tempStartTime, end: self.tempEndTime)
                            }
                        })
                    }

                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.signOut()
                    }) {
                        Text("Sign Out")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.width - 24, height: 58)
                    }
                    .background(Color(red: 0/255, green: 167/255, blue: 255/255))
                    .cornerRadius(15)
                    .padding(.top, 32)
                    
                }
            }
            .onAppear {
                // Initialize temporary state variables with current user details
                tempFullName = viewModel.currentUser?.fullname ?? ""
                tempEmail = viewModel.currentUser?.email ?? ""
            }
        }
    }
}

struct CustomRoundedRectangle: Shape {
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Define the points for the corners
        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        
        // Move to the starting point (top-left)
        path.move(to: CGPoint(x: topLeft.x, y: topLeft.y + radius))
        
        // Add lines and arcs to create the shape with different radii for corners
        path.addLine(to: CGPoint(x: topRight.x, y: topRight.y + radius))
        path.addArc(center: CGPoint(x: topRight.x - radius, y: topRight.y + radius), radius: radius, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: bottomRight.x - radius, y: bottomRight.y))
        path.addArc(center: CGPoint(x: bottomRight.x - radius, y: bottomRight.y - radius), radius: radius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: bottomLeft.x + radius, y: bottomLeft.y))
        path.addArc(center: CGPoint(x: bottomLeft.x + radius, y: bottomLeft.y - radius), radius: radius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y + radius))
        
        return path
    }
    
    var animatableData: CGFloat {
        get { return radius }
        set { self.radius = newValue }
    }
}

struct TimeChangeView: View {
    @Binding var isPresented: Bool
    @Binding var tempStartTime: Date
    @Binding var tempEndTime: Date
    var onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Start Time", selection: $tempStartTime, displayedComponents: .hourAndMinute)
                DatePicker("End Time", selection: $tempEndTime, displayedComponents: .hourAndMinute)
            }
            .navigationTitle("Change Times")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                        isPresented = false
                    }
                }
            }
        }
    }
}

