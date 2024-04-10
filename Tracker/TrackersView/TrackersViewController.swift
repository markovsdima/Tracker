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
    private var completedTrackers = Set<TrackerRecord>()
    private var currentDate = Date()
    private var dataSource: UICollectionViewDiffableDataSource<TrackerCategory, Tracker>?
    private var snapshot: NSDiffableDataSourceSnapshot<TrackerCategory, Tracker>?
    private var trackerStore = TrackerStore.shared
    private var trackerRecordStore = TrackerRecordStore.shared
    
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
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        return datePicker
    }()
    
    
    // TODO: - Customize
    private lazy var datePickerButton: UIBarButtonItem = {
        
        let button = UIBarButtonItem(customView: datePicker)
        
//        button.customView?.backgroundColor = .ypGrayAndWhite
//        
//        button.customView?.layer.cornerRadius = 8
//        button.customView?.layer.masksToBounds = true
//        button.tintColor = .ypBlackOnly
//        button.customView?.tintColor = .ypBlackOnly
        
        return button
    }()
    
    private lazy var largeTitle: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        
        
        return searchBar
    }()
    
    private lazy var searchField: UISearchTextField = {
        let field = UISearchTextField()
        field.placeholder = "Поиск"
        
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
        
        do {
            try filterCategoriesByWeekDay()
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
        
        
        
    }
    
    // MARK: - Private Methods
    private func getCompletedTrackersIdsArray(_ trackers: Set<TrackerRecord>) -> [UUID] {
        var identifiers = [UUID]()
        for i in trackers {
            identifiers.append(i.id)
        }
        return identifiers
    }
    
    private func emptyCheck(isEmpty: Bool) {
        
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
        self.navigationItem.title = "Трекеры"
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
    
    private func filterCategoriesByWeekDay() throws {
        let selectedWeekDay = Calendar.current.component(.weekday, from: datePicker.date)
        trackerStore.filterCategoriesByWeekDay(selectedWeekDay: selectedWeekDay)
        filteredCategories = try trackerStore.getTrackerCategories(selectedWeekDay, currentDate: currentDate)
        reloadData()
        //print("Filtered categories-----------: \(filteredCategories)")
        emptyCheck(isEmpty: filteredCategories.isEmpty)
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
    
    @objc private func didTapAddTrackerButton() {
        let view = CreateTrackerViewController()
        
        present(view, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        do {
            try filterCategoriesByWeekDay()
        } catch {
            print("filterCategoriesByWeekDayWhenViewDidLoadError")
        }
        
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
            try filterCategoriesByWeekDay()
        } catch {
            print("filterCategoriesByWeekDayWhenViewDidLoadError")
        }
    }
}
