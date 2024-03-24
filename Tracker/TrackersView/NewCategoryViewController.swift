//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 21.03.2024.
//

import UIKit

protocol NewCategoryViewControllerDelegate: AnyObject {
    func addNewCategory(name: String)
}

final class NewCategoryViewController: UIViewController {
    
    weak var delegate: NewCategoryViewControllerDelegate?
    
    private var categoryName: String?
    
    // MARK: - UI Properties
    private lazy var mainTitle: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var categoryNameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название категории"
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
        button.backgroundColor = .ypBlack
        button.tintColor = .ypWhite
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapFinishButton), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        configureUI()
    }
    
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
    
    @objc func didTapFinishButton() {
        guard let categoryName else {
            return
        }
        delegate?.addNewCategory(name: categoryName)
        dismiss(animated: true)
    }
    
    @objc func didChangedNameField() {
        self.categoryName = categoryNameTextField.text
    }
}
