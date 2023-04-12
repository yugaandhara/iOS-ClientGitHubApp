//
//  RequestHelper.swift
//  ClientGitHubApp
//
//  Created by Yugandhara Bodhekar on 10/04/23.
//

import Foundation

final class RequesrHelper {
    
    // MARK: - Type Alias
    
    typealias RepositoriesResult = ([Repository]?, String) -> Void
    
    // MARK: - Variable
    
    private var errorMessage = String()
    
    // MARK: - Internal Methods
    
    func getRepoData(accessToken: String, completion: @escaping RepositoriesResult) {
        guard let url = URL(string: "https://api.github.com/user/repos") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        let token = "Bearer " + accessToken
        request.addValue(token, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }
            guard let data = data else {
                print("Empty response")
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let repositories = try decoder.decode([Repository].self, from: data)
                DispatchQueue.main.async {
                    completion(repositories, self.errorMessage)
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}
