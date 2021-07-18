//
//  PhotoDescriptionBuilder.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation


protocol PhotoDescriptionProtocol {
    func makePhotoDescription(photographer: String?, date: Date?) -> String
}

extension PhotoDescriptionProtocol {
    func makePhotoDescription(for photo: Photo) -> String {
        makePhotoDescription(
            photographer: photo.photographer,
            date: photo.dateCreated
        )
    }
}


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
