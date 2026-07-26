import UIKit

/// Simple template for VC with UITableViewDiffableDataSource
/// Features: Pull to refresh

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureDataSource()
        
        // Initial data ingestion triggering control-flow spin up
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
        // Abstracted data fetch routine mimicking an external network/database boundary invocation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            let updatedItems = [
                ItemModel(title: "Fetched Item 1"),
                ItemModel(title: "Fetched Item 2"),
                ItemModel(title: "Fetched Item 3")
            ]
            self?.updateUI(with: updatedItems)
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

// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Decoupled resolution: query the data source index to eliminate race conditions during asynchronous view mutability
        guard let selectedItem = dataSource?.itemIdentifier(for: indexPath) else { return }
        
        // Router / Coordinator pattern execution should occur here
        print("Dispatched action for element identity: \(selectedItem.id)")
    }
}
