//
//  CreateEventViewController.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 08.03.2024.
//

import UIKit

protocol CreateEventViewControllerDelegate: AnyObject {
    func updateTrackersCollection()
    func dismissAnimated()
}

class CreateEventViewController: UIViewController {
    
    // MARK: - Public properties
    weak var delegate: CreateEventViewControllerDelegate?
    
    var willDismiss:(() -> Void)?
    var didDismiss:(() -> Void)?
    
    // MARK: - UI Properties
    private lazy var mainTitle: UILabel = {
        let label = UILabel()
        label.text = eventType.name
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var trackerNameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название трекера"
        field.backgroundColor = .ypGrayAlpha
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: field.frame.height))
        field.leftViewMode = .always
        field.layer.cornerRadius = 16
        field.addTarget(self, action: #selector(didChangedNameField), for: .editingChanged)
        field.translatesAutoresizingMaskIntoConstraints = false
        
        return field
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Категория", for: .normal)
        button.setTitleColor(.ypBlack, for: .normal)
        button.backgroundColor = .ypGrayAlpha
        button.contentHorizontalAlignment = .leading
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapCategoryButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var categoryButtonImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .chevron
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var categoryButtonBottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var scheduleButton: UIButton = {
        let button = UIButton()
        button.setTitle("Расписание", for: .normal)
        button.setTitleColor(.ypBlack, for: .normal)
        button.backgroundColor = .ypGrayAlpha
        button.contentHorizontalAlignment = .leading
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        button.addTarget(self, action: #selector(didTapScheduleButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var scheduleButtonImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .chevron
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.backgroundColor = .ypWhite
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypGray
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: - Private Properties
    private var eventType: TrackerTypes
    private var trackerTitle: String?
    private var category = String()
    private var schedule = [WeekDay]()
    private var tracker: Tracker?
    
    // MARK: - Initializers
    init(eventType: TrackerTypes) {
        self.eventType = eventType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        configureUI(with: eventType)
    }
    
    // MARK: - Private Methods
    private func configureUI(with type: TrackerTypes) {
        view.addSubview(mainTitle)
        view.addSubview(trackerNameTextField)
        view.addSubview(categoryButton)
        categoryButton.addSubview(categoryButtonImage)
        
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        if eventType == .regularEvent {
            categoryButton.addSubview(categoryButtonBottomLineView)
            categoryButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            view.addSubview(scheduleButton)
            scheduleButton.addSubview(scheduleButtonImage)
            NSLayoutConstraint.activate([
                categoryButtonBottomLineView.bottomAnchor.constraint(equalTo: categoryButton.bottomAnchor),
                categoryButtonBottomLineView.heightAnchor.constraint(equalToConstant: 1),
                categoryButtonBottomLineView.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
                categoryButtonBottomLineView.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: -16),
                
                scheduleButton.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 0),
                scheduleButton.heightAnchor.constraint(equalToConstant: 75),
                scheduleButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                scheduleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                
                scheduleButtonImage.trailingAnchor.constraint(equalTo: scheduleButton.trailingAnchor, constant: -16),
                scheduleButtonImage.centerYAnchor.constraint(equalTo: scheduleButton.centerYAnchor),
                scheduleButtonImage.heightAnchor.constraint(equalToConstant: 24),
                scheduleButtonImage.widthAnchor.constraint(equalToConstant: 24)
            ])
        }
        
        if eventType == .oneTimeEvent {
            scheduleButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        }
        
        NSLayoutConstraint.activate([
            mainTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 27),
            mainTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            trackerNameTextField.topAnchor.constraint(equalTo: mainTitle.bottomAnchor, constant: 38),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            trackerNameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            categoryButton.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 12),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            categoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            categoryButtonImage.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: -16),
            categoryButtonImage.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor),
            categoryButtonImage.heightAnchor.constraint(equalToConstant: 24),
            categoryButtonImage.widthAnchor.constraint(equalToConstant: 24),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
    }
    
    private func addTracker() {
        let uuid = UUID()
        
        let categoryName = category
        
        guard let trackerTitle else { return }
        
        if eventType == .regularEvent {
            self.tracker = Tracker(
                id: uuid,
                title: trackerTitle,
                color: .ypGreen,
                emoji: "😊",
                schedule: schedule,
                trackerType: self.eventType)
        } else {
            self.tracker = Tracker(
                id: uuid,
                title: trackerTitle,
                color: .ypGreen,
                emoji: "😊",
                schedule: nil,
                trackerType: self.eventType)
        }
        
        var categories = MockData.shared.mockCategories
        
        guard let tracker else { return }
        
        var index = 0
        if categories.contains(where: { $0.title == categoryName }) {
            for category in categories {
                if category.title == categoryName {
                    let updated = TrackerCategory(title: categoryName, trackers: category.trackers + [tracker])
                    categories.remove(at: index)
                    categories.insert(updated, at: 0)
                }
                index += 1
            }
            
            index = 0
            
            var newCategories = [TrackerCategory]()
            newCategories = categories
            
            MockData.shared.mockCategories = newCategories
            
        } else {
            let newCategory = TrackerCategory(title: categoryName, trackers: [tracker])
            var newCategories = categories
            newCategories.append(newCategory)
            categories = newCategories
            
            MockData.shared.mockCategories = newCategories
        }
        
        delegate?.updateTrackersCollection()
    }
    
    @objc private func didTapScheduleButton() {
        let view = ScheduleViewController()
        view.delegate = self
        
        present(view, animated: true)
    }
    
    @objc private func didTapCategoryButton() {
        let view = CategoriesViewController()
        view.delegate = self
        
        present(view, animated: true)
    }
    
    @objc private func didTapCancelButton() {
        willDismiss?()
        dismiss(animated: true) {
            self.didDismiss?()
        }
        delegate?.dismissAnimated()
    }
    
    @objc private func didTapCreateButton() {
        willDismiss?()
        addTracker()
        dismiss(animated: true) {
            self.didDismiss?()
        }
        delegate?.dismissAnimated()
    }
    
    @objc private func didChangedNameField() {
        self.trackerTitle = trackerNameTextField.text
    }
}

// MARK: - ScheduleViewControllerDelegate
extension CreateEventViewController: ScheduleViewControllerDelegate {
    func configWeekDays(_ schedule: [WeekDay]) {
        self.schedule = schedule
    }
}

// MARK: - CategoriesViewControllerDelegate
extension CreateEventViewController: CategoriesViewControllerDelegate {
    func selectCategory(indexPath: IndexPath) {
        self.category = MockData.shared.mockCategories[indexPath.row].title
    }
}
