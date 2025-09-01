//
//  MovieDetailViewModelTests.swift
//  Movies CatalogTests
//
//  Created by Arman Gökalp on 01.09.2025.
//

import XCTest
@testable import Movies_Catalog

final class MovieDetailViewModelTests: XCTestCase {
    
    var viewModel: MovieDetailViewModel!
    var testMovie: Movie!
    
    override func setUpWithError() throws {
        testMovie = Movie(
            id: 42,
            title: "Blade Runner 2049",
            overview: "A young blade runner discovers a secret that could plunge what's left of society into chaos.",
            posterPath: "/poster.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "2017-10-06",
            voteAverage: 8.0,
            voteCount: 5000,
            popularity: 85.5,
            revenue: 250000000
        )
        viewModel = MovieDetailViewModel(movie: testMovie)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        testMovie = nil
    }
    
    // MARK: - Basic Property Tests
    
    func testBasicProperties() throws {
        XCTAssertEqual(viewModel.title, "Blade Runner 2049")
        XCTAssertEqual(viewModel.year, "2017")
        XCTAssertEqual(viewModel.rating, "⭐ 8.0")
        XCTAssertEqual(viewModel.overview, "A young blade runner discovers a secret that could plunge what's left of society into chaos.")
    }
    
    func testImageURLs() throws {
        XCTAssertTrue(viewModel.posterURL?.contains("w500/poster.jpg") ?? false, "Should generate correct poster URL")
        XCTAssertTrue(viewModel.backdropURL?.contains("w780/backdrop.jpg") ?? false, "Should generate correct backdrop URL")
    }
    
    func testPlayerScreenProperties() throws {
        XCTAssertEqual(viewModel.date, "2017-10-06 📅")
        XCTAssertEqual(viewModel.voteCount, "5000 votes")
        XCTAssertEqual(viewModel.popularity, "85.5 popularity")
        
        // Test revenue formatting - just check it exists and is formatted
        XCTAssertNotNil(viewModel.revenue, "Revenue should not be nil for movie with revenue")
    }
    
    func testEmptyDateHandling() throws {
        // Given - movie with empty release date
        let movieWithoutDate = Movie(
            id: 1,
            title: "Test",
            overview: "Test",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "",
            voteAverage: 7.0,
            voteCount: 100,
            popularity: 50.0,
            revenue: nil
        )
        let viewModelWithoutDate = MovieDetailViewModel(movie: movieWithoutDate)
        
        // Then
        XCTAssertEqual(viewModelWithoutDate.date, "", "Should handle empty date gracefully")
        XCTAssertNil(viewModelWithoutDate.revenue, "Should handle nil revenue")
    }
    
    func testZeroRevenueHandling() throws {
        // Given - movie with zero revenue
        let movieWithZeroRevenue = Movie(
            id: 1,
            title: "Test",
            overview: "Test",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "2024-01-01",
            voteAverage: 7.0,
            voteCount: 100,
            popularity: 50.0,
            revenue: 0
        )
        let viewModelWithZeroRevenue = MovieDetailViewModel(movie: movieWithZeroRevenue)
        
        // Then
        XCTAssertNil(viewModelWithZeroRevenue.revenue, "Should return nil for zero revenue")
    }
    
    func testNilImagePaths() throws {
        // Given - movie without images
        let movieWithoutImages = Movie(
            id: 1,
            title: "Test",
            overview: "Test",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "2024-01-01",
            voteAverage: 7.0,
            voteCount: 100,
            popularity: 50.0,
            revenue: nil
        )
        let viewModelWithoutImages = MovieDetailViewModel(movie: movieWithoutImages)
        
        // Then
        XCTAssertNil(viewModelWithoutImages.posterURL, "Should handle nil poster path")
        XCTAssertNil(viewModelWithoutImages.backdropURL, "Should handle nil backdrop path")
    }
}
