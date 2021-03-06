//
//  PhotoTableViewCell.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/13.
//

import UIKit


///
/// Displays a photo in a list. Displays a title, subtitle, and an image loaded from the web.
///
final class PhotoTableViewCell: UITableViewCell {
    
    var title: String? {
        get {
            infoView.title
        }
        set {
            infoView.title = newValue
        }
    }
    
    var subtitle: String? {
        get {
            infoView.subtitle
        }
        set {
            infoView.subtitle = newValue
        }
    }
    
    var imageURL: URL? {
        get {
            thumbnailImageView.url
        }
        set {
            thumbnailImageView.url = newValue
        }
    }

    private let thumbnailImageView: URLImageView = {
        let view = URLImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 3
        return view
    }()
    
    private let infoView: PhotoInfoView = {
        let view = PhotoInfoView()
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.url = nil
    }
    
    private func setupLayout() {
        UIStackView(
            axis: .horizontal,
            spacing: 16,
            alignment: .top,
            arrangedSubviews: [
                thumbnailImageView
                    .with(widthEqualTo: 64)
                    .with(aspectRatioEqualTo: 1.0),
                infoView,
            ]
        )
        .added(
            to: contentView.with(layoutMargins: UIEdgeInsets(vertical: 12))
        )
    }
}
