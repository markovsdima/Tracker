//
//  CreateEventViewController.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 08.03.2024.
//

import UIKit

protocol CreateEventViewControllerDelegate: AnyObject {
    func dismissAnimated()
}

enum Category: String, CaseIterable {
    case emojies = "Emojies"
    case colors = "Colors"
}

final class CreateEventViewController: UIViewController {
    
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
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var trackerNameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Введите название трекера"
        field.backgroundColor = .ypGrayAlpha
        field.font = .systemFont(ofSize: 17)
        
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
    
    private lazy var categoryButtonSubtitle: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
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
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
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
    
    private lazy var scheduleButtonSubtitle: UILabel = {
        let label = UILabel()
        label.text = "Дни недели"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
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
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
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
        button.setTitleColor(.ypWhiteOnly, for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: - Private Properties
    private var eventType: TrackerTypes
    private var trackerTitle: String? = ""
    private var category = String()
    private var schedule = [WeekDay]()
    private var tracker: Tracker?
    private var selectedEmojiIndex: Int?
    private var selectedColorIndex: Int?
    
    private var dataSource: UICollectionViewDiffableDataSource<Category, EmojiesAndColorsItem>?
    private var collectionView: UICollectionView?
    private var snapshot: NSDiffableDataSourceSnapshot<Category, EmojiesAndColorsItem>?
    
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
        self.hideKeyboardWhenTappedAround()
        configureCollection()
        configureUI(with: eventType)
    }
    
    // MARK: - Private Methods
    private func configureCollection() {
        configureHierarchy()
        configureDataSource()
        configureHeader()
        
        collectionView?.register(EmojiesSectionViewCell.self, forCellWithReuseIdentifier: EmojiesSectionViewCell.reuseIdentifier)
        collectionView?.register(ColorsSectionViewCell.self, forCellWithReuseIdentifier: ColorsSectionViewCell.reuseIdentifier)
        collectionView?.register(EmojiesAndColorsSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiesAndColorsSectionHeader.reuseIdentifier)
        
        collectionView?.delegate = self
    }
    
    private func configureUI(with type: TrackerTypes) {
        guard let collectionView else { return }
        view.addSubview(mainTitle)
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(trackerNameTextField)
        contentView.addSubview(categoryButton)
        
        categoryButton.addSubview(categoryButtonImage)
        
        
        contentView.addSubview(collectionView)
        contentView.addSubview(cancelButton)
        contentView.addSubview(createButton)
        
        let baseContentViewHeight: CGFloat = 794
        
        if eventType == .regularEvent {
            categoryButton.addSubview(categoryButtonBottomLineView)
            categoryButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            contentView.addSubview(scheduleButton)
            scheduleButton.addSubview(scheduleButtonImage)
            NSLayoutConstraint.activate([
                categoryButtonBottomLineView.bottomAnchor.constraint(equalTo: categoryButton.bottomAnchor),
                categoryButtonBottomLineView.heightAnchor.constraint(equalToConstant: 0.5),
                categoryButtonBottomLineView.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
                categoryButtonBottomLineView.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: -16),
                
                scheduleButton.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 0),
                scheduleButton.heightAnchor.constraint(equalToConstant: 75),
                scheduleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                scheduleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                
                scheduleButtonImage.trailingAnchor.constraint(equalTo: scheduleButton.trailingAnchor, constant: -16),
                scheduleButtonImage.centerYAnchor.constraint(equalTo: scheduleButton.centerYAnchor),
                scheduleButtonImage.heightAnchor.constraint(equalToConstant: 24),
                scheduleButtonImage.widthAnchor.constraint(equalToConstant: 24),
                
                contentView.heightAnchor.constraint(equalToConstant: baseContentViewHeight+75),
                
                collectionView.topAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: 16)
            ])
        }
        
        if eventType == .oneTimeEvent {
            scheduleButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            NSLayoutConstraint.activate([
                contentView.heightAnchor.constraint(equalToConstant: baseContentViewHeight),
                
                collectionView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 16)
            ])
        }
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: mainTitle.bottomAnchor, constant: 14),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            mainTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            mainTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            trackerNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            trackerNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            categoryButton.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 12),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            categoryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            categoryButtonImage.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: -16),
            categoryButtonImage.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor),
            categoryButtonImage.heightAnchor.constraint(equalToConstant: 24),
            categoryButtonImage.widthAnchor.constraint(equalToConstant: 24),
            
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 500),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            cancelButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
    }
    
    private func createScheduleDaysText() -> String {
        if schedule == [] {
            return ""
        }
        let daysShortNames = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]
        var daysSelected = [String]()
        for day in schedule {
            daysSelected.append(daysShortNames[(day.rawValue) - 1])
        }
        if daysSelected.count == 7 {
            return "Каждый день"
        }
        
        return daysSelected.joined(separator: ", ")
    }
    
    private func updateScheduleButtonSubtitle() {
        let text = createScheduleDaysText()
        if text.isEmpty {
            scheduleButtonSubtitle.isHidden = true
            scheduleButton.titleEdgeInsets.top = 0
        } else {
            scheduleButton.addSubview(scheduleButtonSubtitle)
            scheduleButton.titleEdgeInsets = UIEdgeInsets(top: -24, left: 16, bottom: 0, right: 0)
            scheduleButtonSubtitle.text = text
            scheduleButtonSubtitle.isHidden = false
            
            NSLayoutConstraint.activate([
                scheduleButtonSubtitle.bottomAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: -16),
                scheduleButtonSubtitle.leadingAnchor.constraint(equalTo: scheduleButton.leadingAnchor, constant: 16),
                scheduleButtonSubtitle.heightAnchor.constraint(equalToConstant: 22)
            ])
        }
    }
    
    private func updateCategoryButtonSubtitle() {
        if category == "" {
            categoryButtonSubtitle.isHidden = true
            categoryButton.titleEdgeInsets.top = 0
        } else {
            categoryButton.addSubview(categoryButtonSubtitle)
            categoryButton.titleEdgeInsets = UIEdgeInsets(top: -24, left: 16, bottom: 0, right: 0)
            categoryButtonSubtitle.text = category
            categoryButtonSubtitle.isHidden = false
            
            NSLayoutConstraint.activate([
                categoryButtonSubtitle.bottomAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: -16),
                categoryButtonSubtitle.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
                categoryButtonSubtitle.heightAnchor.constraint(equalToConstant: 22)
            ])
        }
    }
    
    private func addTracker() throws {
        let uuid = UUID()
        
        let categoryName = category
        
        guard let trackerTitle else { return }
        var color: UIColor = UIColor.gray
        var emoji: String = "❓"
        
        if let selectedColorIndex {
            color = EmojiesAndColorsItem.emojiesAndColors()[selectedColorIndex].color ?? UIColor.gray
        }
        
        if let selectedEmojiIndex {
            emoji = EmojiesAndColorsItem.emojiesAndColors()[selectedEmojiIndex].emoji ?? "❓"
        }
        
        if eventType == .regularEvent {
            self.tracker = Tracker(
                id: uuid,
                title: trackerTitle,
                color: color,
                emoji: emoji,
                schedule: schedule,
                trackerType: self.eventType, 
                pin: false)
        } else {
            self.tracker = Tracker(
                id: uuid,
                title: trackerTitle,
                color: color,
                emoji: emoji,
                schedule: nil,
                trackerType: self.eventType, 
                pin: false)
        }
        
        guard let tracker else { return }
        
        let newCategory = TrackerCategory(title: categoryName, trackers: [tracker])
        try TrackerStore.shared.addTracker(tracker, to: newCategory)
        
    }
    
    private func updateCreateButton() {
        switch eventType {
        case .oneTimeEvent:
            let isNotEmptyInfo =
            trackerTitle != ""
            && category != ""
            && selectedColorIndex != nil
            && selectedEmojiIndex != nil
            
            createButton.isEnabled = isNotEmptyInfo
            createButton.backgroundColor = isNotEmptyInfo ? .ypBlack : .ypGray
        case .regularEvent:
            let isNotEmptyInfo = 
            trackerTitle != ""
            && category != ""
            && schedule != []
            && selectedColorIndex != nil
            && selectedEmojiIndex != nil
            
            createButton.isEnabled = isNotEmptyInfo
            createButton.backgroundColor = isNotEmptyInfo ? .ypBlack : .ypGray
        }
    }
    
    @objc private func didTapScheduleButton() {
        let view = ScheduleViewController()
        view.delegate = self
        
        present(view, animated: true)
    }
    
    @objc private func didTapCategoryButton() {
        let viewModel = CategoriesViewModel()
        viewModel.delegate = self
        let view = CategoriesViewController(viewModel: viewModel)
        
        present(view, animated: true)
    }
    
    @objc private func didTapCancelButton() {
        willDismiss?()
        dismiss(animated: true) {
            self.didDismiss?()
        }
        delegate?.dismissAnimated()
    }
    
    @objc private func didTapCreateButton() throws {
        willDismiss?()
        try addTracker()
        dismiss(animated: true) {
            self.didDismiss?()
        }
        delegate?.dismissAnimated()
    }
    
    @objc private func didChangedNameField() {
        self.trackerTitle = trackerNameTextField.text
        updateCreateButton()
    }
}

// MARK: - ScheduleViewControllerDelegate
extension CreateEventViewController: ScheduleViewControllerDelegate {
    func configWeekDays(_ schedule: [WeekDay]) {
        self.schedule = schedule
        self.updateScheduleButtonSubtitle()
        self.updateCreateButton()
    }
}

// MARK: - CategoriesViewModelDelegate
extension CreateEventViewController: CategoriesViewModelDelegate {
    func selectCategory(title: String?) {
        guard let title else { return }
        self.category = title
        self.updateCategoryButtonSubtitle()
        self.updateCreateButton()
    }
}

// MARK: - UICollectionViewLayout
///(EmojiesAndColorsCollection)
extension CreateEventViewController {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/6),
                                              heightDimension: .fractionalWidth(1/6))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(1/6))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}

// MARK: - UICollectionViewConfiguration
///(EmojiesAndColorsCollection)
extension CreateEventViewController {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.backgroundColor = .ypWhite
        collectionView?.isScrollEnabled = false
        collectionView?.allowsMultipleSelection = true
    }
    
    private func configureHeader() {
        dataSource?.supplementaryViewProvider = {
            (collectionView: UICollectionView,
             kind: String,
             indexPath: IndexPath
            ) -> UICollectionReusableView? in
            
            
            guard let header: EmojiesAndColorsSectionHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: EmojiesAndColorsSectionHeader.reuseIdentifier,
                for: indexPath
            ) as? EmojiesAndColorsSectionHeader else {
                return UICollectionReusableView()
            }
            
            if indexPath.section == 0 {
                header.configureHeader(title: "Emoji")
            } else {
                header.configureHeader(title: "Цвет")
            }
            
            return header
        }
    }
    
    private func configureDataSource() {
        guard let collectionView else { return }
        dataSource = UICollectionViewDiffableDataSource<Category, EmojiesAndColorsItem>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            switch item.category {
            case .emojies:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiesSectionViewCell", for: indexPath) as? EmojiesSectionViewCell
                cell?.configure(with: item.emoji ?? "❓")
                
                return cell
            case .colors:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorsSectionViewCell", for: indexPath) as? ColorsSectionViewCell
                cell?.configure(with: item.color ?? .ypGray)
                
                return cell
            }
        }
        
        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Category, EmojiesAndColorsItem>()
        for category in Category.allCases {
            let items = EmojiesAndColorsItem.emojiesAndColors().filter { $0.category == category }
            snapshot.appendSections([category])
            snapshot.appendItems(items)
        }
        
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - UICollectionViewDelegate
///(EmojiesAndColorsCollection)
extension CreateEventViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        if let selected = collectionView.indexPathsForSelectedItems?.first(where: { $0.section == indexPath.section }) {
            collectionView.deselectItem(at: selected, animated: false)
            return true
        } else {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.selectedEmojiIndex = indexPath.row
            updateCreateButton()
        } else {
            self.selectedColorIndex = indexPath.row + 18
            updateCreateButton()
        }
    }
}
