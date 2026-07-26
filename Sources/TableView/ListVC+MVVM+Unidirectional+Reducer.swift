import UIKit
import Combine

// MARK: - Core UDF Types
// Enforces a strict, declarative schema of all possible user actions or system intents
enum ListViewModelAction {
    case viewDidLoad
    case refreshTriggered
    case itemSelected(index: Int)
}

// Single source of truth reflecting the deterministic UI layout representation
struct ListViewModelState {
    var items: [String] = []
    var isLoading: Bool = false
    var navigationTarget: NavigationTarget?
    
    enum NavigationTarget: Equatable {
        case details(title: String)
    }
}

// MARK: - ViewModel Implementation
final class ListViewModel {
    
    // Read-only state stream exposed downstream to the UI rendering layer
    @Published private(set) var state = ListViewModelState()
    
    // Abstracted data repository infrastructure mapping
    private let mockItems = ["Modern Alpha", "Modern Beta", "Modern Gamma"]

    // Input boundary acting as the single injection point for all state mutations
    func handle(_ action: ListViewModelAction) {
        switch action {
        case .viewDidLoad, .refreshTriggered:
            loadData()
            
        case .itemSelected(let index):
            guard index < state.items.count else { return }
            let selectedItem = state.items[index]
            // Mutate state downstream to signal structural routing interceptors
            state.navigationTarget = .details(title: selectedItem)
        }
    }
    
    private func loadData() {
        state.isLoading = true
        
        // Simulating data provider layer latent lifecycle
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.state.items = self.mockItems
            self.state.isLoading = false
        }
    }
    
    func resetNavigation() {
        state.navigationTarget = nil
    }
}

// MARK: - View Controller Implementation
final class ListViewController: UIViewController {
    
    private let vm: ListViewModel
    private var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    private var displayData: [String] = []
    private var cancellables = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(vm: ListViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupTableView()
        bindViewModel()
        
        // Dispatch explicit action payload signaling layout engine initialization
        vm.handle(.viewDidLoad)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        view.addSubview(tableView)
    }
    
    // MARK: - Reactive Data Binding
    private func bindViewModel() {
        // Enforce synchronization context mapping onto main scheduling queue
        vm.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }
    
    // Deterministic state-to-layout rendering routine. 0% logic, 100% data application.
    private func render(_ state: ListViewModelState) {
        // Apply loading indicator visibility state
        if state.isLoading {
            if !refreshControl.isRefreshing { refreshControl.beginRefreshing() }
        } else {
            refreshControl.endRefreshing()
        }
        
        // Diff layout data states and animate tree transformations conditionally
        if self.displayData != state.items {
            self.displayData = state.items
            self.tableView.reloadData()
        }
        
        // Evaluate state mutation mutations to intercept control-flow routing changes
        if let navigation = state.navigationTarget {
            switch navigation {
            case .details(let title):
                print("Router: Deep-linking presentation path down to details context: \(title)")
            }
            // Consume state to avoid presentation cycles on subsequent redraw cycles
            vm.resetNavigation()
        }
    }
    
    @objc private func handleRefresh() {
        vm.handle(.refreshTriggered)
    }
}

// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = displayData[indexPath.row]
        cell.contentConfiguration = config
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Encapsulate user interaction context into concrete action domain model mapping
        vm.handle(.itemSelected(index: indexPath.row))
    }
}
