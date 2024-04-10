//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 10.04.2024.
//

import UIKit

enum FilterType: String {
    case allTrackers = "Все трекеры"
    case todayTrackers = "Трекеры на сегодня"
    case completed = "Завершенные"
    case uncompleted = "Не завершенные"
}

protocol FiltersViewControllerDelegate {
    func changeFiltrationType(to: FilterType)
}

final class FiltersViewController: UIViewController {
    
    var delegate: FiltersViewControllerDelegate?
    
    private let filterTypes: [FilterType] = [.allTrackers, .todayTrackers, .completed, .uncompleted]
    
    private var currentFilter: FilterType = .allTrackers
    
    // MARK: - UI Properties
    private lazy var mainTitle: UILabel = {
        let label = UILabel()
        label.text = "Фильтры"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .ypWhite
        table.register(FiltersTableViewCell.self, forCellReuseIdentifier: FiltersTableViewCell.reuseIdentifier)
        table.layer.cornerRadius = 16
        table.allowsMultipleSelection = false
        table.isScrollEnabled = true
        table.translatesAutoresizingMaskIntoConstraints = false
        
        return table
    }()
    
    // MARK: - Initializers
    convenience init(currentFilter: FilterType) {
        self.init()
        
        self.currentFilter = currentFilter
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        configureUI()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Private Methods
    private func configureUI() {
        view.addSubview(mainTitle)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            mainTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            mainTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: mainTitle.bottomAnchor, constant: 38),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -39),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
}

// MARK: - Table View Methods
extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FiltersTableViewCell.reuseIdentifier, for: indexPath)
        guard let cell = cell as? FiltersTableViewCell else { return UITableViewCell() }
        
        if currentFilter == filterTypes[indexPath.row] {
            cell.showImageForSelected(true)
        }
        
        cell.configure(
            title: filterTypes[indexPath.row].rawValue,
            backgroundColor: .ypGrayAlpha
        )
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.cornerRadius = 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FiltersTableViewCell else { return }
        cell.showImageForSelected(true)

        delegate?.changeFiltrationType(to: filterTypes[indexPath.row])
        //let cellTitle = filterTypes[indexPath.row].rawValue
        
        //viewModel?.didSelectCategory(with: categoryTitle)
        
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FiltersTableViewCell else { return }
        cell.showImageForSelected(false)
    }
    
}
