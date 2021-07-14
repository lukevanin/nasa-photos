//
//  PhotoInfoView.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/14.
//

import UIKit


final class PhotoInfoView: UIView {
    
    var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    var subtitle: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    private let titleLabel: UILabel = {
        let label = TitleLabel()
        label.numberOfLines = 2
        label.text = "Ag"
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = SubtitleLabel()
        label.numberOfLines = 1
        label.text = "Ag"
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        UIStackView(
            axis: .vertical,
            arrangedSubviews: [
                titleLabel,
                subtitleLabel
                    .padding(UIEdgeInsets(vertical: 4))
            ])
            .added(to: self)
    }
}
