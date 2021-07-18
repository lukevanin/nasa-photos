//
//  PhotosViewController.swift
//  NASAPhotos
//
//  Created by Luke Van In on 2021/07/12.
//

import UIKit
import Combine


///
/// A view model that provides a collection of items that can be displayed in a list. Used by
/// `ListViewController` to display a list of items. Concrete implementations should publish a collection
/// of view models that can be used to configure rows in a table view.
///
/// The view model `reset()` and `fetch()` methods are used to control fetching content in batches.
///
/// See `ListViewModel` for an example.
///
protocol ListViewModelProtocol {
    
    associatedtype Item: Hashable
    
    ///
    /// Publishes available items.
    ///
    var items: AnyPublisher<[Item], Never> { get }
    
    ///
    /// Resets the internal state of the view model so that the next fetch will retrieve the first page of items.
    /// Items currently in the list are removed.
    ///
    func reset()

    ///
    /// Fetches the next page of items and appends the items to the published list of items. Has no
    /// side-effects if no more items are available.
    ///
    func fetch()

    ///
    /// Selects the item in the liast at the given index.
    ///
    func selectItem(at index: Int)
}


///
/// Dequeues and configures reusable cells for a table view. Used by the `ListViewController` to
/// create table view cells for view models. Concrete implementations should register a specific
/// `UITableViewCell` instance, then dequeue and configure the instance when the cell is requested.
///
protocol CellBuilderProtocol {
    associatedtype Item
    func register(in tableView: UITableView)
    func cell(in tableView: UITableView, at indexPath: IndexPath, with item: Item) -> UITableViewCell?
}


///
/// Displays a vertically scrolling list of items provided by a view model conforming to
/// `ListViewModelProtocol`, and configured by a cell provider conforming to
/// `CellBuilderProtocol`. Loads the list from the view model when the view controller appears. Loads
/// additional batches when the list is scrolled so that the last element is displayed. Displays an activity
/// indicator while the data is loading. Provides pull-down-to-refresh functionality.
///
final class ListViewController<ViewModel, CellProvider>:
    UIViewController,
    UITableViewDelegate,
    UITableViewDataSourcePrefetching
where
    ViewModel: ListViewModelProtocol,
    CellProvider: CellBuilderProtocol,
    ViewModel.Item == CellProvider.Item
{
    
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
        // Create a diffable snapshot from the latest items, and apply the
        // shanges to the view.
        let snapshot = makeSnapshot(for: items)
        dataSource?.apply(
            snapshot,
            animatingDifferences: true,
            completion: nil
        )
        // Show the loading indicator while the list is empty. This is not
        // correct behaviour under all circumstances as an empty result set may
        // be a valid state. It would be more useful to show a placeholder
        // message state when an empty result set is loaded. This serves current
        // requirements so it is left as-is.
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
        // Convert the array of view model items to a diffable snapshot that
        // is used to compute differences between successive batches of items.
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
        // Register the cell on the table view, and set up a diffable data
        // source to provide cells to the table, using the cell provider.
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
        #warning("TODO: Use theme for standard margisn")
        tableView.contentInset = UIEdgeInsets(
            horizontal: 0,
            vertical: 12
        )
        tableView.separatorStyle = .none
        // Install a refresh control to support pull-down to refresh.
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
        // Install the activity indicator on the background of the table view,
        // so that it can be shown while the list is being loaded.
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
        // Request the next batch of data when the last row of the table is
        // about to be displayed. UITableViewDataSourcePrefetching is used so
        // that the view model can start loading before the data is displayed,
        // which reduces the chances that the user will hit the bottom of the
        // list before the data is loaded.
        let lastIndex = tableView.numberOfRows(inSection: 0) - 1
        let lastIndexPath = IndexPath(item: lastIndex, section: 0)
        if indexPaths.contains(lastIndexPath) {
            viewModel.fetch()
        }
    }
}
