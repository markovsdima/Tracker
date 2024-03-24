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
    
    lazy var selectedImage: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "checkmark"))
        image.tintColor = .ypBlue
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
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
        selectedImage.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.addSubview(cellTitle)
        contentView.addSubview(selectedImage)
        
        NSLayoutConstraint.activate([
            cellTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            selectedImage.heightAnchor.constraint(equalToConstant: 24),
            selectedImage.widthAnchor.constraint(equalToConstant: 24),
            selectedImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectedImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
            
        ])
    }
    
    func showImageForSelected(_ isHidden: Bool) {
        selectedImage.isHidden = !isHidden
    }
}

