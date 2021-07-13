//
//  UIKitExtensions.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/13.
//

import UIKit

extension UIEdgeInsets {
    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(
            top: vertical,
            left: horizontal,
            bottom: vertical,
            right: horizontal
        )
    }
}


extension UIView {
    
    func add(to superview: UIView, margins: UIEdgeInsets? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(self)
        if let margins = margins {
            superview.layoutMargins = margins
            NSLayoutConstraint.activate([
                leftAnchor.constraint(
                    equalTo: superview.layoutMarginsGuide.leftAnchor
                ),
                rightAnchor.constraint(
                    equalTo: superview.layoutMarginsGuide.rightAnchor
                ),
                topAnchor.constraint(
                    equalTo: superview.layoutMarginsGuide.topAnchor
                ),
                bottomAnchor.constraint(
                    equalTo: superview.layoutMarginsGuide.bottomAnchor
                ),
            ])
        }
        else {
            NSLayoutConstraint.activate([
                leftAnchor.constraint(
                    equalTo: superview.leftAnchor
                ),
                rightAnchor.constraint(
                    equalTo: superview.rightAnchor
                ),
                topAnchor.constraint(
                    equalTo: superview.topAnchor
                ),
                bottomAnchor.constraint(
                    equalTo: superview.bottomAnchor
                ),
            ])
        }
    }
    
    func with(widthEqualToConstant constant: CGFloat) -> Self {
        let constraint = widthAnchor.constraint(equalToConstant: constant)
        constraint.isActive = true
        return self
    }
    
    func with(heightEqualToConstant constant: CGFloat) -> Self {
        let constraint = heightAnchor.constraint(equalToConstant: constant)
        constraint.isActive = true
        return self
    }

    func with(aspectRatio: CGFloat) -> Self {
        let constraint = widthAnchor.constraint(
            equalTo: heightAnchor,
            multiplier: aspectRatio
        )
        constraint.isActive = true
        return self
    }
}


extension UIStackView {
    
    convenience init(
        axis: NSLayoutConstraint.Axis,
        spacing: CGFloat? = nil,
        distribution: Distribution? = nil,
        alignment: Alignment? = nil,
        arrangedSubviews: [UIView]
    ) {
        self.init()
        self.axis = axis
        if let spacing = spacing {
            self.spacing = spacing
        }
        if let distribution = distribution {
            self.distribution = distribution
        }
        if let alignment = alignment {
            self.alignment = alignment
        }
        arrangedSubviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        arrangedSubviews.forEach(addArrangedSubview)
    }
}


extension UITableViewCell {
    
    static func estimatedHeight(for width: CGFloat) -> CGFloat {
        let constraint = CGSize(width: width, height: .greatestFiniteMagnitude)
        let cell = Self.init(style: .default, reuseIdentifier: nil)
        let size = cell.contentView.systemLayoutSizeFitting(
            constraint,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return size.height
    }
}
