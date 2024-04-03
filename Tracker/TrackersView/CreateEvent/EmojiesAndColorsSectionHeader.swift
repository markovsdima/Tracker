//
//  EmojiesAndColorsSectionHeader.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 02.04.2024.
//

import UIKit

class EmojiesAndColorsSectionHeader: UICollectionReusableView {
    static let reuseIdentifier = "EmojiesAndColorsSectionHeader"
    
    // MARK: - Public Properties
    let titleLabel = UILabel()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "123"
        titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = .ypBlack
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

