//
//  Constants.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 26.08.2025.
//

import UIKit

struct Constants {
    
    struct Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
        static let xxLarge: CGFloat = 24
        static let xxxLarge: CGFloat = 32
        static let huge: CGFloat = 50
    }
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 20
        static let xLarge: CGFloat = 25
    }
    
    struct Dimensions {
        static let posterWidth: CGFloat = 120
        static let posterHeight: CGFloat = 200
        static let posterAspectRatio: CGFloat = 1.5
        static let backdropHeight: CGFloat = 250
        static let detailPosterWidth: CGFloat = 100
        static let detailPosterHeight: CGFloat = 150
        static let buttonHeight: CGFloat = 50
        static let closeButtonSize: CGFloat = 40
        static let playButtonSize: CGFloat = 75
        static let borderWidth: CGFloat = 3
    }
    
    struct Animation {
        static let defaultDuration: TimeInterval = 0.3
        static let controlsHideDelay: TimeInterval = 3.0
    }
    
    struct Cache {
        static let imageCountLimit: Int = 100
        static let imageTotalCostLimit: Int = 50 * 1024 * 1024
    }
    
}

extension Constants {
    struct Typography {
        static let largeTitle = UIFont.preferredFont(forTextStyle: .largeTitle)
        static let title1 = UIFont.preferredFont(forTextStyle: .title1)
        static let title2 = UIFont.preferredFont(forTextStyle: .title2)
        static let title3 = UIFont.preferredFont(forTextStyle: .title3)
        static let headline = UIFont.preferredFont(forTextStyle: .headline)
        static let body = UIFont.preferredFont(forTextStyle: .body)
        static let callout = UIFont.preferredFont(forTextStyle: .callout)
        static let subheadline = UIFont.preferredFont(forTextStyle: .subheadline)
        static let footnote = UIFont.preferredFont(forTextStyle: .footnote)
        static let caption1 = UIFont.preferredFont(forTextStyle: .caption1)
        static let caption2 = UIFont.preferredFont(forTextStyle: .caption2)
        
        static func boldTitle1() -> UIFont {
            return UIFont.preferredFont(forTextStyle: .title1).withWeight(.bold)
        }
        
        static func boldTitle2() -> UIFont {
            return UIFont.preferredFont(forTextStyle: .title2).withWeight(.bold)
        }
        
        static func boldTitle3() -> UIFont {
            return UIFont.preferredFont(forTextStyle: .title3).withWeight(.bold)
        }
        
        static func semiboldHeadline() -> UIFont {
            return UIFont.preferredFont(forTextStyle: .headline).withWeight(.semibold)
        }
        
        static func mediumBody() -> UIFont {
            return UIFont.preferredFont(forTextStyle: .body).withWeight(.medium)
        }
    }
}

extension Constants {
    struct Colors {
        static let primary = UIColor.systemRed
        static let secondary = UIColor.systemOrange
        static let background = UIColor.systemBackground
        static let label = UIColor.label
        static let secondaryLabel = UIColor.secondaryLabel
        static let placeholder = UIColor.systemGray5
        static let overlay = UIColor.black.withAlphaComponent(0.5)
        static let controlsBackground = UIColor.black.withAlphaComponent(0.6)
    }
}

extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: weight]
        ])
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
