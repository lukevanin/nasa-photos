//
//  PhotoCellBuilder.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/18.
//

import UIKit


///
/// Defines the view state for a single photo.
///
struct PhotosListItemViewModel: Identifiable {
    
    /// Unique identifier of the item
    let id: String
    
    /// Url of the thumbnail image to display
    var thumbnailImageURL: URL?
    
    /// Text title of the photo
    var title: String
    
    /// Short description of the photo. Includes the photographer and date that the photo was created.
    var description: String
}

extension PhotosListItemViewModel: Hashable {
    
}



///
///
///
final class PhotoCellBuilder: CellBuilder {
    
    typealias Cell = PhotoTableViewCell
    
    func cell(
        in tableView: UITableView,
        at indexPath: IndexPath,
        with item: PhotosListItemViewModel
    ) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: reuseIdentifier,
            for: indexPath
        )
        if let cell = cell as? PhotoTableViewCell {
            cell.imageURL = item.thumbnailImageURL
            cell.title = item.title
            cell.subtitle = item.description
        }
        return cell
    }
}
