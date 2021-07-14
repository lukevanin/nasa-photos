//
//  Theme.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/14.
//

import UIKit


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
        let baseFont = UIFont(name: "HelveticaNeue-Bold", size: 16)!
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)
        adjustsFontForContentSizeCategory = true
        textColor = .label
    }
}
