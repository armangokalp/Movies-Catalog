//
//  MovieListViewModel.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 26.08.2025.
//


import Foundation

class MovieListViewModel {
    private let apiService: MovieAPIService // DI
    private let cacheService: CacheServiceProtocol // DI
    private(set) var moviesByCategory: [MovieCategory: [Movie]] = [:]
    private var currentPages: [MovieCategory: Int] = [:]
    private var isLoadingMore: [MovieCategory: Bool] = [:]
    private var hasMorePages: [MovieCategory: Bool] = [:]
    
    // ui hooks
    var onDataUpdated: (() -> Void)?
    var onCategoryUpdated: ((MovieCategory) -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    init(apiService: MovieAPIService, cacheService: CacheServiceProtocol) {
        self.apiService = apiService
        self.cacheService = cacheService
    }
    
    // MARK: - Data Loading
    func loadMovies() {
        
        loadFromCache()
        
        onLoadingStateChanged?(true)
        let group = DispatchGroup()
        
        for category in MovieCategory.allCases {
            currentPages[category] = 1
            isLoadingMore[category] = false
            hasMorePages[category] = true
            
            group.enter()
            apiService.fetchMovies(category: category, page: 1) { [weak self] result in
                defer { group.leave() }
                
                switch result {
                case .success(let response):
                    self?.moviesByCategory[category] = response.results
                    self?.hasMorePages[category] = response.page < response.totalPages
                    
                    let cachedMovies = self?.cacheService.loadMovies(for: category) ?? []
                    if !(self?.areMoviesEqual(cachedMovies, response.results) ?? false) { /// cache if loaded content is different
                        self?.cacheService.saveMovies(response.results, for: category)
                    }
                case .failure(let error):

                    if self?.moviesByCategory[category]?.isEmpty ?? true {
                        self?.onError?("Failed to load \(category.displayName): \(error.localizedDescription)")
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            self.onLoadingStateChanged?(false)
            self.onDataUpdated?()
        }
    }
    
    private func loadFromCache() {
        for category in MovieCategory.allCases {
            let cachedMovies = cacheService.loadMovies(for: category)
            if !cachedMovies.isEmpty {
                moviesByCategory[category] = cachedMovies

                let cachedCount = cachedMovies.count
                currentPages[category] = cachedCount / Constants.Cache.imagePerRequest
                hasMorePages[category] = cachedCount < Constants.Cache.offlineCacheLimitPerCategory
            }
        }
        
        onDataUpdated?()
    }
    
    func loadMoreMovies(for category: MovieCategory) { /// Horizontal Pagination
        guard let hasMore = hasMorePages[category], hasMore,
              let isLoading = isLoadingMore[category], !isLoading else {
            return
        }
        
        isLoadingMore[category] = true
        let nextPage = (currentPages[category] ?? 1) + 1
        
        apiService.fetchMovies(category: category, page: nextPage) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingMore[category] = false
                
                switch result {
                case .success(let response):
                    self?.currentPages[category] = nextPage
                    var existingMovies = self?.moviesByCategory[category] ?? []
                    
                    // Filtering duplicates
                    let existingIds = Set(existingMovies.map { $0.id })
                    let newMovies = response.results.filter { !existingIds.contains($0.id) }
                    existingMovies.append(contentsOf: newMovies)
                    
                    self?.moviesByCategory[category] = existingMovies
                    self?.hasMorePages[category] = response.page < response.totalPages
                    
                    let moviesToCache = Array(existingMovies.prefix(Constants.Cache.offlineCacheLimitPerCategory))
                    let cachedMovies = self?.cacheService.loadMovies(for: category) ?? []
                    if !(self?.areMoviesEqual(cachedMovies, moviesToCache) ?? false) { /// Cache if loaded content is different
                        self?.cacheService.saveMovies(moviesToCache, for: category)
                    }
                    
                    let previousCount = existingMovies.count - response.results.count
                    self?.onCategoryUpdated?(category)
                case .failure(let error):
                    self?.onError?("Failed to load more \(category.displayName): \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: Data Access
    func getMovies(for category: MovieCategory) -> [Movie] {
        return moviesByCategory[category] ?? []
    }
    
    func getMovie(for category: MovieCategory, at index: Int) -> Movie? {
        let movies = getMovies(for: category)
        guard index < movies.count else { return nil }
        return movies[index]
    }
    
    func shouldLoadMore(for category: MovieCategory, at index: Int) -> Bool {
        let movies = getMovies(for: category)
        guard let hasMore = hasMorePages[category], hasMore,
              let isLoading = isLoadingMore[category], !isLoading else {
            return false
        }
        
        return index >= movies.count - 5 /// Loads on last 5
    }
    
    // MARK: Helpers
    private func areMoviesEqual(_ movies1: [Movie], _ movies2: [Movie]) -> Bool { ///Cache helper
        guard movies1.count == movies2.count else { return false }
        
        let ids1 = Set(movies1.map { $0.id })
        let ids2 = Set(movies2.map { $0.id })
        
        return ids1 == ids2
    }
}
