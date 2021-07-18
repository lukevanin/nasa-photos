//
//  BodyLabel.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/18.
//

import UIKit


///
/// Displays static text in the Body text style.
///
final class BodyLabel: UILabel {
    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        font = Theme.current.bodyFont()
        adjustsFontForContentSizeCategory = true
        textColor = .label
    }
}
