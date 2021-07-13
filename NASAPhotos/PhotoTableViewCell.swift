//
//  PhotoTableViewCell.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/13.
//

import UIKit


final class PhotoTableViewCell: UITableViewCell {
    
    let thumbnailImageView: URLImageView = {
        let view = URLImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 3
        view.backgroundColor = .systemGray5
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        #warning("TODO: Refactor fonts to use a shared repository")
        let font = UIFont(name: "HelveticaNeue-Bold", size: 17)!
        label.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.numberOfLines = 2
        label.text = "Ag"
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        #warning("TODO: Refactor fonts to use a shared repository")
        let font = UIFont(name: "HelveticaNeue", size: 14)!
        label.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.text = "Ag"
        return label
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
                    .with(widthEqualToConstant: 64)
                    .with(aspectRatio: 1),
                UIStackView(
                    axis: .vertical,
                    arrangedSubviews: [
                        titleLabel,
                        subtitleLabel,
                    ]
                ),
            ]
        )
        .add(
            to: contentView,
            margins: UIEdgeInsets(horizontal: 0, vertical: 12)
        )
    }
}
