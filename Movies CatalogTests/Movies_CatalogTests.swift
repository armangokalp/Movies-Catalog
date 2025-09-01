//
//  Movies_CatalogTests.swift
//  Movies CatalogTests
//
//  Created by Arman Gökalp on 25.08.2025.
//

import XCTest
@testable import Movies_Catalog

final class Movies_CatalogTests: XCTestCase {

    override func setUpWithError() throws {
        // Clean slate for each test
    }

    override func tearDownWithError() throws {
        // Cleanup after tests
    }

    // MARK: - Movie Model Tests
    
    func testMovieDecoding() throws {
        // Sample JSON that matches TMDb API response
        let json = """
        {
            "id": 123,
            "title": "Test Movie",
            "overview": "A great test movie",
            "release_date": "2024-01-15",
            "vote_average": 8.5,
            "vote_count": 1000,
            "popularity": 95.5,
            "poster_path": "/test_poster.jpg",
            "backdrop_path": "/test_backdrop.jpg",
            "revenue": 50000000
        }
        """.data(using: .utf8)!
        
        let movie = try JSONDecoder().decode(Movie.self, from: json)
        
        XCTAssertEqual(movie.id, 123)
        XCTAssertEqual(movie.title, "Test Movie")
        XCTAssertEqual(movie.formattedReleaseYear, "2024")
        XCTAssertEqual(movie.formattedRating, "8.5")
        XCTAssertTrue(movie.fullPosterURL?.contains("test_poster.jpg") ?? false)
    }
    
    func testMovieFormattedProperties() throws {
        let movie = Movie(
            id: 1,
            title: "Test",
            overview: "Test overview",
            posterPath: "/poster.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "2023-12-25",
            voteAverage: 7.8,
            voteCount: 500,
            popularity: 88.2,
            revenue: 75000000
        )
        
        XCTAssertEqual(movie.formattedReleaseYear, "2023")
        XCTAssertEqual(movie.formattedRating, "7.8")
        XCTAssertTrue(movie.fullPosterURL?.contains("w500/poster.jpg") ?? false)
    }
}
