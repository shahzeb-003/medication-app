//
//  SymptomView.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 23/12/2023.
//

import SwiftUI
import Combine
import FirebaseFirestore
import Firebase

struct SymptomView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAddSymptom = false
    @ObservedObject var viewModel = SymptomViewModel()
    
    @State private var showingDeleteAlert = false
    @State private var symptomToDeleteID: String? = nil

    private var symptomDataPoints: [SymptomDataPoint] {
        viewModel.symptoms.map { SymptomDataPoint(severity: Double($0.severity), date: $0.time) }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Simple Graph Test View at the top
                        
                        Text("Symptoms")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(Color.primary)
                            .padding(.horizontal, 24)
                        
                        if symptomDataPoints.count > 1 {
                            SymptomGraphView(dataPoints: symptomDataPoints)
                        }
                        
                        // List of Symptoms
                        ForEach(viewModel.symptoms) { symptom in
                            VStack {
                                HStack {
                                    
                                    SymptomRow(symptom: symptom)
                                    
                                    Button(action: {
                                        symptomToDeleteID = symptom.id
                                        showingDeleteAlert = true
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                            .imageScale(.medium)
                                            .font(.system(size: 25))
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .alert(isPresented: $showingDeleteAlert) {
                                        Alert(
                                            title: Text("Are you sure you want to delete: \(symptom.title)?"),
                                            primaryButton: .destructive(Text("Yes")) {
                                                if let symptomID = symptomToDeleteID, let userID = authViewModel.currentUser?.id {
                                                    if let userID = authViewModel.currentUser?.id {
                                                        viewModel.deleteSymptom(userID: userID, symptomID: symptomID)
                                                        viewModel.fetchSymptoms(for: userID)
                                                    }
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
                        viewModel.fetchSymptoms(for: userID)
                    }
                }
                
                Button(action: {
                    showingAddSymptom = true
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
        .sheet(isPresented: $showingAddSymptom) {
            AddSymptomView(viewModel: viewModel).environmentObject(authViewModel)
                .onDisappear {
                    if let userID = authViewModel.currentUser?.id {
                        viewModel.fetchSymptoms(for: userID)
                    }
                }
        }
    }
    
}


struct SymptomDataPoint {
    var severity: Double
    var date: Date
}

struct SymptomTrendView: View {
    var dataPoints: [SymptomDataPoint]

    private var normalizedDataPoints: [CGPoint] {
        guard let maxSeverity = dataPoints.max(by: { $0.severity < $1.severity })?.severity else { return [] }
        let points = dataPoints.map { CGPoint(x: $0.date.timeIntervalSinceReferenceDate, y: $0.severity / maxSeverity) }
        return points.normalized(in: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                for (index, point) in self.normalizedDataPoints.enumerated() {
                    let xPosition = geometry.size.width * point.x
                    let yPosition = geometry.size.height * (1 - point.y)
                    
                    let graphPoint = CGPoint(x: xPosition, y: yPosition)
                    if index == 0 {
                        path.move(to: graphPoint)
                    } else {
                        path.addLine(to: graphPoint)
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        }
    }
}

extension Array where Element == CGPoint {
    func normalized(in rect: CGRect) -> [CGPoint] {
        guard let minX = self.min(by: { $0.x < $1.x })?.x,
              let maxX = self.max(by: { $0.x < $1.x })?.x,
              let minY = self.min(by: { $0.y < $1.y })?.y,
              let maxY = self.max(by: { $0.y < $1.y })?.y else { return [] }
        
        return self.map { point in
            let normalizedX = (point.x - minX) / (maxX - minX)
            let normalizedY = (point.y - minY) / (maxY - minY)
            return CGPoint(x: normalizedX * rect.width, y: normalizedY * rect.height)
        }
    }
}

struct SymptomGraphView: View {
    var dataPoints: [SymptomDataPoint]
    
    private let yAxisInset: CGFloat = 50 // Increase inset for y-axis to give more space for labels
    private let xAxisInset: CGFloat = 50 // Increase inset for x-axis to give more space for labels
    private let pointRadius: CGFloat = 4 // Radius of the points on the graph
    
    // DateFormatter to format the date labels
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm\ndd MMM"
        return formatter
    }()
    
    private func normalizeDataPoints(size: CGSize) -> [CGPoint] {
        guard let minDate = dataPoints.map({ $0.date }).min(),
              let maxDate = dataPoints.map({ $0.date }).max(),
              let minSeverity = dataPoints.map({ $0.severity }).min(),
              let maxSeverity = dataPoints.map({ $0.severity }).max(),
              maxDate > minDate,
              maxSeverity > minSeverity else {
            return []
        }
        
        let dateRange = maxDate.timeIntervalSince(minDate)
        let severityRange = 9.0 // Fixed range for severity from 1 to 10
        
        let drawableWidth = size.width - yAxisInset * 2
        let drawableHeight = size.height - xAxisInset * 2
        
        return dataPoints.map { point in
            let xPosition = ((point.date.timeIntervalSince(minDate) / dateRange) * drawableWidth) + yAxisInset
            let yPosition = ((point.severity - 1) / severityRange) * drawableHeight // Severity normalized from 0 to 9
            return CGPoint(x: xPosition, y: size.height - yPosition - xAxisInset)
        }
    }

    
    var body: some View {
        GeometryReader { geometry in
            let points = self.normalizeDataPoints(size: geometry.size)
            let drawableHeight = geometry.size.height - (xAxisInset * 2)

            
            ZStack {
                // Draw the axes
                Path { path in
                    // X-axis
                    path.move(to: CGPoint(x: yAxisInset, y: geometry.size.height - xAxisInset))
                    path.addLine(to: CGPoint(x: geometry.size.width - yAxisInset, y: geometry.size.height - xAxisInset))
                    // Y-axis
                    path.move(to: CGPoint(x: yAxisInset, y: geometry.size.height - xAxisInset))
                    path.addLine(to: CGPoint(x: yAxisInset, y: xAxisInset))
                }
                .stroke(Color.primary.opacity(0.25), lineWidth: 1)
                
                // Draw the dots for the scatter plot
                ForEach(points.indices, id: \.self) { index in
                    Circle()
                        .frame(width: pointRadius * 2, height: pointRadius * 2)
                        .position(points[index])
                        .foregroundColor(Color.blue)
                }
                
                // Y-axis labels
                ForEach(1...10, id: \.self) { severity in
                    Text("\(severity)")
                        .font(.caption)
                        .position(
                            x: yAxisInset / 2,
                            y: geometry.size.height - (CGFloat(severity - 1) / 9.0) * drawableHeight - xAxisInset
                        )
                }
                
                // X-axis labels
                if let minDate = dataPoints.map({ $0.date }).min(),
                   let maxDate = dataPoints.map({ $0.date }).max() {
                    let dateInterval = maxDate.timeIntervalSince(minDate)
                    let labelCount = min(dataPoints.count, 5) // Limit the number of labels to 5 or the number of data points
                    
                    ForEach(0..<labelCount, id: \.self) { index in
                        let increment = dateInterval / Double(labelCount - 1)
                        let date = minDate.addingTimeInterval(increment * Double(index))
                        let label = self.dateFormatter.string(from: date)
                        
                        Text(label)
                            .font(.caption)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .position(
                                x: yAxisInset + (geometry.size.width - yAxisInset * 2) / CGFloat(labelCount - 1) * CGFloat(index),
                                y: geometry.size.height - xAxisInset / 2
                            )
                    }
                }
            }
        }
        .frame(height: 250) // Adjusted the graph height for better spacing
    }
}
