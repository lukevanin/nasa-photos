//
//  PhotoDescriptionBuilder.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation


///
/// Abstract interface for formatting a description of a photo, given a photographer's name and a date.
///
protocol PhotoDescriptionProtocol {
    func makePhotoDescription(photographer: String?, date: Date?) -> String
}

extension PhotoDescriptionProtocol {
    
    ///
    /// Convenience method that provides a formatted description from a photo instance.
    ///
    func makePhotoDescription(for photo: Photo) -> String {
        makePhotoDescription(
            photographer: photo.photographer,
            date: photo.dateCreated
        )
    }
}


///
/// Provides a formatted description of a photo given a photographer and date. Uses a date formatter to
/// create a localized representation of the date.
///
final class PhotoDescriptionFormatter: PhotoDescriptionProtocol {
    
    private let dateFormatter: DateFormatter
    
    init(dateFormatter: DateFormatter) {
        self.dateFormatter = dateFormatter
    }
    
    func makePhotoDescription(photographer: String?, date: Date?) -> String {
        let formattedDate = date.map(dateFormatter.string)
        switch (formattedDate, photographer) {
        case (.some(let date), .some(let photographer)):
            #warning("TODO: Use localized string for formatting photo description")
            return "\(photographer) | \(date)"
        case (.some(let date), .none):
            return date
        case (.none, .some(let photographer)):
            return photographer
        case (.none, .none):
            return ""
        }
    }
}
