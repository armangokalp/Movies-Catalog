//
//  MovieCollectionViewCell.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 25.08.2025.
//

// Screen: movie card item

import UIKit

protocol Configurable {
    associatedtype Model
    func configure(with model: Model)
}

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
    
    // image
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        //imageView.backgroundColor = Constants.Colors.placeholder
        imageView.layer.cornerRadius = Constants.CornerRadius.small
        return imageView
    }()
    
    // ProgressView
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
      //  accessibilityLabel = "Movie: \(movie.title)" ///would not hurt to add
      //  accessibilityHint = "Double tap to view movie details"
        
        loadingIndicator.startAnimating()
        
        posterImageView.loadImage(
            from: movie.fullPosterURL
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
            }
        }
        
        // TODO: could add movie title on top of poster if fallback image

    }
    

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        loadingIndicator.stopAnimating()
        accessibilityLabel = nil
        accessibilityHint = nil
    }
    
   /* override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            posterImageView.backgroundColor = Constants.Colors.placeholder
            loadingIndicator.color = Constants.Colors.secondaryLabel
        }
    }*/ /// Could be useful if we want light/dark mode switch
}
