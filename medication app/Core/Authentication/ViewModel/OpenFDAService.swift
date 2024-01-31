//
//  OpenFDAService.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 29/11/2023.
//

import Foundation


class OpenFDAService {
    func searchMedication(byName name: String, completion: @escaping ([String]) -> Void) {
        guard let query = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.fda.gov/drug/label.json?search=openfda.brand_name:\(query)+OR+openfda.generic_name:\(query)&limit=10") else {
            completion([])
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }

            do {
                let result = try JSONDecoder().decode(FDAApiResponse.self, from: data)
                let names = result.results.map { $0.openFDA.brandName.first ?? $0.openFDA.genericName.first ?? "" }
                completion(names.filter { !$0.isEmpty })
            } catch {
                completion([])
            }
        }
        task.resume()
    }
}

struct FDAApiResponse: Codable {
    var results: [FDADrugResult]
}

struct FDADrugResult: Codable {
    var openFDA: OpenFDADetails

    enum CodingKeys: String, CodingKey {
        case openFDA = "openfda"
    }
}

struct OpenFDADetails: Codable {
    var brandName: [String]
    var genericName: [String]
}
