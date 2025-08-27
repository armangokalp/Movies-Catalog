//
//  GradientBackground.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 27.08.2025.
//

import UIKit

extension UIView {
    func setGradientBackground(_ colors: [UIColor],
                               startPoint: CGPoint = CGPoint(x: 0.5, y: 0),
                               endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = bounds
        gradient.masksToBounds = true
        layer.insertSublayer(gradient, at: 0)
    }
}
