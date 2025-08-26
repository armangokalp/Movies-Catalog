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
    
    func playMovie() -> MoviePlayerViewController {
        return MoviePlayerViewController()
    }
}
