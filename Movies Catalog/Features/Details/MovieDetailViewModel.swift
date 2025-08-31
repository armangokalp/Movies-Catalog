//
//  MovieDetailViewModel.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 26.08.2025.
//


import Foundation
import UIKit

class MovieDetailViewModel {
    
    private let movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
    }

    
    var title: String           { return movie.title }
    var year: String            { return movie.formattedReleaseYear }
    var rating: String          { return "⭐ \(movie.formattedRating)" }
    var overview: String        { return movie.overview }
    var posterURL: String?      { return movie.fullPosterURL }
    var backdropURL: String?    { return movie.fullBackdropURL }
    
    // for MoviePlayer info section
    var date: String            { return movie.releaseDate.isEmpty ? "" : "\(movie.releaseDate) 📅" }
    var voteCount: String       { return "\(movie.voteCount) votes" }
    var popularity: String      { return String(format: "%.1f popularity", movie.popularity) }
    var revenue: String?        { 
        guard let revenue = movie.revenue, revenue > 0 else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: revenue))
    }
    
}
