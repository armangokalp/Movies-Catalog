//
//  ImageLoader.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 25.08.2025.
//

// Basic async image loader with in-memory cache

import UIKit

class ImageLoader: ImageLoadingService {
    private let cache = NSCache<NSString, UIImage>()
    
    init() {
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
            guard let data = data,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            // Cache le
            let cost = data.count
            self?.cache.setObject(image, forKey: urlString as NSString, cost: cost)

            DispatchQueue.main.async {
                completion(image)
            }

        }.resume()
    }
}



extension UIImageView {
    func loadImage(from urlString: String?, placeholderColors: [CGColor] = [Constants.Colors.label.cgColor, Constants.Colors.placeholder.cgColor], completion: ((UIImage?) -> Void)? = nil) {
        
        createGradientPlaceholder(placeholderColors) ///while loading
        
        guard let urlString = urlString else { 
            completion?(nil)
            return 
        }
        
        let imageLoader: ImageLoadingService = AppDependencyContainer.shared.resolve(ImageLoadingService.self)
        imageLoader.loadImage(from: urlString) { [weak self] image in
            DispatchQueue.main.async {
                if let loadedImage = image {
                    self?.removeGradientPlaceholder()
                    self?.image = loadedImage
                } else {
                    //self?.image = UIImage(named: "fallback")
                }
                completion?(image)
            }
        }
    }
    
    private func createGradientPlaceholder(_ gradientColors: [CGColor]) {
        removeGradientPlaceholder() ///avoid stacking
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.cornerRadius = layer.cornerRadius
        gradientLayer.name = "placeholderGradient"
        
        // init size before gradient
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            gradientLayer.frame = self.bounds
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    private func removeGradientPlaceholder() {
        layer.sublayers?.removeAll { layer in
            layer.name == "placeholderGradient"
        }
    }
}
