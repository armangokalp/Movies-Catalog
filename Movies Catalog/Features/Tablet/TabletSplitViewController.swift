//
//  TabletSplitViewController.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 31.08.2025.
//

import UIKit

class TabletSplitViewController: UISplitViewController {
    
    private let factory: ViewControllerFactory
    private var movieListVC: MovieListViewController
    private var detailNavigationController: UINavigationController
    private var placeholderDetailVC: PlaceholderDetailViewController
    
    init(factory: ViewControllerFactory) {
        self.factory = factory
        self.movieListVC = factory.makeMovieListViewController()
        self.placeholderDetailVC = PlaceholderDetailViewController()
        self.detailNavigationController = UINavigationController(rootViewController: placeholderDetailVC)
        
        super.init(style: .doubleColumn)
        
        setupSplitView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSplitView() {
        preferredDisplayMode = .oneBesideSecondary
        preferredSplitBehavior = .tile
        
        minimumPrimaryColumnWidth = Constants.SplitView.minimumPrimaryColumnWidth
        maximumPrimaryColumnWidth = Constants.SplitView.maximumPrimaryColumnWidth
        preferredPrimaryColumnWidthFraction = Constants.SplitView.preferredPrimaryColumnWidthFraction
        
        let primaryNavController = UINavigationController(rootViewController: movieListVC)
        
        viewControllers = [primaryNavController, detailNavigationController]
        
        movieListVC.onMovieSelected = { [weak self] movie in
            self?.showMovieDetail(movie: movie)
        }
        
        primaryNavController.navigationBar.prefersLargeTitles = false
        detailNavigationController.navigationBar.prefersLargeTitles = false
    }
    
    private func showMovieDetail(movie: Movie) {
        let detailVC = factory.makeMovieDetailViewController(movie: movie)
        detailNavigationController.setViewControllers([detailVC], animated: true)
    }
}

class PlaceholderDetailViewController: UIViewController {
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Select a movie to view details"
        label.font = Constants.Typography.title2
        label.textColor = Constants.Colors.secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "film.fill"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Constants.Colors.secondary.withAlphaComponent(0.3)
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = Constants.Colors.background
        
        view.addSubview(iconImageView)
        view.addSubview(placeholderLabel)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -Constants.Spacing.xxxLarge),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.Spacing.enormous),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.Spacing.enormous),
            
            placeholderLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: Constants.Spacing.large),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Spacing.xLarge),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Spacing.xLarge)
        ])
    }
}
