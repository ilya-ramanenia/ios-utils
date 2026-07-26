//
//  ListViewController.swift
//  tasklist
//
//  Created by ilya Ramanenia on 03/03/2026.
//

import UIKit
import UIKit

struct ItemModel {
    // Value type structure with unique identity to prevent mismatched row reference states
    let id = UUID()
    let title: String
}

final class ListViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let refreshControl = UIRefreshControl()
    
    // Core synchronous backing store replacing implicit state tracking of DiffableDataSource
    private var items: [ItemModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        refreshData()
    }

    private func setupUI() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Enforce synchronous delegation routing for data representation and interaction
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    @objc private func handleRefresh() {
        refreshData()
    }

    private func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.items = [
                ItemModel(title: "Item 1"),
                ItemModel(title: "Item 2"),
                ItemModel(title: "Item 3")
            ]
            
            // Full UI reset required on layout/batch updates boundary initiation
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
}

// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = items[indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        config.text = item.title
        cell.contentConfiguration = config
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Safe linear bounds verification to eliminate out-of-range lookup runtime execution panic
        guard indexPath.row  UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else {
                completionHandler(false)
                return
            }
            
            // Enforce serialization sequence: backing store updates must occur atomically before triggering view manipulation
            tableView.performBatchUpdates({
                self.items.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }, completion: { isFinished in
                // Callback notifying structural hierarchy interface tree manipulation closure block has finished execution
                completionHandler(isFinished)
            })
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        // Full swipe gesture executes the contextual action automatically
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}
