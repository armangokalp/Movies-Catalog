//
//  Models.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 25.08.2025.
//

import Foundation

struct Movie: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let revenue: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, popularity, revenue
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    var fullPosterURL: String? {
        guard let posterPath = posterPath else { return nil }
        return "https://image.tmdb.org/t/p/w500\(posterPath)"
    }
    
    var fullBackdropURL: String? {
        guard let backdropPath = backdropPath else { return nil }
        return "https://image.tmdb.org/t/p/w780\(backdropPath)"
    }
    
    var formattedRating: String {
        return String(format: "%.1f", voteAverage)
    }
    
    var formattedReleaseYear: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: releaseDate) {
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            return yearFormatter.string(from: date)
        }
        return ""
    }
    
}


struct MoviesResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

enum MovieCategory: String, CaseIterable {
    case popular = "popularity.desc"
    case topRated = "vote_average.desc"
    case revenue = "revenue.desc"
    case releaseDate = "release_date.desc"
    
    var displayName: String {
        switch self {
        case .popular:
            return "Popular"
        case .topRated:
            return "Top Rated"
        case .revenue:
            return "Revenue"
        case .releaseDate:
            return "Release Date"
        }
    }
}
