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
    
    
    private let titleOverlayView: UIView = {
        let v = UIView()
        v.isHidden = true
        v.clipsToBounds = true
        return v
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.textAlignment = .center
        l.font = Constants.Typography.semiboldHeadline()
        l.textColor = Constants.Colors.overlayFont
        l.setContentCompressionResistancePriority(.required, for: .vertical)
        l.setContentHuggingPriority(.required, for: .vertical)
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
       // setupAccessibility()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(posterImageView)
        contentView.addSubview(loadingIndicator)
        posterImageView.addSubview(titleOverlayView)
        titleOverlayView.addSubview(titleLabel)
        
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        titleOverlayView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // image
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // ProgressView centers image
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Title for placeholder
            titleOverlayView.leadingAnchor.constraint(equalTo: posterImageView.leadingAnchor),
            titleOverlayView.trailingAnchor.constraint(equalTo: posterImageView.trailingAnchor),
            titleOverlayView.centerYAnchor.constraint(equalTo: posterImageView.centerYAnchor),
           
            titleLabel.leadingAnchor.constraint(equalTo: titleOverlayView.leadingAnchor, constant: Constants.Spacing.small),
            titleLabel.trailingAnchor.constraint(equalTo: titleOverlayView.trailingAnchor, constant: -Constants.Spacing.small),
            titleLabel.bottomAnchor.constraint(equalTo: titleOverlayView.bottomAnchor, constant: -Constants.Spacing.xxLarge),
            titleLabel.topAnchor.constraint(equalTo: titleOverlayView.topAnchor, constant: Constants.Spacing.small)
        ])
    }
    
  /*  private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .button
    }*/
    

    func configure(with movie: Movie) {
      //  accessibilityLabel = "Movie: \(movie.title)" ///would not hurt to add
      //  accessibilityHint = "Double tap to view movie details"
        
        loadingIndicator.stopAnimating()
        hideTitleOverlay()
        
        titleLabel.text = movie.title
        
        loadingIndicator.startAnimating()
        
        posterImageView.loadImage(
            from: movie.fullPosterURL
        ) { [weak self] loaded in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                
                if loaded != nil {
                    self?.hideTitleOverlay()
                } else {
                    self?.showTitleOverlay()
                }
            }
        }
    }
    
    private func showTitleOverlay() {
        titleOverlayView.isHidden = false
    }
    private func hideTitleOverlay() {
        titleOverlayView.isHidden = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        posterImageView.cancelCurrentImageLoad()
        posterImageView.image = nil
        loadingIndicator.stopAnimating()
        hideTitleOverlay()
       // accessibilityLabel = nil
       // accessibilityHint = nil
    }
    
   /* override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            posterImageView.backgroundColor = Constants.Colors.placeholder
            loadingIndicator.color = Constants.Colors.secondaryLabel
        }
    }*/ /// Could be useful if we want light/dark mode switch
}
