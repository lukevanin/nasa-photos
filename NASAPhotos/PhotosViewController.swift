//
//  PhotosViewController.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/12.
//

import UIKit
import Combine


#warning("TODO: Show loading indicator")

final class PhotosViewController: UIViewController {
    
    typealias OnSelectItem = (PhotosItemViewModel) -> Void

    private static let photoCellIdentifier = "photo-cell"
    
    private var onSelectItem: OnSelectItem?
    
    private var cancellables = Set<AnyCancellable>()
    private var dataSource: UITableViewDiffableDataSource<Int, PhotosItemViewModel>?
    private var refreshNeeded = false
    
    private let loadingIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.autoresizingMask = [
            .flexibleTopMargin,
            .flexibleRightMargin,
            .flexibleBottomMargin,
            .flexibleLeftMargin,
        ]
        view.hidesWhenStopped = true
        return view
    }()
    private let tableView = UITableView()
    private let viewModel: PhotosViewModelProtocol
    
    init(
        viewModel: PhotosViewModelProtocol,
        onSelectItem: OnSelectItem? = nil
    ) {
        self.viewModel = viewModel
        self.onSelectItem = onSelectItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupTableView()
        setNeedsRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addViewModelObservers()
        refreshIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.flashScrollIndicators()
        tableView.indexPathsForSelectedRows?.forEach {
            tableView.deselectRow(at: $0, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeViewModelObservers()
    }
    
    private func setupNavigationItem() {
        navigationItem.title = NSLocalizedString("photos-title", comment: "Photos screen title")
    }
    
    // ViewModel
    
    private func addViewModelObservers() {
        viewModel.items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self = self else {
                    return
                }
                self.update(with: items)
                self.endRefresh()
            }
            .store(in: &cancellables)
        viewModel.errors
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self else {
                    return
                }
                self.presentError(error)
            }
            .store(in: &cancellables)
    }
    
    private func removeViewModelObservers() {
        cancellables.removeAll()
    }
    
    private func setNeedsRefresh() {
        refreshNeeded = true
    }
    
    private func refreshIfNeeded() {
        guard refreshNeeded == true else {
            return
        }
        refreshNeeded = false
        viewModel.reset()
        viewModel.fetch()
    }
     
    private func retry() {
        viewModel.fetch()
    }
    
    private func update(with items: [PhotosItemViewModel]) {
        let snapshot = makeSnapshot(for: items)
        dataSource?.apply(
            snapshot,
            animatingDifferences: true,
            completion: nil
        )
        if items.count == 0 {
            if loadingIndicatorView.isHidden == true {
                loadingIndicatorView.startAnimating()
            }
        }
        else {
            if loadingIndicatorView.isHidden == false {
                loadingIndicatorView.stopAnimating()
            }
        }
    }
    
    private func makeSnapshot(for items: [PhotosItemViewModel]) -> NSDiffableDataSourceSnapshot<Int, PhotosItemViewModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Int, PhotosItemViewModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        return snapshot
    }
    
    private func presentError(_ message: String) {
        #warning("TODO: Refactor error into coordinator, called from the view model")
        let viewController = UIAlertController(
            title: NSLocalizedString("photos-error-alert-title", comment: "Error alert title"),
            message: message,
            preferredStyle: .alert
        )
        viewController.addAction(
            UIAlertAction(
                title: NSLocalizedString("photos-error-alert-retry-button", comment: "Error alert retry button caption"),
                style: .default,
                handler: { [weak self] _ in
                    guard let self = self else {
                        return
                    }
                    self.retry()
                }
            )
        )
        present(viewController, animated: true, completion: nil)
    }
    
    // MARK: Table View
    
    private func endRefresh() {
        tableView.refreshControl?.endRefreshing()
    }

    private func setupTableView() {
        tableView.register(
            PhotoTableViewCell.self,
            forCellReuseIdentifier: Self.photoCellIdentifier
        )
        dataSource = UITableViewDiffableDataSource<Int, PhotosItemViewModel>(
            tableView: tableView,
            cellProvider: Self.makeCell
        )
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.prefetchDataSource = self
        tableView.estimatedRowHeight = PhotoTableViewCell.estimatedHeight(
            for: UIScreen.main.bounds.width
        )
        tableView.contentInset = UIEdgeInsets(
            horizontal: 0,
            vertical: 12
        )
        tableView.separatorStyle = .none
        tableView.refreshControl = UIRefreshControl(
            frame: .zero,
            primaryAction: UIAction() { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.setNeedsRefresh()
                self.refreshIfNeeded()
            }
        )
        tableView.backgroundView = {
            let frame = tableView.bounds
            loadingIndicatorView.center = CGPoint(
                x: frame.midX,
                y: frame.midY
            )
            let view = UIView(frame: frame)
            view.autoresizesSubviews = true
            view.addSubview(loadingIndicatorView)
            return view
        }()
    }
    
    private static func makeCell(
        in tableView: UITableView,
        at indexPath: IndexPath,
        with item: PhotosItemViewModel
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Self.photoCellIdentifier,
            for: indexPath
        )
        if let cell = cell as? PhotoTableViewCell {
            configureCell(cell, with: item)
        }
        return cell
    }
    
    private static func configureCell(
        _ cell: PhotoTableViewCell,
        with item: PhotosItemViewModel
    ) {
        cell.imageURL = item.thumbnailImageURL
        cell.title = item.title
        cell.subtitle = item.description
    }
}

extension PhotosViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let onSelectItem = onSelectItem else {
            return
        }
        guard let item = dataSource?.itemIdentifier(for: indexPath) else {
            return
        }
        onSelectItem(item)
    }
}

extension PhotosViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let lastIndex = tableView.numberOfRows(inSection: 0) - 1
        let lastIndexPath = IndexPath(item: lastIndex, section: 0)
        if indexPaths.contains(lastIndexPath) {
            print(lastIndexPath, indexPaths)
            viewModel.fetch()
        }
    }
}
