//
//  FoundationExtensions.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/16.
//

import Foundation


extension URL {
    func usingHTTPS() -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        components.scheme = "https"
        guard let url = components.url else {
            return self
        }
        return url
    }
}
