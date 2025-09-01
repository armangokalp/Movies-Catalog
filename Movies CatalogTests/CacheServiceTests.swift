//
//  CacheServiceTests.swift
//  Movies CatalogTests
//
//  Created by Arman Gökalp on 01.09.2025.
//

import XCTest
@testable import Movies_Catalog

final class CacheServiceTests: XCTestCase {
    
    var cacheService: CacheService!
    var testMovies: [Movie]!
    
    override func setUpWithError() throws {
        cacheService = CacheService()
        testMovies = createTestMovies()
        
        cacheService.clearCache()
    }
    
    override func tearDownWithError() throws {
        cacheService.clearCache()
        cacheService = nil
        testMovies = nil
    }
    
    // MARK: - Save & Load Tests
    
    func testSaveAndLoadMovies() throws {
        // When
        cacheService.saveMovies(testMovies, for: .popular)
        let loadedMovies = cacheService.loadMovies(for: .popular)
        
        // Then
        XCTAssertEqual(loadedMovies.count, testMovies.count, "Should save and load same number of movies")
        XCTAssertEqual(loadedMovies.first?.id, testMovies.first?.id, "Should preserve movie data")
        XCTAssertEqual(loadedMovies.first?.title, testMovies.first?.title, "Should preserve movie title")
    }
    
    func testEmptyCache() throws {
        // When
        let loadedMovies = cacheService.loadMovies(for: .topRated)
        
        // Then
        XCTAssertTrue(loadedMovies.isEmpty, "Should return empty array for uncached category")
        XCTAssertEqual(cacheService.getCachedMovieCount(for: .topRated), 0, "Should report zero count")
    }
    
    func testCacheSeparationByCategory() throws {
        // Given
        let popularMovies = createTestMovies(startId: 1)
        let topRatedMovies = createTestMovies(startId: 100)
        
        // When
        cacheService.saveMovies(popularMovies, for: .popular)
        cacheService.saveMovies(topRatedMovies, for: .topRated)
        
        // Then
        let loadedPopular = cacheService.loadMovies(for: .popular)
        let loadedTopRated = cacheService.loadMovies(for: .topRated)
        
        XCTAssertEqual(loadedPopular.first?.id, 1, "Should cache popular movies separately")
        XCTAssertEqual(loadedTopRated.first?.id, 100, "Should cache top rated movies separately")
        XCTAssertNotEqual(loadedPopular.first?.id, loadedTopRated.first?.id, "Categories should be independent")
    }
    
    func testClearCache() throws {
        // Given
        cacheService.saveMovies(testMovies, for: .popular)
        cacheService.saveMovies(testMovies, for: .topRated)
        
        // When
        cacheService.clearCache()
        
        // Then
        XCTAssertTrue(cacheService.loadMovies(for: .popular).isEmpty, "Should clear popular cache")
        XCTAssertTrue(cacheService.loadMovies(for: .topRated).isEmpty, "Should clear top rated cache")
        XCTAssertEqual(cacheService.getCachedMovieCount(for: .popular), 0, "Should report zero count after clear")
    }
    
    func testCacheLimit() throws {
        // Given - more movies than cache limit
        let manyMovies = createManyTestMovies(count: 100)
        
        // When
        cacheService.saveMovies(manyMovies, for: .popular)
        let loadedMovies = cacheService.loadMovies(for: .popular)
        
        // Then - should respect cache limit
        XCTAssertLessThanOrEqual(loadedMovies.count, Constants.Cache.offlineCacheLimitPerCategory, 
                                "Should respect cache limit")
        XCTAssertEqual(loadedMovies.first?.id, manyMovies.first?.id, "Should keep first movies")
    }
    
    func testGetCachedMovieCount() throws {
        // Given
        cacheService.saveMovies(testMovies, for: .popular)
        
        // When
        let count = cacheService.getCachedMovieCount(for: .popular)
        
        // Then
        XCTAssertEqual(count, testMovies.count, "Should return correct cached count")
    }
    
    // MARK: - Error Handling Tests
    
    func testCorruptedCacheHandling() throws {
        // Given - manually corrupt the cache with invalid data
        UserDefaults.standard.set("invalid_json_data", forKey: "cached_movies_popularity.desc")
        
        // When
        let loadedMovies = cacheService.loadMovies(for: .popular)
        
        // Then
        XCTAssertTrue(loadedMovies.isEmpty, "Should handle corrupted cache gracefully")
    }
    
    // MARK: - Helper Methods
    
    private func createTestMovies(startId: Int = 1) -> [Movie] {
        return (startId..<startId + 3).map { id in
            Movie(
                id: id,
                title: "Cached Movie \(id)",
                overview: "Overview \(id)",
                posterPath: "/poster\(id).jpg",
                backdropPath: "/backdrop\(id).jpg",
                releaseDate: "2024-01-01",
                voteAverage: 7.0,
                voteCount: 100,
                popularity: 50.0,
                revenue: 1000000
            )
        }
    }
    
    private func createManyTestMovies(count: Int) -> [Movie] {
        return (1...count).map { id in
            Movie(
                id: id,
                title: "Movie \(id)",
                overview: "Overview \(id)",
                posterPath: "/poster\(id).jpg",
                backdropPath: "/backdrop\(id).jpg",
                releaseDate: "2024-01-01",
                voteAverage: 7.0,
                voteCount: 100,
                popularity: 50.0,
                revenue: 1000000
            )
        }
    }
}
