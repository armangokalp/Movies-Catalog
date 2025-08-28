//
//  MovieDetailViewController.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 25.08.2025.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    private let viewModel: MovieDetailViewModel
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var backdropImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.systemGray5
        return imageView
    }()
    
    private lazy var gradientView: UIView = {
        let view = UIView()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, Constants.Colors.background.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        view.layer.addSublayer(gradientLayer)
        return view
    }()
    
    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.CornerRadius.medium
        imageView.layer.borderWidth = Constants.Dimensions.borderWidth
        imageView.layer.borderColor = Constants.Colors.background.cgColor
        imageView.backgroundColor = Constants.Colors.placeholder
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Typography.boldTitle1()
        label.textColor = Constants.Colors.label
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var yearLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Typography.mediumBody()
        label.textColor = Constants.Colors.secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Typography.semiboldHeadline()
        label.textColor = Constants.Colors.secondary
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("▶ Play Movie", for: .normal)
        button.titleLabel?.font = Constants.Typography.semiboldHeadline()
        button.backgroundColor = Constants.Colors.primary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.CornerRadius.xLarge
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var overviewTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Overview"
        label.font = Constants.Typography.title3
        label.textColor = Constants.Colors.label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var overviewLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Typography.body
        label.textColor = Constants.Colors.label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    init(movie: Movie) {
        self.viewModel = MovieDetailViewModel(movie: movie)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithMovie()
        view.setGradientBackground([Constants.Colors.background,Constants.Colors.background, Constants.Colors.secondaryBackground])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientFrame()
    }
    
    private func setupUI() {
        view.backgroundColor = Constants.Colors.background
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = Constants.Colors.primary
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backdropImageView)
        contentView.addSubview(gradientView)
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(yearLabel)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(playButton)
        contentView.addSubview(overviewTitleLabel)
        contentView.addSubview(overviewLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        backdropImageView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        overviewTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Backdrop Image
            backdropImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backdropImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backdropImageView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.backdropHeight),
            
            // Gradient View
            gradientView.topAnchor.constraint(equalTo: backdropImageView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: backdropImageView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: backdropImageView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: backdropImageView.bottomAnchor),
            
            // Poster Image
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Spacing.xLarge),
            posterImageView.bottomAnchor.constraint(equalTo: backdropImageView.bottomAnchor, constant: -Constants.Spacing.xLarge),
            posterImageView.widthAnchor.constraint(equalToConstant: Constants.Dimensions.detailPosterWidth),
            posterImageView.heightAnchor.constraint(equalToConstant: Constants.Dimensions.detailPosterHeight),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: backdropImageView.bottomAnchor, constant: Constants.Spacing.xLarge),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Spacing.xLarge),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Spacing.xLarge),
            
            // Year Label
            yearLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.Spacing.small),
            yearLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            // Rating Label
            ratingLabel.centerYAnchor.constraint(equalTo: yearLabel.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Play Button
            playButton.topAnchor.constraint(equalTo: yearLabel.bottomAnchor, constant: Constants.Spacing.xxLarge),
            playButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Spacing.xLarge),
            playButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Spacing.xLarge),
            playButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.buttonHeight),
            
            // Overview Title
            overviewTitleLabel.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: Constants.Spacing.xxxLarge),
            overviewTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Spacing.xLarge),
            overviewTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Spacing.xLarge),
            
            // Overview Label
            overviewLabel.topAnchor.constraint(equalTo: overviewTitleLabel.bottomAnchor, constant: Constants.Spacing.medium),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Spacing.xLarge),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Spacing.xLarge),
            overviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Spacing.xxxLarge)
        ])
    }
    
    private func configureWithMovie() {
        
        titleLabel.text = viewModel.title
        yearLabel.text = viewModel.year
        ratingLabel.text = viewModel.rating
        overviewLabel.text = viewModel.overview
        
        backdropImageView.loadImage(
            from: viewModel.backdropURL,
            placeholderColors: [Constants.Colors.placeholder.cgColor, Constants.Colors.background.cgColor]
        )
        posterImageView.loadImage(
            from: viewModel.posterURL
        )
    }
    
    private func updateGradientFrame() {
        CATransaction.begin()
        CATransaction.setDisableActions(true) // disable animation
        if let gradientLayer = gradientView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = gradientView.bounds
        }
        CATransaction.commit()
    }
    
    @objc private func playButtonTapped() {
        let playerVC = viewModel.playMovie()
        playerVC.modalPresentationStyle = .pageSheet
            
//        forcePortrait()
        
        present(playerVC, animated: true)
    }
    
    /*private func forcePortrait() {
        // MovieDetailVC stays portrait after dismissing MoviePlayerVC
        CATransaction.begin()
        CATransaction.setDisableActions(true) // disable animation
        if let windowScene = view.window?.windowScene {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        }
        CATransaction.commit()
    }*/

}
