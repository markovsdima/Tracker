//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 21.03.2024.
//

import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func selectCategory(title: String?)
}

final class CategoriesViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var delegate: CategoriesViewControllerDelegate?
    
    // MARK: - Private Properties
    private var trackerCategoryStore = TrackerCategoryStore.shared
    private var trackerCategories: [TrackerCategory]?
    
    // MARK: - UI Properties
    private lazy var mainTitle: UILabel = {
        let label = UILabel()
        label.text = "Категории"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(CategoriesTableViewCell.self, forCellReuseIdentifier: "CategoriesTableViewCell")
        table.layer.cornerRadius = 16
        table.allowsMultipleSelection = false
        table.isScrollEnabled = true
        table.translatesAutoresizingMaskIntoConstraints = false
        
        return table
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.backgroundColor = .ypBlack
        button.tintColor = .ypWhite
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapAddCategoryButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var noCategoriesYetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.noTrackersYet
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var noCategoriesYetLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно \n объединить по смыслу"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        view.backgroundColor = .ypWhite
        tableView.dataSource = self
        tableView.delegate = self
        configureUI()
        emptyCheck()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Private Methods
    private func loadCategories() {
        do {
            trackerCategories = try trackerCategoryStore.fetchCategories()
        } catch {
            print("Error: \(error) while loading categories")
        }
    }
    
    private func emptyCheck() {
        if MockData.shared.mockCategories.count == 0 {
            
            view.addSubview(noCategoriesYetImageView)
            view.addSubview(noCategoriesYetLabel)
            
            noCategoriesYetImageView.layer.zPosition = 10
            noCategoriesYetLabel.layer.zPosition = 10
            
            NSLayoutConstraint.activate([
                noCategoriesYetImageView.widthAnchor.constraint(equalToConstant: 80),
                noCategoriesYetImageView.heightAnchor.constraint(equalToConstant: 80),
                noCategoriesYetImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                noCategoriesYetImageView.topAnchor.constraint(equalTo: mainTitle.bottomAnchor, constant: 246),
                
                noCategoriesYetLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                noCategoriesYetLabel.topAnchor.constraint(equalTo: noCategoriesYetImageView.bottomAnchor, constant: 8)
            ])
        }
    }
    
    private func configureUI() {
        view.addSubview(mainTitle)
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            mainTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            mainTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: mainTitle.bottomAnchor, constant: 38),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -39),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func didTapAddCategoryButton() {
        let view = NewCategoryViewController()
        view.delegate = self
        
        present(view, animated: true)
    }
}

// MARK: - Table View Methods
extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesTableViewCell.reuseIdentifier, for: indexPath)
        guard let cell = cell as? CategoriesTableViewCell else { return UITableViewCell() }
        
        cell.configure(
            title: trackerCategories?[indexPath.row].title ?? "",
            backgroundColor: .ypGrayAlpha
        )
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerCategories?.count ?? 0
    }
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoriesTableViewCell else { return }
        cell.showImageForSelected(true)
        let categoryTitle = trackerCategories?[indexPath.row].title
        delegate?.selectCategory(title: categoryTitle)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoriesTableViewCell else { return }
        cell.showImageForSelected(false)
    }
}

// MARK: - NewCategoryViewControllerDelegate
extension CategoriesViewController: NewCategoryViewControllerDelegate{
    func addNewCategory(name: String) {
        do {
            try trackerCategoryStore.addCategory(title: name)
            loadCategories()
            tableView.reloadData()
            
        } catch TrackerCategoryStoreError.categoryExist {
            print("Такая категория уже есть")
            // TODO: notificate in ui
        } catch {
            print("Неизвестная ошибка: \(error)")
        }
        
    }
}
