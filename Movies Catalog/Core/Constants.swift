//
//  Constants.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 26.08.2025.
//

import UIKit

struct Constants {
    
    private static var activeTraits: UITraitCollection {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first(where: { $0.isKeyWindow }) {
            return window.traitCollection
        }
        return UIScreen.main.traitCollection
    }
    private static var isPad: Bool { activeTraits.userInterfaceIdiom == .pad }

    struct Spacing {
        static var tiny: CGFloat { Constants.isPad ? 6 : 4 }
        static var small: CGFloat { Constants.isPad ? 12 : 8 }
        static var medium: CGFloat { Constants.isPad ? 16 : 12 }
        static var large: CGFloat { Constants.isPad ? 24 : 16 }
        static var xLarge: CGFloat { Constants.isPad ? 28 : 20 }
        static var xxLarge: CGFloat { Constants.isPad ? 32 : 24 }
        static var xxxLarge: CGFloat { Constants.isPad ? 40 : 32 }
        static var huge: CGFloat { Constants.isPad ? 64 : 50 }
        static var enormous: CGFloat { Constants.isPad ? 80 : 64 }
    }
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 20
        static let xLarge: CGFloat = 25
    }
    
    struct Dimensions {
        static var posterSize: CGSize { Constants.isPad ? .init(width: 160, height: 260) : .init(width: 120, height: 200) }
        static var posterWidth: CGFloat { posterSize.width }
        static var posterHeight: CGFloat { posterSize.height }

        static var backdropHeight: CGFloat { Constants.isPad ? 450 : 250 }

        static var detailPosterSize: CGSize { Constants.isPad ? .init(width: 140, height: 210) : .init(width: 100, height: 150) }
        static var detailPosterWidth: CGFloat { detailPosterSize.width }
        static var detailPosterHeight: CGFloat { detailPosterSize.height }

        static var buttonHeight: CGFloat { Constants.isPad ? 56 : 50 }
        static var closeButtonSize: CGFloat { Constants.isPad ? 48 : 40 }
        static var playButtonSize: CGFloat { Constants.isPad ? 84 : 75 }
        static var borderWidth: CGFloat { Constants.isPad ? 4 : 3 }
    }
    
    struct SplitView {
        static var minimumPrimaryColumnWidth: CGFloat = 320
        static var maximumPrimaryColumnWidth: CGFloat = 900
        static var preferredPrimaryColumnWidthFraction: CGFloat = 0.5
    }
    
    struct Animation {
        static let defaultDuration: TimeInterval = 0.3
        static let controlsHideDelay: TimeInterval = 3.0
    }
    
    struct Cache {
        // NSCache
        static let imageCountLimit: Int = 100
        static let imageTotalCostLimit: Int = 50 * 1024 * 1024
        // Offline Cache
        static let imagePerRequest: Int = 20
        static let offlineCacheLimitPerCategory: Int = 40
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
        static let secondaryBackground = UIColor.secondarySystemBackground
        static let label = UIColor.label
        static let secondaryLabel = UIColor.secondaryLabel
        static let placeholder = UIColor(red: 0.07, green: 0.05, blue: 0.06, alpha: 1)
        static let overlay = UIColor.black.withAlphaComponent(0.5)
        static let overlayFont = UIColor.black
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
