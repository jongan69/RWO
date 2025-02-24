//
//  APIService.swift
//  RWO
//
//  Created by Jonathan Gan on 2/23/25.
//


//
//  APIService.swift
//  RWO
//
//  Created by Jonathan Gan on 2/23/25.
//


import Foundation

@MainActor
class APIService: ObservableObject {
    @Published var data: RetardioResponse?
    @Published var errorMessage: String?

    func fetchData() async {
        let urlString = "https://www.retardio.exposed/api/combined"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check if the response status code is 200 (OK)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                errorMessage = "Server responded with an error. Please try again later."
                return
            }

            // Attempt to decode the data
            let decodedData = try JSONDecoder().decode(RetardioResponse.self, from: data)
            self.data = decodedData
        } catch let decodingError as DecodingError {
            print(decodingError)
            errorMessage = "Decoding error: \(decodingError.localizedDescription)"
        } catch URLError.notConnectedToInternet {
            errorMessage = "No internet connection. Please check your connection."
        } catch URLError.timedOut {
            errorMessage = "The request timed out. Please try again."
        } catch URLError.cannotFindHost {
            errorMessage = "Cannot find host. Please check the URL."
        } catch URLError.cannotConnectToHost {
            errorMessage = "Cannot connect to the server. Please check your internet."
        } catch {
            errorMessage = "An error occurred: \(error.localizedDescription)"
        }
    }
}
