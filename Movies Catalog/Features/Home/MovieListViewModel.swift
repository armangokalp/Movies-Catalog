//
//  MovieListViewModel.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 26.08.2025.
//


import Foundation

class MovieListViewModel {
    private let apiService = APIService.shared
    private(set) var moviesByCategory: [MovieCategory: [Movie]] = [:]
    
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    
    func loadMovies() {
        onLoadingStateChanged?(true)
        let group = DispatchGroup()
        
        for category in MovieCategory.allCases {
            group.enter()
            apiService.fetchMovies(category: category) { [weak self] result in
                defer { group.leave() }
                
                switch result {
                case .success(let response):
                    self?.moviesByCategory[category] = response.results
                case .failure(let error):
                    self?.onError?("Failed to load \(category.displayName): \(error.localizedDescription)")
                }
            }
        }
        
        group.notify(queue: .main) {
            self.onLoadingStateChanged?(false)
            self.onDataUpdated?()
        }
    }
    
    func getMovies(for category: MovieCategory) -> [Movie] {
        return moviesByCategory[category] ?? []
    }
    
    func getMovie(for category: MovieCategory, at index: Int) -> Movie? {
        let movies = getMovies(for: category)
        guard index < movies.count else { return nil }
        return movies[index]
    }
}
