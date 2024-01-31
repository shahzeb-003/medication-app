//
//  Webservice.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 20/01/2024.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case badID
}

class Webservice {
    func getNames(searchTerm: String) async throws -> [MedicationNames] {
        
        guard let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NetworkError.badURL
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.fda.gov"
        components.path = "/drug/ndc.json"
        components.queryItems = [
            URLQueryItem(name: "search", value: "brand_name:\"\(encodedSearchTerm)\""),
            URLQueryItem(name: "limit", value: "10")
        ]

        
        guard let url = components.url else {
        
            throw NetworkError.badURL
        }
        
        
        
        let(data, response) = try await URLSession.shared.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            
            throw NetworkError.badID
        }
        
        let medicationResponse = try? JSONDecoder().decode(MedicationResponse.self, from: data)
        print("Number of results: \(medicationResponse?.results.count ?? 0)")
        return medicationResponse?.results ?? []
        
    }
}
