//
//  MovieListViewController.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 25.08.2025.
//

// Screen: home with movie carousels


import UIKit

class MovieListViewController: UIViewController {
    // DI
    private let viewModel: MovieListViewModel
    private let factory: ViewControllerFactory
    
    // For tablet split view
    var onMovieSelected: ((Movie) -> Void)?
    
    private var bgGradientLayer: CAGradientLayer?
    private var categories: [MovieCategory] = []
    private var diffableDataSource: UICollectionViewDiffableDataSource<MovieCategory, MovieItem>!
    
    // MARK: UI components
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderView.identifier)
        collectionView.delegate = self
        return collectionView
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
    
    
    //MARK: Layout
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            return self?.createCategorySection()
        }
    }
    
    private func createCategorySection() -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(Constants.Dimensions.posterWidth),
            heightDimension: .absolute(Constants.Dimensions.posterHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(Constants.Dimensions.posterWidth),
            heightDimension: .absolute(Constants.Dimensions.posterHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = Constants.Spacing.tiny
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Constants.Spacing.tiny,
            bottom: Constants.Spacing.large,
            trailing: Constants.Spacing.tiny
        )
        
        // Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        // Visible items changed callback for pagination
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, point, environment in
            guard let self = self else { return }
            
            let sectionIndex = visibleItems.first?.indexPath.section ?? 0
            guard sectionIndex < self.categories.count else { return }
            
            let category = self.categories[sectionIndex]
            let maxIndex = visibleItems.map { $0.indexPath.item }.max() ?? 0
            
            if self.viewModel.shouldLoadMore(for: category, at: maxIndex) {
                self.viewModel.loadMoreMovies(for: category)
            }
        }
        
        return section
    }
    
    
    init(viewModel: MovieListViewModel, factory: ViewControllerFactory) {
        self.viewModel = viewModel
        self.factory = factory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDiffableDataSource()
        setupBindings()
        viewModel.loadMovies()
        bgGradientLayer = view.setGradientBackground([Constants.Colors.background, Constants.Colors.secondaryBackground])
        
        categories = MovieCategory.allCases
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //Resized gradient layer to always fill divider view
        navBarGradientDivider.layer.sublayers?.first?.frame = navBarGradientDivider.bounds
        
        bgGradientLayer?.frame = view.bounds
    }
    
    
    //MARK: Setup
    
    private func setupUI() {
        navigationItem.titleView = appLogoImageView
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        view.addSubview(navBarGradientDivider)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Divider on top
            navBarGradientDivider.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBarGradientDivider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBarGradientDivider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBarGradientDivider.heightAnchor.constraint(equalToConstant: 2),
            
            // Collection view
            collectionView.topAnchor.constraint(equalTo: navBarGradientDivider.bottomAnchor, constant: Constants.Spacing.large),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    
    private func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            self?.updateDataSource()
        }
        
        viewModel.onCategoryUpdated = { [weak self] category in
            self?.updateCategory(category)
        }
        
        viewModel.onError = { errorMessage in
            print(errorMessage) // Could give in-app feedback
        }
        
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            if isLoading {
                self?.loadingIndicator.startAnimating()
                self?.collectionView.alpha = 0.5
            } else {
                self?.loadingIndicator.stopAnimating()
                self?.collectionView.alpha = 1.0
            }
        }
    }
    
    private func setupDiffableDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource<MovieCategory, MovieItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, movieItem in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MovieCollectionViewCell.identifier,
                for: indexPath
            ) as! MovieCollectionViewCell
            cell.configure(with: movieItem.movie)
            return cell
        }
        
        diffableDataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else {
                return UICollectionReusableView()
            }
            
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CategoryHeaderView.identifier,
                for: indexPath
            ) as! CategoryHeaderView
            
            let category = self.categories[indexPath.section]
            headerView.configure(with: category.displayName)
            return headerView
        }
    }
    
    private func updateDataSource() {
        categories = MovieCategory.allCases
        applySnapshot()
    }
    
    private func updateCategory(_ category: MovieCategory) {
        applySnapshot()
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<MovieCategory, MovieItem>()
        
        for category in categories {
            snapshot.appendSections([category])
            let movies = viewModel.getMovies(for: category)
            let movieItems = movies.map { MovieItem(movie: $0, category: category) }
            snapshot.appendItems(movieItems, toSection: category)
        }
        
        diffableDataSource.apply(snapshot, animatingDifferences: false)
    }

}



extension MovieListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section < categories.count else { return }
        let category = categories[indexPath.section]
        
        guard let movie = viewModel.getMovie(for: category, at: indexPath.item) else { return }
        
        if let onMovieSelected = onMovieSelected {
            // Tablet
            onMovieSelected(movie)
        } else {
            // Phone
            let detailVC = factory.makeMovieDetailViewController(movie: movie)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

class CategoryHeaderView: UICollectionReusableView {
    static let identifier = "CategoryHeaderView"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Typography.boldTitle3()
        label.textColor = Constants.Colors.label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.Spacing.tiny),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.Spacing.tiny),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.Spacing.small)
        ])
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
