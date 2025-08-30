//
//  ViewControllerFactory.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 29.08.2025.
//

import UIKit

final class AppViewControllerFactory: ViewControllerFactory {
    private let container: DependencyContainer
    
    init(container: DependencyContainer = AppDependencyContainer.shared) {
        self.container = container
    }
    
    func makeMovieListViewController() -> MovieListViewController {
        let apiService: MovieAPIService = container.resolve(MovieAPIService.self)
        let cacheService: CacheServiceProtocol = container.resolve(CacheServiceProtocol.self)
        let viewModel = MovieListViewModel(apiService: apiService, cacheService: cacheService)
        return MovieListViewController(viewModel: viewModel, factory: self)
    }
    
    func makeMovieDetailViewController(movie: Movie) -> MovieDetailViewController {
        let viewModel = MovieDetailViewModel(movie: movie)
        return MovieDetailViewController(viewModel: viewModel, factory: self)
    }
    
    func makeMoviePlayerViewController(viewModel: MovieDetailViewModel) -> MoviePlayerViewController {
        return MoviePlayerViewController(detailViewModel: viewModel)
    }
}

/*final class AppNavigationService: NavigationService {
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func presentViewController(_ viewController: UIViewController, animated: Bool) {
        navigationController?.present(viewController, animated: animated)
    }
    
    func dismissViewController(animated: Bool) {
        navigationController?.dismiss(animated: animated)
    }
}
*/ /// Future potential use if we want a navigation handler
