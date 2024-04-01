//
//  ViewController.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 10.02.2024.
//

import CoreData
import UIKit

class TrackersViewController: UIViewController {
    
    // MARK: - Private Properties
    private var categories: [TrackerCategory] = MockData.shared.mockCategories
    private var filteredCategories: [TrackerCategory] = []
    private var completedTrackers = Set<TrackerRecord>()
    private var currentDate = Date()
    private var dataSource: UICollectionViewDiffableDataSource<TrackerCategory, Tracker>!
    private var snapshot: NSDiffableDataSourceSnapshot<TrackerCategory, Tracker>?
    //private var coreDataManager = CoreDataManager.shared
    private var trackerStore = TrackerStore.shared
    private var trackerCategoryStore = TrackerCategoryStore.shared
    
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
        
        return datePicker
    }()
    
    private lazy var datePickerButton: UIBarButtonItem = {
        let button = UIBarButtonItem(customView: datePicker)
        button.tintColor = .ypBlack
        
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
        emptyCheck()
        
    }
    
    // MARK: - Private Methods
    private func emptyCheck() {
        if categories.count == 0 {
            
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
        }
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
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
            
            //let trackerCategoryCoreData = self.trackerCategoryStore.fetchedResultsController.object(at: IndexPath)
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: IndexPath) as! TrackersCollectionViewCell
            let completion = self.checkForCompletionToday(id: ItemIdentifier.id)
            let completedDaysCount = self.checkForCompletedDaysCount(id: ItemIdentifier.id)
            cell.configure(with: ItemIdentifier, completion: completion, count: completedDaysCount, isFuture: self.checkIsFuture())
            cell.delegate = self
            
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
        let count = MockData.shared.mockCompletedTrackers.filter { tracker in
            tracker.id == id
        }.count
        return count
    }
    
    private func checkForCompletionToday(id: UUID) -> Bool {
        if MockData.shared.mockCompletedTrackers.contains(TrackerRecord(id: id, date: currentDate)) {
            return true
        } else {
            return false
        }
    }
    
    private func configureHeader() {
        dataSource?.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            
            let header: TrackersSectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! TrackersSectionHeader
            
            if let section = self.snapshot?.sectionIdentifiers[indexPath.section] {
                header.configure(with: section)
            }
            
            return header
        }
    }
    
    private func reloadData() {
        snapshot = NSDiffableDataSourceSnapshot<TrackerCategory, Tracker>()
        snapshot?.appendSections(filteredCategories)
        for category in filteredCategories {
            snapshot?.appendItems(category.trackers, toSection: category)
        }
        
        dataSource.apply(snapshot!, animatingDifferences: true)
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
        filteredCategories = try TrackerStore.shared.getTrackerCategories(selectedWeekDay)
        reloadData()
        //print("\n Filtered Categories From Core Data ----------------: \(filteredCategories) \n")
        //print("Categories From Mock Data ----------------: \(MockData.shared.mockCategories)")
        //reloadData()
//        let selectedWeekDay = Calendar.current.component(.weekday, from: datePicker.date)
//        
//        filteredCategories = categories.compactMap { category in
//            
//            let filteredTrackers = category.trackers.filter { tracker in
//                guard let schedule = tracker.schedule else {
//                    return true
//                }
//                
//                return schedule.contains { weekDay in
//                    weekDay.rawValue == selectedWeekDay
//                }
//            }
//            
//            if filteredTrackers.isEmpty {
//                return nil
//            }
//            
//            return TrackerCategory(title: category.title, trackers: filteredTrackers)
//        }
//        
//        reloadData()
    }
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
//        guard let dataSource = collectionView.dataSource as? UICollectionViewDiffableDataSource<Int, NSManagedObjectID> else {
//            assertionFailure("The data source has not implemented snapshot support while it should")
//            return
//        }
//        var snapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
//        let currentSnapshot = dataSource.snapshot() as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
//
//        let reloadIdentifiers: [NSManagedObjectID] = snapshot.itemIdentifiers.compactMap { itemIdentifier in
//            guard let currentIndex = currentSnapshot.indexOfItem(itemIdentifier), let index = snapshot.indexOfItem(itemIdentifier), index == currentIndex else {
//                return nil
//            }
//            guard let existingObject = try? controller.managedObjectContext.existingObject(with: itemIdentifier), existingObject.isUpdated else { return nil }
//            return itemIdentifier
//        }
//        snapshot.reloadItems(reloadIdentifiers)
//
//        let shouldAnimate = collectionView.numberOfSections != 0
//        dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>, animatingDifferences: shouldAnimate)
//    }
    
    @objc private func didTapAddTrackerButton() {
        let view = CreateTrackerViewController()
        view.delegate = self
        
        present(view, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        do {
            try filterCategoriesByWeekDay()
        } catch {
            print("filterCategoriesByWeekDayWhenViewDidLoadError")
        }
        collectionView.reloadData()
    }
    
}

// MARK: - TrackersCollectionViewCellDelegate
extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func changeTrackerCompletionState(id: UUID) {
        if MockData.shared.mockCompletedTrackers.contains(TrackerRecord(id: id, date: currentDate)) {
            MockData.shared.mockCompletedTrackers.remove(TrackerRecord(id: id, date: currentDate))
            completedTrackers = MockData.shared.mockCompletedTrackers
        } else {
            MockData.shared.mockCompletedTrackers.insert(TrackerRecord(id: id, date: currentDate))
            completedTrackers = MockData.shared.mockCompletedTrackers
        }
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func didChangeData(in store: TrackerStore) {
        do {
            try filterCategoriesByWeekDay()
            //collectionView.reloadData()
        } catch {
            print("filterCategoriesByWeekDayWhenViewDidLoadError")
        }
    }
    
}

// MARK: - CreateTrackerViewControllerDelegate
extension TrackersViewController: CreateTrackerViewControllerDelegate {
    func updateTrackersCollection() {
//        do {
//            categories = try TrackerCategoryStore.shared.getTrackerCategories()
//        } catch {
//            print("")
//        }
        //self.categories = TrackerStore.shared.categories
        /*
        do {
            try filterCategoriesByWeekDay()
        } catch {
            print("filterCategoriesByWeekDayWhenViewDidLoadError")
        }
        */
        //print(categories)
        //print("And --------------- \(TrackerCategoryStore.shared.trackerCategories)")
    }
}

extension TrackersViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        guard let dataSource = collectionView.dataSource as? UICollectionViewDiffableDataSourceReference else {
            fatalError("The data source has not implemented snapshot support while it should")
        }
        dataSource.applySnapshot(snapshot, animatingDifferences: true)
    }
}

// MARK: - SwiftUI Preview
import SwiftUI
struct FlowProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        let tabBar = TabBarViewController()
        func makeUIViewController(context:
                                  UIViewControllerRepresentableContext<FlowProvider.ContainerView>) -> TabBarViewController {
            return tabBar
        }
        
        func updateUIViewController(_ uiViewController: FlowProvider.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<FlowProvider.ContainerView>) { }
    }
}
