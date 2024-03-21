//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 20.03.2024.
//

import UIKit

final class ScheduleTableViewCell: UITableViewCell {
    
    // MARK: - UI Properties
    lazy var cellTitle: UILabel = {
        let label = UILabel()
        //label.text = "День недели"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var switchButton: UISwitch = {
        let switchButton = UISwitch()
        switchButton.onTintColor = .ypBlue
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        
        return switchButton
    }()
    
    // MARK: - Public Properties
    static let reuseIdentifier = "ScheduleTableViewCell"
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
        contentView.addSubview(switchButton)
        
        NSLayoutConstraint.activate([
            cellTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
