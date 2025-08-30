//
//  CacheService.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 30.08.2025.
//

// Offline cache for movie info (no image)

import Foundation

protocol CacheServiceProtocol {
    func saveMovies(_ movies: [Movie], for category: MovieCategory)
    func loadMovies(for category: MovieCategory) -> [Movie]
    func clearCache()
    func getCachedMovieCount(for category: MovieCategory) -> Int
}

class CacheService: CacheServiceProtocol {
    private let userDefaults = UserDefaults.standard
    
    private func cacheKey(for category: MovieCategory) -> String {
        return "cached_movies_\(category.rawValue)"
    }
    
    func saveMovies(_ movies: [Movie], for category: MovieCategory) {
        let moviesToCache = Array(movies.prefix(Constants.Cache.offlineCacheLimitPerCategory))
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(moviesToCache)
            userDefaults.set(data, forKey: cacheKey(for: category))
            userDefaults.synchronize()
        } catch {
            print("Failed to cache movies for \(category.displayName): \(error)")
        }
    }
    
    func loadMovies(for category: MovieCategory) -> [Movie] {
        guard let data = userDefaults.data(forKey: cacheKey(for: category)) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Movie].self, from: data)
        } catch {
            print("Failed to load cached movies for \(category.displayName): \(error)")
            return []
        }
    }
    
    func clearCache() {
        for category in MovieCategory.allCases {
            userDefaults.removeObject(forKey: cacheKey(for: category))
        }
        userDefaults.synchronize()
    }
    
    func getCachedMovieCount(for category: MovieCategory) -> Int {
        return loadMovies(for: category).count
    }
}
