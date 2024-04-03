//
//  EmojiesAndColorsCollection.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 01.04.2024.
//

import UIKit

//enum Category: String, CaseIterable {
//  case emojies = "Emojies"
//  case colors = "Colors"
//}

private class EmojiesAndColorsCollection: UIViewController {
    
    var selectedEmojiIndex: Int?
    var selectedColorIndex: Int?
    
    private var dataSource: UICollectionViewDiffableDataSource<Category, EmojiesAndColorsItem>!
    private var collectionView: UICollectionView!
    private var snapshot: NSDiffableDataSourceSnapshot<Category, EmojiesAndColorsItem>?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        configureHierarchy()
        configureDataSource()
        configureHeader()
        
        collectionView.register(EmojiesSectionViewCell.self, forCellWithReuseIdentifier: EmojiesSectionViewCell.reuseIdentifier)
        collectionView.register(ColorsSectionViewCell.self, forCellWithReuseIdentifier: ColorsSectionViewCell.reuseIdentifier)
        collectionView.register(EmojiesAndColorsSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiesAndColorsSectionHeader.reuseIdentifier)
        
        collectionView.delegate = self
    }
    
}

extension EmojiesAndColorsCollection {
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

extension EmojiesAndColorsCollection {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .ypWhite
        collectionView.allowsMultipleSelection = true
        view.addSubview(collectionView)
    }
    
    private func configureHeader() {
        dataSource?.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            
            let header: EmojiesAndColorsSectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiesAndColorsSectionHeader.reuseIdentifier, for: indexPath) as! EmojiesAndColorsSectionHeader
            
            if indexPath.section == 0 {
                header.titleLabel.text = "Emoji"
            } else {
                header.titleLabel.text = "Цвет"
            }
            
            return header
        }
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Category, EmojiesAndColorsItem>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            switch item.category {
            case .emojies:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiesSectionViewCell", for: indexPath) as! EmojiesSectionViewCell
                cell.emojiLabel.text = item.emoji
                
                return cell
            case .colors:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorsSectionViewCell", for: indexPath) as! ColorsSectionViewCell
                cell.configure(with: item.color ?? .ypGray)
                
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
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension EmojiesAndColorsCollection: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        ((collectionView.indexPathsForSelectedItems?.filter({ $0.section == indexPath.section }).forEach({ collectionView.deselectItem(at: $0, animated: false) })) != nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            print("Emoji selected: \(EmojiesAndColorsItem.emojiesAndColors()[indexPath.row].emoji ?? "")")
            self.selectedEmojiIndex = indexPath.row
        } else {
            let index = indexPath.row + 18
            print("Color selected: \(EmojiesAndColorsItem.emojiesAndColors()[index].color ?? UIColor.gray)")
            self.selectedColorIndex = indexPath.row + 18
        }
    }
}
