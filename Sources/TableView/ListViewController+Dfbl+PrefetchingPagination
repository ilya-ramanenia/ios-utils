import UIKit

struct ItemModel: Hashable {
    // Unique identifier decoupled from content properties to ensure stable identity during mutations
    let id = UUID()
    let title: String
}

final class ListViewController: UIViewController {
    
    // Encapsulated within the controller scope to restrict visibility and prevent global namespace pollution
    private enum Section { case main }
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let refreshControl = UIRefreshControl()
    
    private typealias DataSource = UITableViewDiffableDataSource<Section, ItemModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ItemModel>
    private var dataSource: DataSource?

    // Pagination lifecycle tracking variables to guarantee single-flight requests
    private var isFetchInProgress = false
    private var allItems: [ItemModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureDataSource()
        
        // Initial state ingestion triggering control-flow spin up
        refreshData()
    }

    private func setupUI() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        
        // Attach concrete pull-to-refresh execution target
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func configureDataSource() {
        // Concrete configuration closure encapsulates structural type mappings inline
        dataSource = DataSource(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = item.title
            cell.contentConfiguration = config
            return cell
        }
    }

    @objc private func handleRefresh() {
        refreshData()
    }

    private func refreshData() {
        guard !isFetchInProgress else { return }
        isFetchInProgress = true
        
        // Abstracted initial network/database boundary execution invocation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.isFetchInProgress = false
            
            self.allItems = [
                ItemModel(title: "Item 1"),
                ItemModel(title: "Item 2"),
                ItemModel(title: "Item 3")
            ]
            self.updateUI(with: self.allItems)
        }
    }

    private func loadNextPage() {
        // Enforce lock state preventing race conditions and redundant network operations
        guard !isFetchInProgress else { return }
        isFetchInProgress = true
        
        print("Initiating next page payload resolution...")
        
        // Abstracted subsequent page network fetch simulation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.isFetchInProgress = false
            
            let nextPageItems = [
                ItemModel(title: "Paged Item \(self.allItems.count + 1)"),
                ItemModel(title: "Paged Item \(self.allItems.count + 2)")
            ]
            
            self.allItems.append(contentsOf: nextPageItems)
            self.updateUI(with: self.allItems)
        }
    }

    func updateUI(with items: [ItemModel], animated: Bool = true) {
        // Construct and apply state transaction atomically to eliminate UI-to-source racing issues
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        // Finalize transaction and guarantee layout cycle termination prior to resetting control UI state
        dataSource?.apply(snapshot, animatingDifferences: animated) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
}

// MARK: - UITableViewDelegate & UIScrollViewDelegate
extension ListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Decoupled resolution: query the data source index to eliminate race conditions during asynchronous view mutability
        guard let selectedItem = dataSource?.itemIdentifier(for: indexPath) else { return }
        
        // Router / Coordinator pattern execution should occur here
        print("Dispatched action for element identity: \(selectedItem.id)")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        let totalContentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        // Prevent evaluation scenarios when content boundaries are insufficient to scroll
        guard totalContentHeight > frameHeight else { return }
        
        // Proactive pre-fetching: trigger load sequence when user scrolls past 85% of existing content bounds
        let threshold = totalContentHeight * 0.85
        if contentOffsetY + frameHeight > threshold {
            loadNextPage()
        }
    }
}
