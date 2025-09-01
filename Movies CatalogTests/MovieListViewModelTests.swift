//
//  MovieListViewModelTests.swift
//  Movies CatalogTests
//
//  Created by Arman Gökalp on 01.09.2025.
//

import XCTest
@testable import Movies_Catalog

final class MovieListViewModelTests: XCTestCase {
    
    var viewModel: MovieListViewModel!
    var mockAPIService: MockAPIService!
    var mockCacheService: MockCacheService!
    
    override func setUpWithError() throws {
        mockAPIService = MockAPIService()
        mockCacheService = MockCacheService()
        viewModel = MovieListViewModel(apiService: mockAPIService, cacheService: mockCacheService)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockAPIService = nil
        mockCacheService = nil
    }
    
    // MARK: - Initial Loading Tests
    
    func testLoadMoviesFromAPI() throws {
        let testMovies = createTestMovies(count: 3)
        mockAPIService.mockResponse = .success(MoviesResponse(page: 1, results: testMovies, totalPages: 5, totalResults: 100))
        
        var dataUpdatedCalled = false
        viewModel.onDataUpdated = { dataUpdatedCalled = true }
        
        viewModel.loadMovies()
        
        let expectation = XCTestExpectation(description: "Data loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(dataUpdatedCalled, "Should notify when data updates")
        XCTAssertEqual(viewModel.getMovies(for: .popular).count, 3)
        XCTAssertTrue(mockCacheService.saveMoviesCalled, "Should cache the results")
    }
    
    func testLoadMoviesFromCache() throws {
        let cachedMovies = createTestMovies(count: 2)
        mockCacheService.cachedMovies[.popular] = cachedMovies
        
        var dataUpdatedCalled = false
        viewModel.onDataUpdated = { dataUpdatedCalled = true }
        
        viewModel.loadMovies()
        
        XCTAssertTrue(dataUpdatedCalled, "Should load from cache immediately")
        XCTAssertEqual(viewModel.getMovies(for: .popular).count, 2)
    }
    
    func testAPIErrorHandling() throws {
        mockAPIService.mockResponse = .failure(APIError.noData)
        
        var errorMessage: String?
        viewModel.onError = { errorMessage = $0 }
        
        viewModel.loadMovies()
        
        let expectation = XCTestExpectation(description: "Error handled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNotNil(errorMessage, "Should handle API errors")
        XCTAssertTrue(errorMessage?.contains("Failed to load") ?? false)
    }
    
    // MARK: - Pagination Tests
    
    func testShouldLoadMoreLogic() throws {
        let movies = createTestMovies(count: 10)
        // Setup initial state through public interface
        mockCacheService.cachedMovies[.popular] = movies
        viewModel.loadMovies()
        
        XCTAssertTrue(viewModel.shouldLoadMore(for: .popular, at: 6), "Should load more when near end")
        XCTAssertFalse(viewModel.shouldLoadMore(for: .popular, at: 2), "Should not load more when far from end")
    }
    
    func testLoadMoreMovies() throws {
        let initialMovies = createTestMovies(count: 3)
        let newMovies = createTestMovies(count: 2, startId: 100)
        
        // Setup initial state through cache
        mockCacheService.cachedMovies[.popular] = initialMovies
        viewModel.loadMovies()
        
        // Wait for initial load
        let initialExpectation = XCTestExpectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            initialExpectation.fulfill()
        }
        wait(for: [initialExpectation], timeout: 1.0)
        
        mockAPIService.mockResponse = .success(MoviesResponse(page: 2, results: newMovies, totalPages: 5, totalResults: 100))
        
        var categoryUpdated = false
        viewModel.onCategoryUpdated = { _ in categoryUpdated = true }
        
        viewModel.loadMoreMovies(for: .popular)
        
        let expectation = XCTestExpectation(description: "More movies loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(categoryUpdated, "Should notify when category updates")
        XCTAssertEqual(viewModel.getMovies(for: .popular).count, 5, "Should append new movies")
    }
    
    func testDuplicateMovieFiltering() throws {
        let duplicateMovie = createTestMovies(count: 1)[0]
        let initialMovies = [duplicateMovie]
        let newMovies = [duplicateMovie]
        
        // Setup initial state through cache
        mockCacheService.cachedMovies[.popular] = initialMovies
        viewModel.loadMovies()
        
        // Wait for initial load
        let initialExpectation = XCTestExpectation(description: "Initial load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            initialExpectation.fulfill()
        }
        wait(for: [initialExpectation], timeout: 1.0)
        
        mockAPIService.mockResponse = .success(MoviesResponse(page: 2, results: newMovies, totalPages: 5, totalResults: 100))
        
        viewModel.loadMoreMovies(for: .popular)
        
        let expectation = XCTestExpectation(description: "Duplicates filtered")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(viewModel.getMovies(for: .popular).count, 1, "Should filter out duplicates")
    }
    
    // MARK: - Helper Methods
    
    private func createTestMovies(count: Int, startId: Int = 1) -> [Movie] {
        return (startId..<startId + count).map { id in
            Movie(
                id: id,
                title: "Test Movie \(id)",
                overview: "Test overview for movie \(id)",
                posterPath: "/poster\(id).jpg",
                backdropPath: "/backdrop\(id).jpg",
                releaseDate: "2024-01-01",
                voteAverage: 7.5,
                voteCount: 100,
                popularity: 50.0,
                revenue: 1000000
            )
        }
    }
}

// MARK: - Mock Services

class MockAPIService: MovieAPIService {
    var mockResponse: Result<MoviesResponse, Error>?
    var fetchMoviesCallCount = 0
    var lastCategory: MovieCategory?
    var lastPage: Int?
    
    func fetchMovies(category: MovieCategory, page: Int, completion: @escaping (Result<MoviesResponse, Error>) -> Void) {
        fetchMoviesCallCount += 1
        lastCategory = category
        lastPage = page
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if let response = self.mockResponse {
                completion(response)
            } else {
                completion(.failure(APIError.noData))
            }
        }
    }
}

class MockCacheService: CacheServiceProtocol {
    var cachedMovies: [MovieCategory: [Movie]] = [:]
    var saveMoviesCalled = false
    var clearCacheCalled = false
    var lastSavedCategory: MovieCategory?
    var lastSavedMovies: [Movie]?
    
    func saveMovies(_ movies: [Movie], for category: MovieCategory) {
        saveMoviesCalled = true
        lastSavedCategory = category
        lastSavedMovies = movies
        cachedMovies[category] = movies
    }
    
    func loadMovies(for category: MovieCategory) -> [Movie] {
        return cachedMovies[category] ?? []
    }
    
    func clearCache() {
        clearCacheCalled = true
        cachedMovies.removeAll()
    }
    
    func getCachedMovieCount(for category: MovieCategory) -> Int {
        return cachedMovies[category]?.count ?? 0
    }
}
