//
//  ProfileView.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 14/11/2023.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
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
                        Text(user.fullname)
                                .font(.system(.subheadline, weight: .semibold))
                                .padding(.top, 4)
                                .foregroundColor(Color.primary)
                    
                        Text(user.email)
                            .font(.footnote)
                            .foregroundColor(Color.secondary)
                        
                        Text(user.startTime ?? "")
                            .font(.footnote)
                            .foregroundColor(Color.secondary)
                        
                        Text(user.endTime ?? "")
                            .font(.footnote)
                            .foregroundColor(Color.secondary)
                        
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    
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


