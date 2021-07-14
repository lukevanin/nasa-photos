//
//  PhotoViewController.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/13.
//

import UIKit
import Combine


final class PhotoViewController: UIViewController {
    
    private let photoImageView: URLImageView = {
        let view = URLImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = .systemGray5
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = TitleLabel()
        label.numberOfLines = 0
        label.text = "Ag"
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = SubtitleLabel()
        label.numberOfLines = 1
        label.text = "Ag"
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        let font = UIFont(name: "HelveticaNeue", size: 16)!
        label.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.numberOfLines = 0
        label.text = "Ag"
        return label
    }()

    private let viewModel: PhotoInfoViewModel?
    
    init(viewModel: PhotoInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIScrollView(
            axis: .vertical,
            contentView: UIStackView(
                axis: .vertical,
                arrangedSubviews: [
                    photoImageView
                        .with(aspectRatioEqualTo: 375.0 / 230),
                    UIStackView(
                        axis: .vertical,
                        spacing: 24,
                        arrangedSubviews: [
                            UIStackView(
                                axis: .vertical,
                                arrangedSubviews: [
                                    titleLabel,
                                    subtitleLabel,
                                ]
                            ),
                            bodyLabel,
                        ]
                    )
                    .padding(UIEdgeInsets(horizontal: 16, vertical: 24))
                ]
            )
        )
        .with(backgroundColor: .systemBackground)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    private func setupNavigationItem() {
        navigationItem.title = NSLocalizedString("photo-title", comment: "Photo screen title")
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupView() {
        photoImageView.url = viewModel?.previewImageURL
        titleLabel.text = viewModel?.title
        subtitleLabel.text = viewModel?.description
        bodyLabel.text = viewModel?.details
    }
}
