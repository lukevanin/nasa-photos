//
//  PhotoViewModel.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/14.
//

import Foundation


///
/// Defines the view state for a single photo.
///
struct PhotoInfoViewModel: Identifiable {
    
    /// Unique identifier of the item.
    let id: String
    
    /// URL of the preview image.
    var previewImageURL: URL
    
    /// URL of the original image.
    var originalImageURL: URL

    /// Text title of the photo.
    var title: String
    
    /// Short description of the photo. Includes the photographer and date that the photo was created.
    var description: String
    
    /// Detailed information about the photo.
    var details: String
}
