//
//  ServiceProtocols.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 29.08.2025.
//

import Foundation
import UIKit

protocol MovieAPIService {
    func fetchMovies(category: MovieCategory, page: Int, completion: @escaping (Result<MoviesResponse, Error>) -> Void)
}

protocol ImageLoadingService {
    @discardableResult
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask?
}


/*
protocol NavigationService {
    func pushViewController(_ viewController: UIViewController, animated: Bool)
    func presentViewController(_ viewController: UIViewController, animated: Bool)
    func dismissViewController(animated: Bool)
}*/ /// Not currently used but prepared for possible navigation abstraction


protocol ViewControllerFactory {
    func makeMovieListViewController() -> MovieListViewController
    func makeMovieDetailViewController(movie: Movie) -> MovieDetailViewController
    func makeMoviePlayerViewController(viewModel: MovieDetailViewModel) -> MoviePlayerViewController
}
