//
//  MovieListViewModel.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 26.08.2025.
//


import Foundation

class MovieListViewModel {
    private let apiService: MovieAPIService // DI
    private(set) var moviesByCategory: [MovieCategory: [Movie]] = [:]
    
    // ui hooks
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    init(apiService: MovieAPIService) {
        self.apiService = apiService
    }
    
    // MARK: - Data Loading
    func loadMovies() {
        onLoadingStateChanged?(true)
        let group = DispatchGroup() // wait for all categories, then refresh UI
        
        for category in MovieCategory.allCases {
            group.enter()
            // Curently always fetching page 1 (can extend for pagination later)
            apiService.fetchMovies(category: category, page: 1) { [weak self] result in
                defer { group.leave() }
                
                switch result {
                case .success(let response):
                    // TODO: will append when adding infinite scroll
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
    
    // MARK: - Data Access
    func getMovies(for category: MovieCategory) -> [Movie] {
        return moviesByCategory[category] ?? []
    }
    
    func getMovie(for category: MovieCategory, at index: Int) -> Movie? {
        let movies = getMovies(for: category)
        guard index < movies.count else { return nil }
        return movies[index]
    }
}
