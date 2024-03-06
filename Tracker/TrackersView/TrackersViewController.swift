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
    
    // MARK: - UI Properties
    private var dataSource: UICollectionViewDiffableDataSource<TrackerCategory, Tracker>!
    
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
    
    //    private lazy var noTrackersYetView: UIView = {
    //        let view = UIView()
    //        view.backgroundColor = .lightGray
    //
    //        return view
    //    }()
    
    private lazy var noTrackersYetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.noTrackersYet
        
        return imageView
    }()
    
    private lazy var noTrackersYetLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        
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
        reloadData()
        
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    // MARK: - Private Methods
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
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
    
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<TrackerCategory, Tracker>()
        snapshot.appendSections(categories)
        
        for category in categories {
            snapshot.appendItems(category.trackers, toSection: category)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
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
        
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        //        view.addSubview(noTrackersYetView)
        //        noTrackersYetView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(noTrackersYetImageView)
        noTrackersYetImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(noTrackersYetLabel)
        noTrackersYetLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
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
            
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
            //            noTrackersYetView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            //            noTrackersYetView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
            
            noTrackersYetImageView.widthAnchor.constraint(equalToConstant: 80),
            noTrackersYetImageView.heightAnchor.constraint(equalToConstant: 80),
            noTrackersYetImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            noTrackersYetImageView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 230),
            
            noTrackersYetLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            noTrackersYetLabel.topAnchor.constraint(equalTo: noTrackersYetImageView.bottomAnchor, constant: 8)
            
        ])
    }
    
    @objc private func didTapAddTrackerButton() {
        NSLog("123")
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy" // Формат даты
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
extension TrackersViewController {
    
    
    private func createLayout() -> UICollectionViewLayout {
        // section -> groups -> items -> size
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

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
