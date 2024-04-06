//
//  TrackersSectionHeader.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 06.03.2024.
//

import UIKit

class TrackersSectionHeader: UICollectionReusableView {
    
    // MARK: - UI Properties
    private let titleLabel = UILabel()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "123"
        titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(with section: TrackerCategory) {
        titleLabel.text = section.title
    }
}
