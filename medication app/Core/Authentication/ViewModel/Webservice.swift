//
//  Webservice.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 20/01/2024.
//

import Foundation


class Webservice {
    func getNames(searchTerm: String) async throws -> [String] {

        var components = URLComponents()
        components.scheme = "https"
        components.host = "clinicaltables.nlm.nih.gov"
        components.path = "/api/rxterms/v3/search"
        components.queryItems = [
            URLQueryItem(name: "terms", value: searchTerm)
        ]


        guard let url = components.url else {
            throw NetworkError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.badID
        }

        // Attempt to parse the JSON data manually due to its non-standard structure.
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [Any],
           
            
           let medicationNames = jsonResponse[1] as? [String] {
            return medicationNames
        } else {
            throw NetworkError.parsingError
        }
    }
}

enum NetworkError: Error {
    case badURL
    case badID
    case parsingError
}

