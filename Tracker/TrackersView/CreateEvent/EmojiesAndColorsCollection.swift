//
//  EmojiesAndColorsCollection.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 01.04.2024.
//

import UIKit

enum Category: String, CaseIterable {
  case emojies = "Emojies"
  case colors = "Colors"
}

private struct EmojiesAndColorsItem: Hashable {
    let emoji: String?
    let color: UIColor?
    let category: Category
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(identifier)
    }
    
    static func emojiesAndColors() -> [EmojiesAndColorsItem] {
        return [
            EmojiesAndColorsItem(emoji: "🙂", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "😻", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🌺", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🐶", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "❤️", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "😱", color: nil, category: .emojies),
            
            EmojiesAndColorsItem(emoji: "😇", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "😡", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🥶", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🤔", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🙌", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🍔", color: nil, category: .emojies),
            
            EmojiesAndColorsItem(emoji: "🥦", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🏓", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🥇", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🎸", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "🏝", color: nil, category: .emojies),
            EmojiesAndColorsItem(emoji: "😪", color: nil, category: .emojies),
            
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color1, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color2, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color3, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color4, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color5, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color6, category: .colors),
            
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color7, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color8, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color9, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color10, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color11, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color12, category: .colors),
            
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color13, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color14, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color15, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color16, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color17, category: .colors),
            EmojiesAndColorsItem(emoji: nil, color: ColorsForTrackerCreation.color18, category: .colors)
        ]
    }
}

struct ColorsForTrackerCreation {
    static let color1 = UIColor(hex: "#FD4C49")
    static let color2 = UIColor(hex: "#FF881E")
    static let color3 = UIColor(hex: "#007BFA")
    static let color4 = UIColor(hex: "#6E44FE")
    static let color5 = UIColor(hex: "#33CF69")
    static let color6 = UIColor(hex: "#E66DD4")
    
    static let color7 = UIColor(hex: "#F9D4D4")
    static let color8 = UIColor(hex: "#34A7FE")
    static let color9 = UIColor(hex: "#46E69D")
    static let color10 = UIColor(hex: "#35347C")
    static let color11 = UIColor(hex: "#FF674D")
    static let color12 = UIColor(hex: "#FF99CC")
    
    static let color13 = UIColor(hex: "#F6C48B")
    static let color14 = UIColor(hex: "#7994F5")
    static let color15 = UIColor(hex: "#832CF1")
    static let color16 = UIColor(hex: "#AD56DA")
    static let color17 = UIColor(hex: "#8D72E6")
    static let color18 = UIColor(hex: "#2FD058")
}

class EmojiesAndColorsCollection: UIViewController {
    
    
//    enum Section: Int, CaseIterable {
//        case emojiesSection = 0
//        case colors = 1
//    }
    
    var selectedEmojiIndex: Int?
    var selectedColorIndex: Int?
    
    let emojies = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                   "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                   "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    let emojies2 = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                   "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                   "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    let colors = [UIColor.ypRed, UIColor.ypBlue]
    
    
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
        //collectionView.register(TrackersSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    }
    
    
    
    //    private func reloadData() {
    //        snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
    //        snapshot?.appendSections(filteredCategories)
    //        for category in filteredCategories {
    //            snapshot?.appendItems(category.trackers, toSection: category)
    //        }
    //
    //        dataSource.apply(snapshot!, animatingDifferences: true)
    //    }
    
}

extension EmojiesAndColorsCollection {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/6),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.2))
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
            
//            if let section = self.snapshot?.sectionIdentifiers[indexPath.section] {
//                //header.configure(with: Category.)
//                header.titleLabel.text = "123"
//            }
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
                cell.colorView.backgroundColor = item.color
                
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
        //print(selectedEmojiIndex, selectedColorIndex)
    }
}
