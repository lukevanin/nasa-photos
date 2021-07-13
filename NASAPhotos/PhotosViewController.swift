//
//  PhotosViewController.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/12.
//

import UIKit
import Combine


final class PhotosViewController: UIViewController {
    
    typealias OnSelectItem = (UIViewController, PhotosItemViewModel) -> Void
    
    private static let photoCellIdentifier = "photo-cell"
    
    private var onSelectItem: OnSelectItem?
    
    private var cancellables = Set<AnyCancellable>()
    private var dataSource: UITableViewDiffableDataSource<Int, PhotosItemViewModel>?
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addViewModelObservers()
        reload()
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
    
    private func reload() {
        viewModel.reset()
        viewModel.fetch()
    }
    
    private func update(with items: [PhotosItemViewModel]) {
        let snapshot = makeSnapshot(for: items)
        dataSource?.apply(
            snapshot,
            animatingDifferences: true,
            completion: nil
        )
    }
    
    private func makeSnapshot(for items: [PhotosItemViewModel]) -> NSDiffableDataSourceSnapshot<Int, PhotosItemViewModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Int, PhotosItemViewModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        return snapshot
    }
    
    private func presentError(_ message: String) {
        #warning("TODO: Delegate presenting the error alert")
        let viewController = UIAlertController(
            title: NSLocalizedString("error-alert-title", comment: "Error alert title"),
            message: message,
            preferredStyle: .alert
        )
        viewController.addAction(
            UIAlertAction(
                title: NSLocalizedString("error-alert-retry-button", comment: "Error alert retry button caption"),
                style: .default,
                handler: { [weak self] _ in
                    guard let self = self else {
                        return
                    }
                    #warning("TODO: Call fetch on the view model again")
                }
            )
        )
        present(viewController, animated: true, completion: nil)
    }
    
    // Table View
    
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
        tableView.estimatedRowHeight = PhotoTableViewCell.estimatedHeight(
            for: UIScreen.main.bounds.width
        )
        tableView.contentInset = UIEdgeInsets(
            horizontal: 0,
            vertical: 12
        )
        tableView.separatorStyle = .none
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
        cell.thumbnailImageView.url = item.thumbnailImageURL
        cell.titleLabel.text = item.title
        cell.subtitleLabel.text = item.description
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
        onSelectItem(self, item)
    }
}
