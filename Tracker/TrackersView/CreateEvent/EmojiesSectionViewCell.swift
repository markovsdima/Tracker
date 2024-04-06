//
//  EmojiesSectionViewCell.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 02.04.2024.
//

import UIKit

final class EmojiesSectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiesSectionViewCell"
    
    // MARK: - UI Properties
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "❤️"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // MARK: - Override
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.contentView.backgroundColor = UIColor(hex: "#E6E8EB")
            } else {
                self.contentView.backgroundColor = .init(white: 1, alpha: 0)
            }
        }
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(emojiLabel)
        contentView.layer.cornerRadius = 16
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func configure(with emoji: String) {
        emojiLabel.text = emoji
    }
    
    // MARK: - Private methods
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
