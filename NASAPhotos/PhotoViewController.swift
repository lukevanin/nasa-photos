//
//  PhotoViewController.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/13.
//

import UIKit
import Combine


///
/// Defines the view state for a single photo.
///
struct PhotoInfoViewModel: Identifiable {
    
    /// Unique identifier of the item.
    let id: String

    /// Text title of the photo.
    var title: String
    
    /// Short description of the photo. Includes the photographer and date that the photo was created.
    var description: String
    
    /// Detailed information about the photo.
    var details: String
    
    ///
    var previewImageURL: URL?
}



///
/// Defines an abstract interface for a view model that displays details for a photo.
///
protocol PhotoViewModelProtocol {
    
    ///
    var photo: AnyPublisher<PhotoInfoViewModel, Never> { get }
    
    ///
    /// Reloads the photo data from the resource.
    ///
    func reload()
}


///
/// Displays details about a photo. Displays a large preview image, title, description, and detailed information
/// about the photo.
///
final class PhotoViewController: UIViewController {
    
    private let photoImageView: URLImageView = {
        let view = URLImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = .systemGray5
        return view
    }()
    
    private let infoView: PhotoInfoView = {
        let view = PhotoInfoView()
        return view
    }()
    
    private let bodyLabel: UILabel = {
        let label = BodyLabel()
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.text = "Ag"
        return label
    }()

    private var refreshNeeded = false
    private var cancellables = Set<AnyCancellable>()

    private let viewModel: PhotoViewModelProtocol

    init(viewModel: PhotoViewModelProtocol) {
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
                            infoView,
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
        setNeedsRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addViewModelObservers()
        refreshIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeViewModelObservers()
    }
    
    private func setupNavigationItem() {
        navigationItem.largeTitleDisplayMode = .never
    }
    
    // MARK: View Model
     
    private func setNeedsRefresh() {
        refreshNeeded = true
    }
    
    private func refreshIfNeeded() {
        guard refreshNeeded == true else {
            return
        }
        refreshNeeded = false
        viewModel.reload()
    }

    private func addViewModelObservers() {
        viewModel.photo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photo in
                guard let self = self else {
                    return
                }
                self.updateView(with: photo)
            }
            .store(in: &cancellables)
    }
    
    private func removeViewModelObservers() {
        cancellables.removeAll()
    }
    
    // MARK: View

    private func updateView(with photo: PhotoInfoViewModel) {
        infoView.title = photo.title
        infoView.subtitle = photo.description
        bodyLabel.text = photo.details
        photoImageView.url = photo.previewImageURL
    }
}
