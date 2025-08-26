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
    func loadImage(from urlString: String?, placeholder: UIImage? = nil, completion: ((UIImage?) -> Void)? = nil) {
        self.image = placeholder
        
        guard let urlString = urlString else { 
            completion?(nil)
            return 
        }
        
        ImageLoader.shared.loadImage(from: urlString) { [weak self] image in
            DispatchQueue.main.async {
                self?.image = image ?? placeholder
                completion?(image)
            }
        }
    }
}
