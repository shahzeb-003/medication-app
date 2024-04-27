//
//  AuthViewModel.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 14/11/2023.
//

// Import necessary frameworks for functionality
import Foundation // Provides basic utility classes and functions
import Firebase // Firebase framework for accessing Firebase services like authentication and database
import FirebaseFirestoreSwift // Provides Swift Codable support for Firestore
import Combine // Framework for handling declarative Swift APIs for processing values over time

// Protocol to ensure any authentication form has a property to validate its current state
protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

// Marks this class to be executed on the main UI thread, crucial for updating the UI based on state changes
@MainActor
class AuthViewModel: ObservableObject {
    // Observable properties to enable SwiftUI views to react to their changes
    @Published var userSession: FirebaseAuth.User? // Tracks the current logged-in Firebase user
    @Published var currentUser: User? // Custom user model for the application
    @Published var isInitializing = true // Indicates whether the authentication state is being initialized
    
    // Initializer to start checking the user's authentication state immediately upon ViewModel creation
    init() {
        // Asynchronously check and update the authentication state
        Task {
            await checkUserAuthenticationState()
        }
    }
    
    // Asynchronously checks the current user's authentication state with Firebase
    func checkUserAuthenticationState() async {
        if let currentUser = Auth.auth().currentUser {
            self.userSession = currentUser // Update the session if a user is currently logged in
            await fetchUser() // Fetch additional user details from Firestore
        }
        self.isInitializing = false // Mark initialization as complete
    }
    
    // Asynchronously signs in a user with an email and password
    func signIn(withEmail email: String, password: String) async throws {
        do {
            // Attempt to sign in with Firebase Auth
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user // Update session on successful sign in
            await fetchUser() // Fetch user details
        } catch {
            // Handle and log any errors during sign in
            print("DEBUG: Failed to sign in with error \(error.localizedDescription)")
        }
    }
    
    // Asynchronously creates a new user with email, password, and additional details
    func createUser(withEmail email: String, password: String, fullname: String, startTime: Date, endTime: Date) async throws {
        do {
            // Attempt to create a user with Firebase Auth
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user // Update session on successful user creation

            // Prepare the date formatter for formatting the start and end times
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm" // Set the desired format
            let formattedStartTime = dateFormatter.string(from: startTime)
            let formattedEndTime = dateFormatter.string(from: endTime)

            // Create a user model with the formatted times and other details
            let user = User(id: result.user.uid, fullname: fullname, email: email, startTime: formattedStartTime, endTime: formattedEndTime)
            let encodedUser = try Firestore.Encoder().encode(user) // Encode the user for Firestore
            // Save the encoded user data in Firestore
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser() // Fetch the newly created user's details
        } catch {
            // Handle and log any errors during user creation
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
        }
    }

    // Signs out the current user
    func signOut() {
        do {
            try Auth.auth().signOut() // Attempt to sign out with Firebase Auth
            self.userSession = nil // Reset the user session
            self.currentUser = nil // Reset the current user details
        } catch {
            // Handle and log any errors during sign out
            print("DEBUG: Failed to sign out with error (error.localizedDescription)")
        }
    }
    
    // Asynchronously fetches the current user's details from Firestore
    func fetchUser() async {
        // Ensure there is a current user signed in
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            // Attempt to fetch user data from Firestore
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            if snapshot.exists, let data = snapshot.data() {
                // If data is found, attempt to decode it into the User model
                do {
                    let user = try Firestore.Decoder().decode(User.self, from: data)
                    self.currentUser = user // Update the current user with decoded details
                } catch let decodeError {
                    // Handle and log any decoding errors
                    print("DEBUG: Decoding error: \(decodeError)")
                }
            } else {
                // Handle the case where no data is available for the user
                print("DEBUG: No data available for user")
            }
        } catch {
            // Handle and log any errors during data fetch
            print("DEBUG: Failed to fetch user with error \(error.localizedDescription)")
        }
    }
    
    // Function to update user start and end times
    func updateUserTimes(start: Date, end: Date) async {
        guard let uid = userSession?.uid else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let formattedStartTime = dateFormatter.string(from: start)
        let formattedEndTime = dateFormatter.string(from: end)
        
        do {
            let userUpdate = ["startTime": formattedStartTime, "endTime": formattedEndTime]
            try await Firestore.firestore().collection("users").document(uid).updateData(userUpdate)
            await fetchUser()
        } catch {
            print("DEBUG: Failed to update user times with error \(error.localizedDescription)")
        }
    }

}

