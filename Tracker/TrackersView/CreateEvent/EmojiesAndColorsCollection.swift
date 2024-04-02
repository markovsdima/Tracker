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

struct Item: Hashable {
    let emoji: String?
    let color: UIColor?
    let category: Category
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(identifier)
    }
    
    static func emojiesAndColors() -> [Item] {
        return [
            Item(emoji: "🙂", color: nil, category: .emojies),
            Item(emoji: "🙂", color: nil, category: .emojies),
            Item(emoji: "🙂", color: nil, category: .emojies),
            Item(emoji: "🙂", color: nil, category: .emojies),
            Item(emoji: "🙂", color: nil, category: .emojies),
            Item(emoji: "🙂", color: nil, category: .emojies),
            Item(emoji: nil, color: .ypBlack, category: .colors),
            Item(emoji: nil, color: .ypBlack, category: .colors),
            Item(emoji: nil, color: .ypBlue, category: .colors),
            Item(emoji: nil, color: .ypBlack, category: .colors),
            Item(emoji: nil, color: .ypGreen, category: .colors),
            Item(emoji: nil, color: .ypBlack, category: .colors)
        ]
    }
}

class EmojiesAndColorsCollection: UIViewController {
    
    
    enum Section: Int, CaseIterable {
        case emojiesSection = 0
        case colors = 1
    }
    
    var selectedEmojiIndex: Int?
    var selectedColorIndex: Int?
    
    let emojies = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                   "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                   "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    let emojies2 = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                   "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                   "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    let colors = [UIColor.ypRed, UIColor.ypBlue]
    
    
    private var dataSource: UICollectionViewDiffableDataSource<Category, Item>!
    private var collectionView: UICollectionView!
    
    //private var snapshot: NSDiffableDataSourceSnapshot<Section, Int>?
    
    
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        configureHierarchy()
        configureDataSource()
        
        collectionView.register(EmojiesSectionViewCell.self, forCellWithReuseIdentifier: EmojiesSectionViewCell.reuseIdentifier)
        collectionView.register(ColorsSectionViewCell.self, forCellWithReuseIdentifier: ColorsSectionViewCell.reuseIdentifier)
        
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
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        
        return layout
    }
}

extension EmojiesAndColorsCollection {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .black
        view.addSubview(collectionView)
    }
    private func configureDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<Category, Item>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            switch item.category {
            case .emojies:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiesSectionViewCell", for: indexPath) as! EmojiesSectionViewCell
                cell.emojiLabel.text = item.emoji
                return cell
            case .colors:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorsSectionViewCell", for: indexPath) as! ColorsSectionViewCell
                cell.colorView.backgroundColor = item.color
                //cell.backgroundColor = .ypBlue
                return cell
            }
            
            //            let section = Section(rawValue: indexPath.section)!
            //            if section == .emojies {
            //                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiesSectionViewCell", for: indexPath) as! EmojiesSectionViewCell
            //                cell.emojiLabel.text = self.emojies[indexPath.row]
            //                //cell.configure(with: identifier)
            //                return cell
            //            } else {
            //                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorsSectionViewCell", for: indexPath) as! ColorsSectionViewCell
            //                cell.emojiLabel.text = self.emojies[indexPath.row]
            //                //ell.configure(with: identifier)
            //                return cell
            //            }
            
            
            
            //cell.delegate = self
            
            
            
        }
        
        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Category, Item>()
        for category in Category.allCases {
            let items = Item.emojiesAndColors().filter { $0.category == category }
            snapshot.appendSections([category])
            snapshot.appendItems(items)
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension EmojiesAndColorsCollection: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            print("Emoji selected: \(Item.emojiesAndColors()[indexPath.row].emoji ?? "")")
        } else {
            print("Color selected")
        }
    }
}
