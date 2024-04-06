//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 20.03.2024.
//

import UIKit

protocol ScheduleTableViewCellDelegate: AnyObject {
    func switchChanged(for day: WeekDay, enabled: Bool)
}

final class ScheduleTableViewCell: UITableViewCell {
    
    // MARK: - Public Properties
    static let reuseIdentifier = "ScheduleTableViewCell"
    
    private var weekDay: WeekDay?
    
    weak var delegate: ScheduleTableViewCellDelegate?
    
    // MARK: - UI Properties
    private lazy var cellTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var switchButton: UISwitch = {
        let switchButton = UISwitch()
        switchButton.onTintColor = .ypBlue
        switchButton.addTarget(self, action: #selector(didTapSwitchButton), for: .valueChanged)
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        
        return switchButton
    }()
    
    // MARK: - Override Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(title: String, backgroundColor: UIColor, weekDay: WeekDay?) {
        cellTitle.text = title
        self.backgroundColor = backgroundColor
        self.weekDay = weekDay
    }
    
    // MARK: - Private Methods
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
    
    @objc private func didTapSwitchButton(sender: UISwitch) {
        guard let weekDay else { return }
        delegate?.switchChanged(for: weekDay, enabled: sender.isOn)
    }
    
    
}
