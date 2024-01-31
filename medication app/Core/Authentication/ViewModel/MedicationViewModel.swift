import Foundation
import Combine
import FirebaseFirestore


class MedicationViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var medicationName: String = ""
    
    @Published var medicationSuggestions: [String] = []
    @Published var allMedications: [String] = []
    private var cancellables = Set<AnyCancellable>()
    private var db = Firestore.firestore()
    @Published var medications: [Medication] = []
    @Published var selectedForm: String = ""

    private let jsonFileName = "drug-ndc-0001-of-0001"
    private let jsonFileExtension = "json"
    private var dataTask: URLSessionDataTask?
    
    private var cachedMedications: CachedMedications?


    init() {
        // Load cached medications if available
        loadCachedMedications()

        // Set up the search text listener
        $medicationName
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.fetchMedicationNames(searchText)
            }
            .store(in: &cancellables)
    }
    
    private func loadCachedMedications() {
        if let data = UserDefaults.standard.data(forKey: "cachedMedications"),
           let cached = try? JSONDecoder().decode(CachedMedications.self, from: data) {
            cachedMedications = cached
        }
    }
    
    func fetchData(for query: String) {
        // Cancel previous network request, if any
        dataTask?.cancel()

        // Perform the network request with the debounced query
        let formattedQuery = query.trimmingCharacters(in: .whitespaces).lowercased()
        if formattedQuery.count >= 2 {
            // Construct and send your network request here (e.g., to an API)
            let urlString = "https://api.fda.gov/drug/ndc.json?search=brand_name:\"\(formattedQuery)\""

            guard let url = URL(string: urlString) else {
                return
            }

            dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                } else if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        // Handle a successful response (e.g., decoding data)
                        if let data = data {
                            do {
                                // Parse the data and update the suggestions
                                let decodedData = try JSONDecoder().decode([String].self, from: data)
                                DispatchQueue.main.async {
                                    self?.medicationSuggestions = decodedData
                                }
                            } catch {
                                print("Error decoding data: \(error.localizedDescription)")
                            }
                        }
                    case 404:
                        // Handle a 404 status code (resource not found)
                        print("Resource not found (404)")
                    default:
                        // Handle other status codes as needed
                        print("Unexpected status code: \(httpResponse.statusCode)")
                    }
                }
            }

            dataTask?.resume()

        } else {
            // Reset suggestions if the query length is less than 2 characters
            medicationSuggestions = []
        }
    }
    
    
    
    private func searchInSpecificDatabase(query: String, form: String?) -> [String] {
        guard let form = form else { return [] }
        
        let fileName = "\(form).json" // Construct the file name based on the selected form
        var results = [String]()

        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            print("JSON file for \(form) not found")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let medications = try JSONDecoder().decode([NDCProduct].self, from: data)
            results = medications
                .compactMap { $0.brand_name?.lowercased() }
                .filter { $0.contains(query) }
        } catch {
            print("Error parsing JSON file for \(form): \(error)")
        }

        let filteredResults = results
            .filter { $0.lowercased().contains(query) }
            .sorted {
                if $0.lowercased().hasPrefix(query) && !$1.lowercased().hasPrefix(query) {
                    return true
                } else if !$0.lowercased().hasPrefix(query) && $1.lowercased().hasPrefix(query) {
                    return false
                }
                return $0 < $1
            }


        let uniqueFilteredResults = uniqueElementsFrom(array: filteredResults)
        return Array(uniqueFilteredResults.prefix(15)) // Limit to 15 results
    }

    func fetchMedicationNames(_ query: String) {
        let queryLowercased = query.trimmingCharacters(in: .whitespaces).lowercased()
        if queryLowercased.count >= 2 {
            // Attempt to fetch from the API
            fetchFromAPI(query: queryLowercased) { [weak self] success, results in
                if success {
                    DispatchQueue.main.async {
                        self?.medicationSuggestions = results
                    }
                } else {
                    // Fallback to local JSON if API fetch fails
                    self?.fetchFromLocalJSON(query: queryLowercased)
                }
            }
        } else {
            medicationSuggestions = []
        }
    }

    private func fetchFromAPI(query: String, completion: @escaping (Bool, [String]) -> Void) {
        let formattedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.fda.gov/drug/ndc.json?search=brand_name:\"\(formattedQuery)\""
        
        guard let url = URL(string: urlString) else {
            completion(false, [])
            return
        }
        
        dataTask?.cancel()
        dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching from API: \(error.localizedDescription)")
                completion(false, [])
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error with the response, unexpected status code: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                completion(false, [])
                return
            }
            
            guard let data = data else {
                print("No data received from API")
                completion(false, [])
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(TopLevelResponse.self, from: data)
                let results = decodedResponse.results.compactMap { $0.brand_name?.lowercased() }
                
                // Create a custom sort closure to prioritize results that start with the query
                let sortedResults = results.sorted { (first, second) -> Bool in
                    if first.hasPrefix(query.lowercased()) && !second.hasPrefix(query.lowercased()) {
                        return true
                    } else if !first.hasPrefix(query.lowercased()) && second.hasPrefix(query.lowercased()) {
                        return false
                    }
                    return first < second
                }
                
                // Remove duplicates and take only the first 15 unique results
                let uniqueSortedResults = Array(NSOrderedSet(array: sortedResults).array.prefix(15)) as! [String]
                completion(true, uniqueSortedResults)
            } catch let decoderError {
                print("Error decoding API response: \(decoderError.localizedDescription)")
                completion(false, [])
            }
        }
        
        dataTask?.resume()
    }



    private func fetchFromLocalJSON(query: String) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            let results = self?.searchInSpecificDatabase(query: query, form: self?.selectedForm) ?? []
            DispatchQueue.main.async {
                self?.medicationSuggestions = results
            }
        }
    }
    
    func uniqueElementsFrom<T: Hashable>(array: [T]) -> [T] {
        var seen = Set<T>()
        return array.filter { seen.insert($0).inserted }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func fetchMedications(for userID: String) {
        let userMedicationsRef = Firestore.firestore().collection("users").document(userID).collection("medications")
        
        userMedicationsRef.getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting medications: \(error)")
            } else {
                self?.medications = querySnapshot?.documents.compactMap { document in
                    let data = document.data()
                    return Medication(id: document.documentID,
                                      form: data["form"] as? String ?? "",
                                      medicationName: data["medicationName"] as? String ?? "",
                                      dosageAmount: data["dosageAmount"] as? Int ?? 1,
                                      frequency: data["frequency"] as? String ?? "",
                                      timesPerWeek: data["timesPerWeek"] as? Int ?? 1,
                                      timesPerMonth: data["timesPerMonth"] as? Int ?? 1)
                } ?? []

                // Update the cached data
                self?.updateCachedMedications()
            }
        }
    }

    private func updateCachedMedications() {
        cachedMedications = CachedMedications(medications: medications)
        if let encoded = try? JSONEncoder().encode(cachedMedications) {
            UserDefaults.standard.set(encoded, forKey: "cachedMedications")
        }
    }

    
    func deleteMedication(userID: String, medicationID: String) {
        let userMedicationsRef = Firestore.firestore().collection("users").document(userID).collection("medications")
        userMedicationsRef.document(medicationID).delete { error in
            if let error = error {
                print("Error removing medication: \(error)")
            } else {
                print("Medication successfully removed!")
                DispatchQueue.main.async {
                    self.medications.removeAll { $0.id == medicationID }
                }
            }
        }
        
        // CalendarViewModel.completionPercentageForToday()
    }

    func addMedication(for userID: String, medicationName: String, dosageAmount: Int,form: String, frequency: String, timesPerWeek: Int?, timesPerMonth: Int?) {
        var medicationData: [String: Any] = [
            "form": form,
            "medicationName": medicationName,
            "dosageAmount": dosageAmount,
            "frequency": frequency
        ]
        
        if let times = timesPerWeek {
            medicationData["timesPerWeek"] = times
        }
        
        if let times = timesPerMonth {
            medicationData["timesPerMonth"] = times
        }
        
        db.collection("users").document(userID).collection("medications").addDocument(data: medicationData) { error in
            if let error = error {
                print("Error adding medication: \(error)")
            } else {
                print("Medication added successfully!")
            }
        }
        
        // updateCompletionPercentageForToday()
    }
}

struct TopLevelResponse: Codable {
    let results: [NDCProduct]
}

struct NDCProduct: Codable {
    let brand_name: String?
    let generic_name: String?
    // Add other fields from the JSON as needed
}

