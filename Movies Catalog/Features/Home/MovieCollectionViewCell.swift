//
//  MovieCollectionViewCell.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 25.08.2025.
//

import UIKit

// Configurable Protocol for Reusability
protocol Configurable {
    associatedtype Model
    func configure(with model: Model)
}

// Identifier
protocol Reusable {
    static var identifier: String { get }
}

extension Reusable {
    static var identifier: String {
        return String(describing: self)
    }
}

class MovieCollectionViewCell: UICollectionViewCell, Configurable, Reusable {
    typealias Model = Movie
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.CornerRadius.small
        imageView.backgroundColor = Constants.Colors.placeholder
        return imageView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = Constants.Colors.secondaryLabel
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupAccessibility()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(loadingIndicator)
        
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .button
    }
    

    func configure(with movie: Movie) {
        accessibilityLabel = "Movie: \(movie.title)"
        accessibilityHint = "Double tap to view movie details"
        
        loadingIndicator.startAnimating()
        
        posterImageView.loadImage(
            from: movie.fullPosterURL,
            placeholder: UIImage(systemName: "popcorn")?
                .withTintColor(Constants.Colors.primary, renderingMode: .alwaysOriginal)
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
            }
        }
    }
    

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        loadingIndicator.stopAnimating()
        accessibilityLabel = nil
        accessibilityHint = nil
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            posterImageView.backgroundColor = Constants.Colors.placeholder
            loadingIndicator.color = Constants.Colors.secondaryLabel
        }
    }
}
