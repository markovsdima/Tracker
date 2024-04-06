//
//  TrackersCollectionViewCell.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 03.03.2024.
//

import UIKit

protocol TrackersCollectionViewCellDelegate: AnyObject {
    func changeTrackerCompletionState(tracker: Tracker)
}

class TrackersCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    weak var delegate: TrackersCollectionViewCellDelegate?
    
    // MARK: - Private Properties
    private var trackerColor: UIColor = .ypGray
    private var trackerId: UUID?
    private var trackerCompletion: Bool?
    private var trackerCompletedDaysCount: Int = 0
    private var isFuture: Bool?
    private var trackerType: TrackerTypes?
    private var tracker: Tracker?
    
    // MARK: - UI Properties
    private lazy var cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypGreen
        
        return view
    }()
    
    private lazy var emojiView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.3)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "❤️"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .ypWhite
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var taskCompletedButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .ypWhite
        button.backgroundColor = .ypGreen
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(taskCompletedButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(cardView)
        contentView.addSubview(taskCompletedButton)
        contentView.addSubview(daysCountLabel)
        cardView.addSubview(emojiView)
        cardView.addSubview(titleLabel)
        emojiView.addSubview(emojiLabel)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func configure(with tracker: Tracker, completion: Bool, count: Int, isFuture: Bool) {
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        cardView.backgroundColor = tracker.color
        taskCompletedButton.backgroundColor = tracker.color
        self.tracker = tracker
        self.trackerColor = tracker.color
        self.trackerId = tracker.id
        self.trackerType = tracker.trackerType
        self.trackerCompletion = completion
        self.trackerCompletedDaysCount = count
        self.isFuture = isFuture
        self.daysCountLabel.text = generateDaysCountLabelText(with: trackerCompletedDaysCount)
        if isFuture {
            taskCompletedButton.setImage(UIImage(systemName: "plus"), for: .normal)
            taskCompletedButton.backgroundColor = trackerColor.withAlphaComponent(0.3)
        } else if completion == true {
            taskCompletedButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            taskCompletedButton.backgroundColor = trackerColor.withAlphaComponent(0.3)
        } else {
            taskCompletedButton.setImage(UIImage(systemName: "plus"), for: .normal)
            taskCompletedButton.backgroundColor = trackerColor
        }
    }
    
    // MARK: - Private methods
    private func generateDaysCountLabelText(with count: Int) -> String {
        if count%10 == 1 && count != 11 {
            return "\(count) день"
        } else if count > 10 && count < 15 {
            return "\(count) дней"
        } else if count%10 > 0 && count%10 < 5 && count != 11 {
            return "\(count) дня"
        } else {
            return "\(count) дней"
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            emojiView.widthAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor),
            
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.heightAnchor.constraint(equalToConstant: 34),
            
            daysCountLabel.centerYAnchor.constraint(equalTo: taskCompletedButton.centerYAnchor),
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            taskCompletedButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            taskCompletedButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            taskCompletedButton.heightAnchor.constraint(equalToConstant: 34),
            taskCompletedButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    @objc private func taskCompletedButtonDidTap() {
        guard let tracker else { return }
        
        if isFuture == true { return }
        
        if trackerCompletion == true {
            taskCompletedButton.setImage(UIImage(systemName: "plus"), for: .normal)
            taskCompletedButton.backgroundColor = trackerColor
            trackerCompletion?.toggle()
            trackerCompletedDaysCount -= 1
            daysCountLabel.text = generateDaysCountLabelText(with: trackerCompletedDaysCount)
        } else {
            taskCompletedButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            taskCompletedButton.backgroundColor = trackerColor.withAlphaComponent(0.3)
            trackerCompletion?.toggle()
            trackerCompletedDaysCount += 1
            daysCountLabel.text = generateDaysCountLabelText(with: trackerCompletedDaysCount)
        }
        
        delegate?.changeTrackerCompletionState(tracker: tracker)
    }
}
