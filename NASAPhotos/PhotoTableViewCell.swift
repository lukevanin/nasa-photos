//
//  PhotoTableViewCell.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/13.
//

import UIKit


final class PhotoTableViewCell: UITableViewCell {
    
    let thumbnailImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 3
        view.backgroundColor = .systemGray5
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
//        let font = UIFont.systemFont(ofSize: 17, weight: .bold)
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
        let weight = UIFont.Weight(0.4)
        let font = UIFont(name: "HelveticaNeue", size: 14)!
//        let font = UIFont.systemFont(ofSize: 14, weight: .thin)
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
        #warning("TODO: Insert spacing above subtitle")
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
        .add(to: contentView, margins: UIEdgeInsets(horizontal: 0, vertical: 12))
    }
}
