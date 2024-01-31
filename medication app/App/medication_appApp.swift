//
//  medication_appApp.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 14/11/2023.
//

import SwiftUI
import Firebase
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
struct medication_appApp: App {
    @StateObject var viewModel = AuthViewModel()
    private var notificationDelegate = NotificationDelegate()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    
    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate

    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}


class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification while the app is in the foreground
        completionHandler([.banner, .sound])
    }
}
