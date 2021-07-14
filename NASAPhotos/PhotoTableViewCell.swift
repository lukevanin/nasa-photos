//
//  PhotoTableViewCell.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/13.
//

import UIKit


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
            infoView.title
        }
        set {
            infoView.title = newValue
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
    }
    
    private func setupLayout() {
        #warning("TODO: Insert spacing between title and subtitle")
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
