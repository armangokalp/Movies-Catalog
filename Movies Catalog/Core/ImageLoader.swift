//
//  ImageLoader.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 25.08.2025.
//

import UIKit

class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = Constants.Cache.imageCountLimit
        cache.totalCostLimit = Constants.Cache.imageTotalCostLimit
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Cache kontrol
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Cache le
            self?.cache.setObject(image, forKey: urlString as NSString)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}



extension UIImageView {
    func loadImage(from urlString: String?, placeholderColors: [CGColor] = [Constants.Colors.label.cgColor, Constants.Colors.placeholder.cgColor], completion: ((UIImage?) -> Void)? = nil) {
        
        createGradientPlaceholder(placeholderColors)
        
        guard let urlString = urlString else { 
            completion?(nil)
            return 
        }
        
        ImageLoader.shared.loadImage(from: urlString) { [weak self] image in
            DispatchQueue.main.async {
                if let loadedImage = image {
                    self?.removeGradientPlaceholder()
                    self?.image = loadedImage
                } else {
                    self?.image = UIImage(named: "")
                }
                completion?(image)
            }
        }
    }
    
    private func createGradientPlaceholder(_ gradientColors: [CGColor]) {
        //removeGradientPlaceholder()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.cornerRadius = layer.cornerRadius
        gradientLayer.name = "placeholderGradient"
        
        let icon = UIImageView(image: UIImage(systemName: "film.fill"))
        icon.tintColor = Constants.Colors.primary
        
        // Set frame in layoutSubviews to ensure proper sizing
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            gradientLayer.frame = self.bounds
            self.layer.insertSublayer(gradientLayer, at: 0)
            //gradientLayer.insertSublayer(icon, at: 0)
        }
    }
    
    private func removeGradientPlaceholder() {
        layer.sublayers?.removeAll { layer in
            layer.name == "placeholderGradient"
        }
    }
}
