import UIKit

// MARK: - ViewModel
final class ListViewModel {
    // Structural backing store tracking local domain models state
    private(set) var items: [String] = []
    
    func viewDidLoad() {
        // Enforce synchronous initialization of layout primitives on target tracking lifecycle activation
        items = ["Item A", "Item B", "Item C"]
    }
    
    func selectItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        // Root business processing logic execution block should be handled downstream from here
        print("ViewModel received element processing target: \(items[index])")
    }
}

// MARK: - ViewController
final class ListViewController: UIViewController {
    
    private let vm: ListViewModel
    private var tableView: UITableView!
    
    init(vm: ListViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("Storyboard not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupTableView()
        
        // Lifecycle propagation: delegate initialization signal upstream to allow initial state composition
        vm.viewDidLoad()
    }
    
    private func setupTableView() {
        // Enforce frame-based initialization covering full view bounds for optimal layout pass rendering performance
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
}

// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = vm.items[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Forward raw user action tracking parameters directly to the domain layer context
        vm.selectItem(at: indexPath.row)
    }
}
