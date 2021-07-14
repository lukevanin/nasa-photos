//
//  UIKitExtensions.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/13.
//

import UIKit

extension UIEdgeInsets {
    init(horizontal: CGFloat = 0, vertical: CGFloat = 0) {
        self.init(
            top: vertical,
            left: horizontal,
            bottom: vertical,
            right: horizontal
        )
    }
}


extension UIScrollView {
    
    convenience init(
        frame: CGRect = .zero,
        axis: NSLayoutConstraint.Axis = .vertical,
        contentView: UIView
    ) {
        self.init(frame: frame)
        addContent(axis: axis, contentView: contentView)
    }

    func addContent(
        axis: NSLayoutConstraint.Axis? = .vertical,
        contentView: UIView
    ) {
        subviews.forEach { $0.removeFromSuperview() }
        contentView.added(to: self, relativeTo: .edges)
        if let axis = axis {
            switch axis {
            case .vertical:
                contentView.with(widthEqualTo: widthAnchor)
                alwaysBounceVertical = true
                alwaysBounceHorizontal = false
            case .horizontal:
                contentView.with(heightEqualTo: heightAnchor)
                alwaysBounceVertical = false
                alwaysBounceHorizontal = true
            @unknown default:
                fatalError("Unsupported axis \(axis)")
            }
        }
        else {
            contentView.with(widthEqualTo: widthAnchor)
            contentView.with(heightEqualTo: heightAnchor)
            alwaysBounceVertical = true
            alwaysBounceHorizontal = true
        }
    }
}


extension UIView {

    func padding(_ padding: UIEdgeInsets) -> UIView {
        let view = UIView()
        view.addSubview(self)
        added(to: view.with(layoutMargins: padding))
        return view
    }
    
    enum Guide {
        case safeArea
        case margins
        case edges
    }
    
    @discardableResult func added(
        to superview: UIView,
        relativeTo guide: Guide = .margins
    ) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(self)
        switch guide {
        case .margins:
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
            
        case .safeArea:
            NSLayoutConstraint.activate([
                leftAnchor.constraint(
                    equalTo: superview.safeAreaLayoutGuide.leftAnchor
                ),
                rightAnchor.constraint(
                    equalTo: superview.safeAreaLayoutGuide.rightAnchor
                ),
                topAnchor.constraint(
                    equalTo: superview.safeAreaLayoutGuide.topAnchor
                ),
                bottomAnchor.constraint(
                    equalTo: superview.safeAreaLayoutGuide.bottomAnchor
                ),
            ])
            
        case .edges:
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
        return self
    }
    
    @discardableResult func with(backgroundColor: UIColor) -> Self {
        self.backgroundColor = backgroundColor
        return self
    }
    
    @discardableResult func with(layoutMargins: UIEdgeInsets) -> Self {
        self.layoutMargins = layoutMargins
        return self
    }

    @discardableResult func with(
        widthEqualTo constant: CGFloat,
        priority: UILayoutPriority = .required
    ) -> Self {
        let constraint = widthAnchor.constraint(equalToConstant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return self
    }

    @discardableResult func with(
        heightEqualTo constant: CGFloat,
        priority: UILayoutPriority = .required
    ) -> Self {
        let constraint = heightAnchor.constraint(equalToConstant: constant)
        constraint.priority = priority
        constraint.isActive = true
        return self
    }

    @discardableResult func with(
        widthEqualTo dimension: NSLayoutDimension,
        multiplier: CGFloat = 1,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) -> Self {
        let constraint = widthAnchor.constraint(
            equalTo: dimension,
            multiplier: multiplier,
            constant: constant
        )
        constraint.priority = priority
        constraint.isActive = true
        return self
    }

    @discardableResult func with(
        heightEqualTo dimension: NSLayoutDimension,
        multiplier: CGFloat = 1,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required
    ) -> Self {
        let constraint = heightAnchor.constraint(
            equalTo: dimension,
            multiplier: multiplier,
            constant: constant
        )
        constraint.priority = priority
        constraint.isActive = true
        return self
    }

    @discardableResult func with(
        aspectRatioEqualTo constant: CGFloat,
        priority: UILayoutPriority = .required
    ) -> Self {
        let constraint = widthAnchor.constraint(
            equalTo: heightAnchor,
            multiplier: constant
        )
        constraint.priority = priority
        constraint.isActive = true
        return self
    }
}


extension UIStackView {
    
    convenience init(
        frame: CGRect = .zero,
        axis: NSLayoutConstraint.Axis,
        spacing: CGFloat? = nil,
        distribution: Distribution? = nil,
        alignment: Alignment? = nil,
        arrangedSubviews: [UIView]
    ) {
        self.init(frame: frame)
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
