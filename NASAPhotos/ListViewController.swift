//
//  PhotosViewController.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/12.
//

import UIKit
import Combine


///
///
///
protocol ListViewModelProtocol {
    
    associatedtype Item: Hashable
    
    ///
    /// Publishes available items.
    ///
    var items: AnyPublisher<[Item], Never> { get }

    ///
    /// Fetches the next page of items. If no more items are available then this does nothing.
    ///
    func reset()
    
    ///
    /// Resets the internal state of the view model so that the next fetch will retrieve the first page of items.
    ///
    func fetch()
    
    ///
    /// Selects the item in the liast at the given index.
    ///
    func selectItem(at index: Int)
}


///
///
///
protocol CellBuilder {
    associatedtype Cell: UITableViewCell
    associatedtype Item

    var reuseIdentifier: String { get }
    func register(in tableView: UITableView)
    func cell(in tableView: UITableView, at indexPath: IndexPath, with item: Item) -> UITableViewCell?
}

extension CellBuilder {
    var reuseIdentifier: String {
        String(describing: Cell.self)
    }
    
    func register(in tableView: UITableView) {
        tableView.register(Cell.self, forCellReuseIdentifier: reuseIdentifier)
    }
}


///
///
///
final class ListViewController<ViewModel, CellProvider>: UIViewController, UITableViewDelegate, UITableViewDataSourcePrefetching where ViewModel: ListViewModelProtocol, CellProvider: CellBuilder, ViewModel.Item == CellProvider.Item {
    
    private var cancellables = Set<AnyCancellable>()
    private var dataSource: UITableViewDiffableDataSource<Int, ViewModel.Item>?
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
    
    private let viewModel: ViewModel
    private let cellProvider: CellProvider
    
    init(viewModel: ViewModel, cellProvider: CellProvider) {
        self.viewModel = viewModel
        self.cellProvider = cellProvider
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
    
    private func update(with items: [ViewModel.Item]) {
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
    
    private func makeSnapshot(for items: [ViewModel.Item]) -> NSDiffableDataSourceSnapshot<Int, ViewModel.Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ViewModel.Item>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        return snapshot
    }
    
    // MARK: Table View
    
    private func endRefresh() {
        tableView.refreshControl?.endRefreshing()
    }

    private func setupTableView() {
        cellProvider.register(in: tableView)
        dataSource = UITableViewDiffableDataSource<Int, ViewModel.Item>(
            tableView: tableView,
            cellProvider: cellProvider.cell
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
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectItem(at: indexPath.item)
    }

    // MARK: UITableViewDataSourcePrefetching
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let lastIndex = tableView.numberOfRows(inSection: 0) - 1
        let lastIndexPath = IndexPath(item: lastIndex, section: 0)
        if indexPaths.contains(lastIndexPath) {
            viewModel.fetch()
        }
    }
}
