//
//  PhotoDetailsModelProtocol.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/19.
//

import Foundation
import Combine


///
/// Provides a single photo.
///
protocol PhotoDetailsModelProtocol {
    
    associatedtype Photo: PhotoDetailsProtocol
    
    /// Current photo.
    var photo: CurrentValueSubject<Photo, Never> { get }
    
    /// Error resulting from attempting to load the photo.
    var error: PassthroughSubject<Error, Never> { get }
    
    /// Loads and publishes the photo.
    func reload()
}
