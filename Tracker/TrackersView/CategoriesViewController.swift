//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 21.03.2024.
//

import UIKit

final class CategoriesViewController: UIViewController {
    
    // MARK: - Private Properties
    private var trackerCategoriesNames: [String]? = [] {
        didSet {
            tableView.reloadData()
            emptyCheck()
        }
    }
    
    private var viewModel: CategoriesViewModel?
    
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
        table.backgroundColor = .ypWhite
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
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
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
    
    private lazy var cellContextMenu = UIMenu()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        view.backgroundColor = .ypWhite
        tableView.dataSource = self
        tableView.delegate = self
        configureUI()
        emptyCheck()
        tableView.dataSource = self
        tableView.delegate = self
        
        trackerCategoriesNames = viewModel?.trackerCategoriesNames
    }
    
    // MARK: - Initializers
    convenience init(viewModel: CategoriesViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        bind()
    }
    
    // MARK: - Private Methods
    private func bind() {
        viewModel?.trackerCategoriesNamesBinding = { [weak self] names in
            self?.trackerCategoriesNames = names
        }
    }
    
    private func emptyCheck() {
        let isHidden: Bool = !(trackerCategoriesNames?.count == 0)
        noCategoriesYetImageView.isHidden = isHidden
        noCategoriesYetLabel.isHidden = isHidden
    }
    
    private func configureUI() {
        view.addSubview(mainTitle)
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)
        view.addSubview(noCategoriesYetImageView)
        view.addSubview(noCategoriesYetLabel)
        
        noCategoriesYetImageView.layer.zPosition = 10
        noCategoriesYetLabel.layer.zPosition = 10
        
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
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            noCategoriesYetImageView.widthAnchor.constraint(equalToConstant: 80),
            noCategoriesYetImageView.heightAnchor.constraint(equalToConstant: 80),
            noCategoriesYetImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            noCategoriesYetImageView.topAnchor.constraint(equalTo: mainTitle.bottomAnchor, constant: 246),
            
            noCategoriesYetLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            noCategoriesYetLabel.topAnchor.constraint(equalTo: noCategoriesYetImageView.bottomAnchor, constant: 8)
        ])
    }
    
    @objc private func didTapAddCategoryButton() {
        let view = NewCategoryViewController(trackerCategoriesNames: trackerCategoriesNames)
        
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
            title: trackerCategoriesNames?[indexPath.row] ?? "",
            backgroundColor: .ypGrayAlpha
        )
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerCategoriesNames?.count ?? 0
    }
}

extension CategoriesViewController: UITableViewDelegate {
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
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoriesTableViewCell else { return }
        cell.showImageForSelected(true)
        let categoryTitle = trackerCategoriesNames?[indexPath.row] ?? ""
        
        viewModel?.didSelectCategory(with: categoryTitle)
        
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoriesTableViewCell else { return }
        cell.showImageForSelected(false)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        let categoryTitle = trackerCategoriesNames?[indexPath.row] ?? ""
        
        return UIContextMenuConfiguration(actionProvider:  { suggestedActions in
            
            let editAction = UIAction(title: "Редактировать") { action in
                let view = EditCategoryViewController(name: categoryTitle)
                view.delegate = self
                
                self.present(view, animated: true)
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { action in
                self.viewModel?.deleteCategory(name: categoryTitle)
            }
            
            return UIMenu(children: [editAction, deleteAction])
        })
    }
    
}

// MARK: - NewCategoryViewControllerDelegate
extension CategoriesViewController: NewCategoryViewControllerDelegate{
    func addNewCategory(name: String) {
        viewModel?.addNewCategory(name: name)
    }
}

// MARK: - EditCategoryViewControllerDelegate
extension CategoriesViewController: EditCategoryViewControllerDelegate{
    func editCategory(newName: String, existingCategory: String) {
        viewModel?.editCategory(title: newName, for: existingCategory)
    }
}
