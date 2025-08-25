//
//  APIService.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 25.08.2025.
//

import Foundation

class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://api.themoviedb.org/3"
    private let apiKey = "8537cf09d8c5dd833338467f049a0aa7"
    
    
    func fetchMovies(category: MovieCategory, page: Int = 1, completion: @escaping (Result<MoviesResponse, Error>) -> Void) {
        guard let url = buildURL(for: category, page: page) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(APIError.noData))
                }
                return
            }
            
            do {
                let moviesResponse = try JSONDecoder().decode(MoviesResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(moviesResponse))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    

    private func buildURL(for category: MovieCategory, page: Int) -> URL? {
        var components = URLComponents(string: "\(baseURL)/discover/movie")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "sort_by", value: category.rawValue),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "include_video", value: "false"),
            URLQueryItem(name: "language", value: "en-US")
        ]
        
        // Add additional filters for revenue category
        if category == .revenue {
            components?.queryItems?.append(URLQueryItem(name: "revenue.gte", value: "1000000"))
        }
        
        return components?.url
    }
}


enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
