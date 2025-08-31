//
//  ImageLoader.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 25.08.2025.
//

// Basic async image loader with in-memory cache

import UIKit
import Foundation
import ObjectiveC

class ImageLoader: ImageLoadingService {
    private let cache = NSCache<NSString, UIImage>()
    private var activeTasks = NSCache<NSString, URLSessionDataTask>()
    
    init() {
        cache.countLimit = Constants.Cache.imageCountLimit
        cache.totalCostLimit = Constants.Cache.imageTotalCostLimit
    }
    
    @discardableResult
    func loadImage(from urlString: String,
                   completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {

        if let cached = cache.object(forKey: urlString as NSString) {
            DispatchQueue.main.async { completion(cached) }
            return nil
        }

        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async { completion(nil) }
            return nil
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let err = error as NSError?, err.code == NSURLErrorCancelled {
                return
            }

            var image: UIImage? = nil
            if let data, let img = UIImage(data: data) {
                image = img
                self?.cache.setObject(img, forKey: urlString as NSString, cost: data.count)
            }

            DispatchQueue.main.async { completion(image) }
        }

        task.resume()
        return task
    }
    
    func cancelTask(for urlString: String) {
        if let existingTask = activeTasks.object(forKey: urlString as NSString) {
            existingTask.cancel()
            activeTasks.removeObject(forKey: urlString as NSString)
        }
    }
}



extension UIImageView {
    private static var currentURLKey: UInt8 = 0
    
    private var currentImageURL: String? {
        get {
            return objc_getAssociatedObject(self, &UIImageView.currentURLKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &UIImageView.currentURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func loadImage(from urlString: String?, placeholderColors: [CGColor] = [Constants.Colors.label.cgColor, Constants.Colors.placeholder.cgColor], completion: ((UIImage?) -> Void)? = nil) {
        
        cancelCurrentImageLoad()
        currentImageURL = nil
        
        createGradientPlaceholder(placeholderColors)
        
        guard let urlString = urlString else { 
            removeGradientPlaceholder()
            completion?(nil)
            return 
        }
        
        currentImageURL = urlString
        
        let imageLoader: ImageLoadingService = AppDependencyContainer.shared.resolve(ImageLoadingService.self)
        imageLoader.loadImage(from: urlString) { [weak self] image in
            DispatchQueue.main.async {
                guard self?.currentImageURL == urlString else {
                    return
                }
                
                self?.removeGradientPlaceholder()
                
                if let loadedImage = image {
                    self?.image = loadedImage
                } else {
                    self?.createGradientPlaceholder(placeholderColors)
                    //self?.image = UIImage(named: "fallback")
                }
                completion?(image)
            }
        }
    }
    
    func cancelCurrentImageLoad() {
        if let currentURL = currentImageURL {
            let imageLoader = AppDependencyContainer.shared.resolve(ImageLoadingService.self) as? ImageLoader
            imageLoader?.cancelTask(for: currentURL)
            currentImageURL = nil
        }
        removeGradientPlaceholder()
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
