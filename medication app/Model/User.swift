//
//  User.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 14/11/2023.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String
    var fullname: String
    var email: String
    var startTime: String?
    var endTime: String?
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
    
    init(id: String, fullname: String, email: String, startTime: String, endTime: String) {
        self.id = id
        self.fullname = fullname
        self.email = email
        self.startTime = email
        self.endTime = email
    }
}
