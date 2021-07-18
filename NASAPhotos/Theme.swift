//
//  Theme.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/18.
//

import UIKit


///
/// Defines an abstract interface for providing commonly used user interface attributes defined by the
/// design system. The theme, together with the user interface objects, defines the catalog of components
/// used to create user interfaces.
///
protocol ThemeProtocol {
    func titleFont() -> UIFont?
    func subtitleFont() -> UIFont?
    func bodyFont() -> UIFont?
}


///
/// Global service locator that provides the theme used by all user interface elements.
///
final class Theme {
    static var current: ThemeProtocol = StandardTheme()
}
