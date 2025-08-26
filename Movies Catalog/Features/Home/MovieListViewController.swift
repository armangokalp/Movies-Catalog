//
//  MovieListViewController.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 25.08.2025.
//

import UIKit

class MovieListViewController: UIViewController {
    
    private let viewModel = MovieListViewModel()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = Constants.Colors.secondary
        return indicator
    }()
    
    private lazy var appLogoImageView: UIImageView = {
        let logoImageView = UIImageView(image: UIImage(systemName: "film.fill"))
        logoImageView.contentMode = .scaleAspectFill
        logoImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        logoImageView.tintColor = Constants.Colors.primary
        
        return logoImageView
    }()
    
    private lazy var navBarGradientDivider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            Constants.Colors.primary.withAlphaComponent(0.15).cgColor,
            Constants.Colors.primary.cgColor,
            Constants.Colors.primary.withAlphaComponent(0.15).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.locations = [0, 0.5, 1]
        
        view.layer.addSublayer(gradient)
        
        view.layer.shadowColor = Constants.Colors.primary.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 4
        view.layer.zPosition = 1
        
        return view
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadMovies()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navBarGradientDivider.layer.sublayers?.first?.frame = navBarGradientDivider.bounds
    }
    
    private func setupUI() {
        view.backgroundColor = Constants.Colors.background
        
        navigationItem.titleView = appLogoImageView
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        
        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        stackView.addSubview(navBarGradientDivider)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navBarGradientDivider.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBarGradientDivider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBarGradientDivider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBarGradientDivider.heightAnchor.constraint(equalToConstant: 2),
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.Spacing.large),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    
    private func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            self?.setupCategorySections()
        }
        
        viewModel.onError = { errorMessage in
            print(errorMessage)
        }
        
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            if isLoading {
                self?.loadingIndicator.startAnimating()
                self?.scrollView.alpha = 0.5
            } else {
                self?.loadingIndicator.stopAnimating()
                self?.scrollView.alpha = 1.0
            }
        }
    }
    
    private func setupCategorySections() {
        for category in MovieCategory.allCases {
            let movies = viewModel.getMovies(for: category)
            guard !movies.isEmpty else { continue }
            
            let sectionView = createCategorySection(for: category, movies: movies)
            stackView.addArrangedSubview(sectionView)
        }
    }
    
    private func createCategorySection(for category: MovieCategory, movies: [Movie]) -> UIView {
        let containerView = UIView()
        
        // Category title
        let titleLabel = UILabel()
        titleLabel.text = category.displayName
        titleLabel.font = Constants.Typography.boldTitle3()
        titleLabel.textColor = Constants.Colors.label
        titleLabel.adjustsFontForContentSizeCategory = true
        
        // Collection view
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: Constants.Dimensions.posterWidth, height: Constants.Dimensions.posterHeight)
        layout.minimumLineSpacing = Constants.Spacing.tiny
        layout.sectionInset = UIEdgeInsets(top: 0, left: Constants.Spacing.tiny, bottom: 0, right: Constants.Spacing.tiny)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.tag = category.hashValue
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(collectionView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.Spacing.tiny),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.Spacing.tiny),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.Spacing.small),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.posterHeight),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.Spacing.large)
        ])
        
        return containerView
    }
    
    private func getCategoryFromTag(_ tag: Int) -> MovieCategory? {
        return MovieCategory.allCases.first { $0.hashValue == tag }
    }
}


extension MovieListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let category = getCategoryFromTag(collectionView.tag) else { return 0 }
        return viewModel.getMovies(for: category).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as! MovieCollectionViewCell
        
        guard let category = getCategoryFromTag(collectionView.tag),
              let movie = viewModel.getMovie(for: category, at: indexPath.item) else {
            return cell
        }
        
        cell.configure(with: movie)
        return cell
    }
}


extension MovieListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let category = getCategoryFromTag(collectionView.tag),
              let movie = viewModel.getMovie(for: category, at: indexPath.item) else { return }
        
        let detailVC = MovieDetailViewController(movie: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
