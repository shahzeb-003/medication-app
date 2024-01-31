//
//  ContentView.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 14/11/2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State var showSplashScreen: Bool = true

    
    var body: some View {
        ZStack {
            if showSplashScreen {
                ZStack {
                    SplashScreenView()
                        .zIndex(1) // Bring the splash screen to the front

                }
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            self.showSplashScreen = false
                        }
                    }
                }
            } else if viewModel.userSession != nil && !showSplashScreen{
                TabView() {
                    MainView()
                        .tabItem() {
                            Image(systemName: "doc.text.image")
                                .environment(\.symbolVariants, .none) // here
                        }
                    MedicationView()
                        .tabItem() {
                            Image(systemName: "pill")
                                .environment(\.symbolVariants, .none) // here
                        }
                    SymptomView()
                        .tabItem() {
                            Image(systemName: "book.pages")
                                .environment(\.symbolVariants, .none) // here
                        }
                    ProfileView()
                        .tabItem() {
                            Image(systemName: "person")
                                .environment(\.symbolVariants, .none) // here
                        }
                }
                .accentColor(Color(red: 0/255, green: 167/255, blue: 255/255))
                .accentColor(Color(red: 0/255, green: 167/255, blue: 255/255))
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5))
            } else if viewModel.userSession == nil {
                InitialView()
            }
        }
    }
}

#Preview {
    ContentView()
}
