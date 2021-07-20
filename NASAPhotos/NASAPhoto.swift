//
//  NASAPhoto.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/19.
//

import Foundation


///
/// Information about a photo provided by the NASA images API.
///
struct NASAPhoto {
    var id: String
    var title: String?
    var dateCreated: Date?
    var photographer: String?
    var details: String?
    var thumbnailImageURL: URL?
    var previewImageURL: URL?
    var manifestURL: URL?
}

extension NASAPhoto: PhotoProtocol {
    
}

extension NASAPhoto: PhotoDetailsProtocol {
    
}
