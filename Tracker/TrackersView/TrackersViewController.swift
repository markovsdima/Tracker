//
//  ViewController.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 10.02.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Private Properties
    private var categories: [TrackerCategory] = MockData.shared.mockCategories
    private var filteredCategories: [TrackerCategory] = []
    private var filteredCategoriesBeforeSearch: [TrackerCategory] = []
    private var completedTrackers = Set<TrackerRecord>()
    private var currentDate = Date()
    private var dataSource: UICollectionViewDiffableDataSource<TrackerCategory, Tracker>?
    private var snapshot: NSDiffableDataSourceSnapshot<TrackerCategory, Tracker>?
    private var trackerStore = TrackerStore.shared
    private var trackerRecordStore = TrackerRecordStore.shared
    
    private let filterTypes: [FilterType] = [.allTrackers, .todayTrackers, .completed, .uncompleted]
    private var userDefaultsFilterType = UserDefaults.standard.integer(forKey: "filterType")
    private var filtrationType: FilterType = .allTrackers {
        didSet { updateFiltrationType() }
    }
    
    private var trackerStoreFiltrationType: trackerStoreFiltrationType = .all
    private var isAnimating = false
    private let analyticsService = AnalyticsService.shared
    
    // MARK: - UI Properties
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .fractionalHeight(1.0)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(148)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(9)
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 5
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            
            let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
        }
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        return collectionView
    }()
    
    private lazy var addTrackerButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage.addTracker
        button.tintColor = .ypBlack
        button.target = self
        button.action = #selector(didTapAddTrackerButton)
        
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale.current
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        return datePicker
    }()
    
    private lazy var datePickerButton: UIBarButtonItem = {
        let button = UIBarButtonItem(customView: datePicker)
        
        return button
    }()
    
    private lazy var searchField: UISearchTextField = {
        let field = UISearchTextField()
        field.placeholder = "Поиск"
        field.addTarget(self, action: #selector(didChangedSearchField), for: .editingChanged)
        field.addTarget(self, action: #selector(didEndSearchField), for: .editingDidEnd)
        field.delegate = self
        
        return field
    }()
    
    private lazy var noTrackersYetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.noTrackersYet
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var noTrackersYetLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.setTitle("Фильтры", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = .ypBlue
        button.setTitleColor(.ypWhiteOnly, for: .normal)
        button.contentEdgeInsets = .init(top: 14, left: 20, bottom: 14, right: 20)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapFiltersButton), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        self.hideKeyboardWhenTappedAround()
        
        trackerStore.delegate = self
        configureNavBar()
        configureUI()
        setupCollectionView()
        setupDataSource()
        configureHeader()
        
        filtrationType = filterTypes[userDefaultsFilterType]
        
        do {
            try filterCategoriesByWeekDay(trackerStoreFiltrationType)
        } catch {
            print("filterCategoriesByWeekDayWhenViewDidLoadError")
        }
        
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(TrackersSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        do {
            completedTrackers = try trackerRecordStore.fetchTrackerRecord()
        } catch {
            print("FetchingTrackersRecordsError")
        }
        
        collectionView.contentInset.bottom = 60
        collectionView.addSubview(filtersButton)
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        analyticsService.report(event: "open", params: ["screen" : "Main"])
        
        animateButton(
            filtrationType == .completed || filtrationType == .uncompleted
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        analyticsService.report(event: "close", params: ["screen" : "Main"])
    }
    
    // MARK: - Private Methods
    private func updateFiltrationType() {
        switch filtrationType {
        case .allTrackers:
            do {
                trackerStoreFiltrationType = .all
                UserDefaults.standard.set(0, forKey: "filterType")
                try filterCategoriesByWeekDay(trackerStoreFiltrationType)
                animateButton(false)
            } catch {
                print("updateFiltrationTypeToAllError")
            }
        case .todayTrackers:
            datePicker.date = Date()
            do {
                trackerStoreFiltrationType = .all
                UserDefaults.standard.set(1, forKey: "filterType")
                try filterCategoriesByWeekDay(trackerStoreFiltrationType)
                animateButton(false)
            } catch {
                print("updateFiltrationTypeToAllAndDateToTodayError")
            }
        case .completed:
            do {
                trackerStoreFiltrationType = .completed
                UserDefaults.standard.set(2, forKey: "filterType")
                try filterCategoriesByWeekDay(trackerStoreFiltrationType)
                animateButton(true)
            } catch {
                print("updateFiltrationTypeToCompletedError")
            }
        case .uncompleted:
            do {
                trackerStoreFiltrationType = .uncompleted
                UserDefaults.standard.set(3, forKey: "filterType")
                try filterCategoriesByWeekDay(trackerStoreFiltrationType)
                animateButton(true)
            } catch {
                print("updateFiltrationTypeToUncompletedError")
            }
        }
        
    }
    
    private func animateButton(_ animate: Bool) {
        if animate == true {
            filtersButton.layer.shadowRadius = 0
            filtersButton.layer.shadowPath = CGPath(roundedRect: filtersButton.bounds, cornerWidth: 16, cornerHeight: 16, transform: nil)
            filtersButton.layer.shadowColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
            filtersButton.layer.shadowOffset = CGSize.zero
            filtersButton.layer.shadowOpacity = 1
            
            let shadowRadiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
            
            shadowRadiusAnimation.fromValue = 0
            shadowRadiusAnimation.toValue = 10
            shadowRadiusAnimation.duration = 2
            shadowRadiusAnimation.autoreverses = true
            shadowRadiusAnimation.repeatCount = .infinity
            
            filtersButton.layer.add(shadowRadiusAnimation, forKey: "shadowRadius")
        } else {
            filtersButton.layer.removeAnimation(forKey: "shadowRadius")
        }
    }
    
    private func getCompletedTrackersIdsArray(_ trackers: Set<TrackerRecord>) -> [UUID] {
        var identifiers = [UUID]()
        for i in trackers {
            identifiers.append(i.id)
        }
        return identifiers
    }
    
    private func emptyCheck(isEmpty: Bool, afterSearch: Bool) {
        
        view.addSubview(noTrackersYetImageView)
        view.addSubview(noTrackersYetLabel)
        
        noTrackersYetImageView.layer.zPosition = 10
        noTrackersYetLabel.layer.zPosition = 10
        
        NSLayoutConstraint.activate([
            noTrackersYetImageView.widthAnchor.constraint(equalToConstant: 80),
            noTrackersYetImageView.heightAnchor.constraint(equalToConstant: 80),
            noTrackersYetImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            noTrackersYetImageView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 230),
            
            noTrackersYetLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            noTrackersYetLabel.topAnchor.constraint(equalTo: noTrackersYetImageView.bottomAnchor, constant: 8)
        ])
        
        noTrackersYetImageView.isHidden = !isEmpty
        noTrackersYetLabel.isHidden = !isEmpty
        if filtrationType == .allTrackers || filtrationType == .todayTrackers {
            filtersButton.isHidden = isEmpty
        }
        
        noTrackersYetLabel.text = afterSearch ? "Ничего не найдено" : "Что будем отслеживать?"
        noTrackersYetImageView.image = afterSearch ? .notFound : .noTrackersYet
        
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .ypWhite
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 8),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<TrackerCategory, Tracker>(collectionView: collectionView) {
            (collectionView, IndexPath, ItemIdentifier) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: IndexPath) as? TrackersCollectionViewCell
            
            let completion = self.checkForCompletionToday(id: ItemIdentifier.id)
            
            let completedDaysCount = self.checkForCompletedDaysCount(id: ItemIdentifier.id)
            
            cell?.configure(with: ItemIdentifier, completion: completion, count: completedDaysCount, isFuture: self.checkIsFuture())
            cell?.delegate = self
            
            return cell
        }
    }
    
    private func checkIsFuture() -> Bool {
        if currentDate.timeIntervalSinceNow.sign == .plus {
            return true
        }
        return false
    }
    
    private func checkForCompletedDaysCount(id: UUID) -> Int {
        let count = completedTrackers.filter { tracker in
            tracker.id == id
        }.count
        return count
    }
    
    private func checkForCompletionToday(id: UUID) -> Bool {
        guard let date = currentDate.onlyDate else { return false }
        if completedTrackers.contains(TrackerRecord(id: id, date: date)) {
            return true
        } else {
            return false
        }
    }
    
    private func configureHeader() {
        dataSource?.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            
            let header: TrackersSectionHeader? = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as? TrackersSectionHeader
            
            if let section = self.snapshot?.sectionIdentifiers[indexPath.section] {
                header?.configure(with: section)
            }
            return header
        }
    }
    
    private func reloadData() {
        snapshot = NSDiffableDataSourceSnapshot<TrackerCategory, Tracker>()
        snapshot?.appendSections(filteredCategories)
        for category in filteredCategories {
            snapshot?.appendItems(category.trackers, toSection: category)
            snapshot?.reloadItems(category.trackers)
        }
        
        guard let snapshot else { return }
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func configureNavBar() {
        self.navigationItem.title = NSLocalizedString("Trackers", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = addTrackerButton
        navigationItem.rightBarButtonItem = datePickerButton
    }
    
    private func configureUI() {
        view.addSubview(searchField)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            searchField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func filterCategoriesByWeekDay(_ filtrationType: trackerStoreFiltrationType) throws {
        let selectedWeekDay = Calendar.current.component(.weekday, from: datePicker.date)
        trackerStore.filterCategoriesByWeekDay(selectedWeekDay: selectedWeekDay)
        filteredCategories = try trackerStore.getTrackerCategories(selectedWeekDay, currentDate: currentDate, filtrationType: filtrationType)
        reloadData()
        var isAfterSearch = false
        if filtrationType == .completed || filtrationType == .uncompleted {
            isAfterSearch = true
        }
        
        emptyCheck(isEmpty: filteredCategories.isEmpty, afterSearch: isAfterSearch)
        filteredCategoriesBeforeSearch = filteredCategories
        checkSearchText()
    }
    
    private func showDeleteActionSheet(id: UUID?) {
        let alert = UIAlertController(
            title: nil,
            message: "Уверены что хотите удалить трекер?",
            preferredStyle: .actionSheet
        )
        let deleteAction = UIAlertAction(
            title: "Удалить",
            style: .destructive
        ) { _ in
            
            do {
                try self.trackerStore.deleteTracker(with: id)
                self.reloadData()
            } catch {
                print("Unable to delete tracker. Error: \(error)")
            }
            
            alert.dismiss(animated: true)
        }
        let cancelAction = UIAlertAction(
            title: "Отменить",
            style: .cancel
        ) { _ in
            alert.dismiss(animated: true)
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    private func checkSearchText() {
        if searchField.text != "", let searchText = searchField.text {
            var searchFilteredCategories: [TrackerCategory] = []
            
            for category in filteredCategoriesBeforeSearch {
                var filteredTrackers: [Tracker] = []
                for tracker in category.trackers {
                    if tracker.title.lowercased().contains(searchText.lowercased()) {
                        filteredTrackers.append(tracker)
                    }
                }
                if !filteredTrackers.isEmpty {
                    searchFilteredCategories.append(TrackerCategory(title: category.title, trackers: filteredTrackers))
                }
            }
            filteredCategories = searchFilteredCategories
            reloadData()
            emptyCheck(isEmpty: filteredCategories.isEmpty, afterSearch: true)
            
        }
    }
    
    @objc private func didTapAddTrackerButton() {
        analyticsService.report(event: "click", params: ["screen" : "Main", "item" : "add_track"])
        let view = CreateTrackerViewController()
        
        present(view, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        do {
            try filterCategoriesByWeekDay(trackerStoreFiltrationType)
        } catch {
            print("filterCategoriesByWeekDayWhenViewDidLoadError")
        }
        
    }
    
    @objc private func didTapFiltersButton() {
        analyticsService.report(event: "click", params: ["screen" : "Main", "item" : "filter"])
        
        let view = FiltersViewController(currentFilter: self.filtrationType)
        view.delegate = self
        
        present(view, animated: true)
    }
    
    @objc private func didEndSearchField() {
        checkSearchText()
        if searchField.text == "" || searchField.text == nil {
            filteredCategories = filteredCategoriesBeforeSearch
            reloadData()
        }
    }
    
    @objc private func didChangedSearchField() {
        checkSearchText()
        if searchField.text == "" {
            filteredCategories = filteredCategoriesBeforeSearch
            reloadData()
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension TrackersViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        emptyCheck(isEmpty: false, afterSearch: true)
        return true
    }
}

// MARK: - TrackersCollectionViewCellDelegate
extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func changeTrackerCompletionState(tracker: Tracker) {
        guard let date = currentDate.onlyDate else { return }
        
        if completedTrackers.contains(TrackerRecord(id: tracker.id, date: date)) {
            
            do {
                guard let date = currentDate.onlyDate else { return }
                try trackerRecordStore.removeRecord(id: tracker.id, date: date)
                completedTrackers = try trackerRecordStore.fetchTrackerRecord()
                snapshot?.reloadItems([tracker])
            } catch { print("Error: \(error) in TrackersViewController.changeTrackerCompletionState()") }
            
        } else {
            
            do {
                guard let date = currentDate.onlyDate else { return }
                trackerRecordStore.addTrackerRecord(for: tracker, date: date)
                completedTrackers = try trackerRecordStore.fetchTrackerRecord()
                snapshot?.reloadItems([tracker])
            } catch { print("Error: \(error) in TrackersViewController.changeTrackerCompletionState()") }
            
        }
        
    }
    
    func updateTrackerPinAction(id: UUID?, isPinned: Bool) {
        guard let id else { return }
        do {
            try trackerStore.updateTrackerPin(trackerId: id, isPinned: isPinned)
        } catch {
            
        }
        
    }
    
    func editTrackerAction(tracker: Tracker?, daysCount: Int?) {
        guard let tracker, let daysCount else { return }
        
        let view = EditEventViewController(tracker: tracker, daysCount: daysCount)
        
        present(view, animated: true)
    }
    
    func deleteTrackerAction(id: UUID?) {
        showDeleteActionSheet(id: id)
    }
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func didChangeData(in store: TrackerStore) {
        do {
            try filterCategoriesByWeekDay(trackerStoreFiltrationType)
        } catch {
            print("filterCategoriesByWeekDayWhenViewDidLoadError")
        }
    }
}

// MARK: FiltersViewControllerDelegate
extension TrackersViewController: FiltersViewControllerDelegate {
    func changeFiltrationType(to type: FilterType) {
        filtrationType = type
    }
}
