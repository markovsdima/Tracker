//
//  EditCategoryViewController.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 09.04.2024.
//

import UIKit

protocol EditCategoryViewControllerDelegate: AnyObject {
    func editCategory(newName: String, existingCategory: String)
}

final class EditCategoryViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var delegate: EditCategoryViewControllerDelegate?
    //private var trackerCategorieName: String?
    
    // MARK: - Private Properties
    private var categoryName: String?
    private var newName: String?
    
    // MARK: - UI Properties
    private lazy var mainTitle: UILabel = {
        let label = UILabel()
        label.text = "Редактирование категории"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var categoryNameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = ""
        field.backgroundColor = .ypGrayAlpha
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: field.frame.height))
        field.leftViewMode = .always
        field.layer.cornerRadius = 16
        field.addTarget(self, action: #selector(didChangedNameField), for: .editingChanged)
        field.translatesAutoresizingMaskIntoConstraints = false
        
        return field
    }()
    
    private lazy var finishButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.backgroundColor = .ypGray
        button.tintColor = .ypWhite
        button.setTitleColor(.ypWhite, for: .normal)
        button.setTitleColor(.ypWhiteOnly, for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapFinishButton), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: Initializers
    convenience init(name: String?) {
        self.init(nibName: nil, bundle: nil)
        self.categoryName = name
        self.categoryNameTextField.text = self.categoryName
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        self.hideKeyboardWhenTappedAround()
        
        configureUI()
    }
    
    // MARK: - Private Methods
    private func configureUI() {
        view.addSubview(mainTitle)
        view.addSubview(finishButton)
        view.addSubview(categoryNameTextField)
        
        NSLayoutConstraint.activate([
            mainTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            mainTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            finishButton.heightAnchor.constraint(equalToConstant: 60),
            finishButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            finishButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            categoryNameTextField.topAnchor.constraint(equalTo: mainTitle.bottomAnchor, constant: 38),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func updateFinishButton() {
        let isNotEmptyInfo = newName != "" && newName != categoryName
        finishButton.isEnabled = isNotEmptyInfo
        finishButton.backgroundColor = isNotEmptyInfo ? .ypBlack : .ypGray
    }
    
    @objc private func didTapFinishButton() {
        guard let categoryName, let newName else { return }
        
        delegate?.editCategory(newName: newName, existingCategory: categoryName)
        dismiss(animated: true)
    }
    
    @objc private func didChangedNameField() {
        self.newName = categoryNameTextField.text
        updateFinishButton()
    }
}
