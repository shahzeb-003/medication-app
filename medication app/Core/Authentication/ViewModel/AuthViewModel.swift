//
//  AuthViewModel.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 14/11/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import Combine

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isInitializing = true
    
    init() {
        Task {
            await checkUserAuthenticationState()
        }
    }
    
    func checkUserAuthenticationState() async {
        if let currentUser = Auth.auth().currentUser {
            self.userSession = currentUser
            await fetchUser()
        }
        self.isInitializing = false
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: Failed to sign in with error \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String, startTime: Date, endTime: Date) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user

            // Format the Date objects into a suitable format for Firebase
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"  // Or any other format you prefer
            let formattedStartTime = dateFormatter.string(from: startTime)
            let formattedEndTime = dateFormatter.string(from: endTime)

            let user = User(id: result.user.uid, fullname: fullname, email: email, startTime: formattedStartTime, endTime: formattedEndTime)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
        }
    }

    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out with error (error.localizedDescription)")
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            if snapshot.exists, let data = snapshot.data() {
                print("DEBUG: Fetched user data: \(data)") // Print raw data

                // Attempt to decode and catch any errors
                do {
                    let user = try Firestore.Decoder().decode(User.self, from: data)
                    self.currentUser = user
                } catch let decodeError {
                    print("DEBUG: Decoding error: \(decodeError)")
                }
            } else {
                print("DEBUG: No data available for user")
            }
        } catch {
            print("DEBUG: Failed to fetch user with error \(error.localizedDescription)")
        }
    }


}


