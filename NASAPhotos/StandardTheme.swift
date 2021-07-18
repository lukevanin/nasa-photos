//
//  StandardTheme.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/18.
//

import UIKit

///
/// User interface theme using system defaults.
///
final class StandardTheme: ThemeProtocol {

    func titleFont() -> UIFont? {
        UIFont.preferredFont(forTextStyle: .headline)
    }
    
    func subtitleFont() -> UIFont? {
        UIFont.preferredFont(forTextStyle: .subheadline)
    }
    
    func bodyFont() -> UIFont? {
        UIFont.preferredFont(forTextStyle: .body)
    }
}
