//
//  Theme.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/14.
//

import UIKit


///
/// Displays static text using the Title style.
///
final class TitleLabel: UILabel {
    
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
        font = Theme.current.titleFont()
        adjustsFontForContentSizeCategory = true
        textColor = .label
    }
}
