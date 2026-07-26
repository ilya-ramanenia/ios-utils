import UIKit

class ListViewModel {
    var items: [String] = ["Item A", "Item B", "Item C"]
    
    // Abstracted interaction interface to decouple UI layer execution from business logic processing
    var didSelectItem: ((String) -> Void)?
    
    func selectItem(at index: Int) {
        guard index < items.count else { return }
        didSelectItem?(items[index])
    }
}

class ListViewController: UIViewController {
    
    private let vm: ListViewModel
    private var tableView: UITableView!
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(vm: ListViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        setupTableView()
    }
    
    private func setupTableView() {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = vm.items[indexPath.row]
        cell.contentConfiguration = config
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Delegation step passing structural index mutation to the domain layer context
        vm.selectItem(at: indexPath.row)
    }
}
