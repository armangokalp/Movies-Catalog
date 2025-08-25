//
//  MovieListViewController.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 25.08.2025.
//

import UIKit

class MovieListViewController: UIViewController {
    
    private var moviesByCategory: [MovieCategory: [Movie]] = [:]
    private let apiService = APIService.shared
    
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMovies()
    }
    
    
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Movies Catalog"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    
    
    private func loadMovies() {
        let group = DispatchGroup()
        
        for category in MovieCategory.allCases {
            group.enter()
            apiService.fetchMovies(category: category) { [weak self] result in
                defer { group.leave() }
                
                switch result {
                case .success(let response):
                    self?.moviesByCategory[category] = response.results
                case .failure(let error):
                    print("Failed to load \(category.displayName): \(error)")
                }
            }
        }
        
        group.notify(queue: .main) {
            self.setupCategorySections()
        }
    }
    
    private func setupCategorySections() {
        for category in MovieCategory.allCases {
            guard let movies = moviesByCategory[category], !movies.isEmpty else { continue }
            
            let sectionView = createCategorySection(for: category, movies: movies)
            stackView.addArrangedSubview(sectionView)
        }
    }
    
    private func createCategorySection(for category: MovieCategory, movies: [Movie]) -> UIView {
        let containerView = UIView()
        
        // Category title
        let titleLabel = UILabel()
        titleLabel.text = category.displayName
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        
        // Collection view
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 200)
        layout.minimumLineSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        
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
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 200),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
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
        return moviesByCategory[category]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as! MovieCollectionViewCell
        
        guard let category = getCategoryFromTag(collectionView.tag),
              let movies = moviesByCategory[category] else {
            return cell
        }
        
        let movie = movies[indexPath.item]
        cell.configure(with: movie)
        
        return cell
    }
}


extension MovieListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let category = getCategoryFromTag(collectionView.tag),
              let movies = moviesByCategory[category] else { return }
        
        let movie = movies[indexPath.item]
        let detailVC = MovieDetailViewController(movie: movie)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
