//
//  StandardTheme.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/18.
//

import UIKit

///
/// User interface theme using a custom font and font size.
///
final class CustomTheme: ThemeProtocol {

    func titleFont() -> UIFont? {
        let baseFont = UIFont(name: "HelveticaNeue-Bold", size: 16)!
        return UIFontMetrics(forTextStyle: .headline).scaledFont(for: baseFont)
    }
    
    func subtitleFont() -> UIFont? {
        let baseFont = UIFont(name: "HelveticaNeue", size: 14)!
        return UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: baseFont)
    }
    
    func bodyFont() -> UIFont? {
        let font = UIFont(name: "HelveticaNeue", size: 16)!
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
    }
}
