//
//  CategoriesTableViewCell.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 21.03.2024.
//

import UIKit

final class CategoriesTableViewCell: UITableViewCell {
    
    // MARK: - UI Properties
    lazy var cellTitle: UILabel = {
        let label = UILabel()
        //label.text = "День недели"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // MARK: - Public Properties
    static let reuseIdentifier = "CategoriesTableViewCell"
   // weak var delegate: ScheduleTableViewCellDelegate?
    

//    override func prepareForReuse() {
//        super.prepareForReuse()
//
//        configureUI()
//    }
    
    // MARK: - Override Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.addSubview(cellTitle)
        
        NSLayoutConstraint.activate([
            cellTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

