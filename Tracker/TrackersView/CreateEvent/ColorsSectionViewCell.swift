//
//  ColorsSectionViewCell.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 02.04.2024.
//

import UIKit

final class ColorsSectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorsSectionViewCell"
    
    // MARK: - UI Properties
    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.text = "❤️"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var colorBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 13
        view.layer.borderWidth = 3
        view.layer.borderColor = CGColor(gray: 1, alpha: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var color: UIColor?
    
    // MARK: - Override
    override var isSelected: Bool {
        didSet {
            if isSelected {
                colorBackgroundView.layer.borderColor = color?.withAlphaComponent(0.4).cgColor
            } else {
                self.colorBackgroundView.layer.borderColor = CGColor.init(gray: 1, alpha: 0)
            }
        }
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(colorBackgroundView)
        colorBackgroundView.addSubview(colorView)
        contentView.layer.cornerRadius = 8
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func configure(with color: UIColor) {
        self.color = color
        colorView.backgroundColor = color
    }
    
    // MARK: - Private methods
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            colorBackgroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorBackgroundView.heightAnchor.constraint(equalToConstant: 52),
            colorBackgroundView.widthAnchor.constraint(equalToConstant: 52),
            
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
}
