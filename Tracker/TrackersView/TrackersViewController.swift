//
//  ViewController.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 10.02.2024.
//

import UIKit

class TrackersViewController: UIViewController {
    
    // MARK: - Public properties
    var categories: [TrackerCategory] = mockCategories
    
    var completedTrackers: [TrackerRecord] = []
    var currentDate: Date?
    
    private var dataSource: UICollectionViewDiffableDataSource<TrackerCategory, Tracker>!
    
    private var snapshot: NSDiffableDataSourceSnapshot<TrackerCategory, Tracker>?
    
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
            //let layout = UICollectionViewCompositionalLayout(section: section)
            return section
        }
        
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        //collectionView.backgroundColor = .green
        //collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
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
        //button.text = "12.34.56"
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
    
//        private lazy var noTrackersYetView: UIView = {
//            let view = UIView()
//            view.backgroundColor = .lightGray
//    
//            return view
//        }()
    
    private lazy var noTrackersYetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.noTrackersYet
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var noTrackersYetLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        configureNavBar()
        
        
        configureUI()
        setupCollectionView()
        setupDataSource()
        configureHeader()
        reloadData()
        
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
        
        //collectionView.dataSource = self
        //collectionView.delegate = self
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<TrackerCategory, Tracker>(collectionView: collectionView) {
            (collectionView, IndexPath, ItemIdentifier) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: IndexPath) as! TrackersCollectionViewCell
            cell.configure(with: ItemIdentifier)
            //cell.backgroundColor = .systemPink
            
            return cell
            
        }
        
    }
    
    private func configureHeader() {
        dataSource?.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            //            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? TrackersSectionHeader else {
            //                fatalError("Could not dequeue sectionHeader")
            //            }
            //            sectionHeader.configure(with: self.categories[indexPath])
            //            return sectionHeader
            let header: TrackersSectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! TrackersSectionHeader
            //header.backgroundColor = .ypBlack
            
            if let section = self.snapshot?.sectionIdentifiers[indexPath.section] {
                header.configure(with: section)
            }
            
            return header
        }
    }
    
    
    
    private func reloadData() {
        snapshot = NSDiffableDataSourceSnapshot<TrackerCategory, Tracker>()
        snapshot?.appendSections(categories)
        
        for category in categories {
            
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
        //view.addSubview(addTrackerButton)
        //addTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        
        //view.addSubview(currentDateLabel)
        //currentDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //        view.addSubview(largeTitle)
        //        largeTitle.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchField)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        
        //        view.addSubview(noTrackersYetView)
        //        noTrackersYetView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        
        NSLayoutConstraint.activate([
            //            addTrackerButton.widthAnchor.constraint(equalToConstant: 44),
            //            addTrackerButton.heightAnchor.constraint(equalToConstant: 44),
            //            addTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            //            addTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            
            //            currentDateLabel.widthAnchor.constraint(equalToConstant: 77),
            //            currentDateLabel.heightAnchor.constraint(equalToConstant: 34),
            //            currentDateLabel.centerYAnchor.constraint(equalTo: addTrackerButton.centerYAnchor),
            //            currentDateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            //            largeTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            //            largeTitle.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor, constant: 1),
            
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            searchField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 36),
            
            //            noTrackersYetView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            //            noTrackersYetView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
            
//            noTrackersYetImageView.widthAnchor.constraint(equalToConstant: 80),
//            noTrackersYetImageView.heightAnchor.constraint(equalToConstant: 80),
//            noTrackersYetImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
//            noTrackersYetImageView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 230),
//            
//            noTrackersYetLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
//            noTrackersYetLabel.topAnchor.constraint(equalTo: noTrackersYetImageView.bottomAnchor, constant: 8)
            
        ])
    }
    
    
    
    @objc private func didTapAddTrackerButton() {
        let view = CreateTrackerViewController()
        
        present(view, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }
    
    
    
}

// MARK: Collection Data Source
/*
 extension TrackersViewController: UICollectionViewDataSource {
 
 
 
 /*
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
  3
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TrackersCollectionViewCell
  
  return cell
  }
  */
 
 }
 */


//extension TrackersViewController {
//
//
//    private func createLayout() -> UICollectionViewLayout {
//        // section -> groups -> items -> size
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1.0))
//
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.2))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        let section = NSCollectionLayoutSection(group: group)
//
//        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
//        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
//        section.boundarySupplementaryItems = [sectionHeader]
//        let layout = UICollectionViewCompositionalLayout(section: section)
//        return layout
//    }
//}



// MARK: Collection Delegate
/*
 extension TrackersViewController: UICollectionViewDelegateFlowLayout {
 func collectionView(
 _ collectionView: UICollectionView,
 layout collectionViewLayout: UICollectionViewLayout,
 sizeForItemAt indexPath: IndexPath
 ) -> CGSize {
 return CGSize(width: collectionView.bounds.width / 2, height: 148)
 }
 
 func collectionView(
 _ collectionView: UICollectionView,
 layout collectionViewLayout: UICollectionViewLayout,
 minimumInteritemSpacingForSectionAt section: Int
 ) -> CGFloat {
 return 0
 }
 }
 */

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
        
        func updateUIViewController(_ uiViewController: FlowProvider.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<FlowProvider.ContainerView>) {
            
        }
    }
}
