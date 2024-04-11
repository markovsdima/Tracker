//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 10.02.2024.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    // MARK: - UI Properties
    private lazy var statisticsLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var statisticsCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var cardBigLabel: UILabel = {
        let label = UILabel()
        label.text = "?"
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var cardTitle: UILabel = {
        let label = UILabel()
        label.text = "Трекеров завершено"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var noDataImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.noData
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // MARK: - Private Properties
    private let trackerRecordStore = TrackerRecordStore.shared
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let trackersFinished = getNumberOfTrackerRecords()
        emptyCheck(trackersFinished: trackersFinished)
        
        cardBigLabel.text = String(trackersFinished)
        addGradientBorderTo(view: statisticsCard)
    }
    
    // MARK: - Private Methods
    private func configureUI() {
        view.addSubview(statisticsLabel)
        view.addSubview(statisticsCard)
        statisticsCard.addSubview(cardBigLabel)
        statisticsCard.addSubview(cardTitle)
        
        view.addSubview(noDataImageView)
        view.addSubview(noDataLabel)
        
        noDataImageView.layer.zPosition = 10
        noDataLabel.layer.zPosition = 10
        
        NSLayoutConstraint.activate([
            statisticsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statisticsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            
            statisticsCard.topAnchor.constraint(equalTo: statisticsLabel.bottomAnchor, constant: 77),
            statisticsCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticsCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statisticsCard.heightAnchor.constraint(equalToConstant: 90),
            
            cardBigLabel.leadingAnchor.constraint(equalTo: statisticsCard.leadingAnchor, constant: 12),
            cardBigLabel.topAnchor.constraint(equalTo: statisticsCard.topAnchor, constant: 12),
            
            cardTitle.leadingAnchor.constraint(equalTo: statisticsCard.leadingAnchor, constant: 12),
            cardTitle.bottomAnchor.constraint(equalTo: statisticsCard.bottomAnchor, constant: -12),
            
            noDataImageView.widthAnchor.constraint(equalToConstant: 80),
            noDataImageView.heightAnchor.constraint(equalToConstant: 80),
            noDataImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            noDataImageView.topAnchor.constraint(equalTo: statisticsLabel.bottomAnchor, constant: 246),
            
            noDataLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            noDataLabel.topAnchor.constraint(equalTo: noDataImageView.bottomAnchor, constant: 8)
        ])
        
    }
    
    private func emptyCheck(trackersFinished: Int) {
        let isHidden: Bool = (trackersFinished > 0)
        noDataImageView.isHidden = isHidden
        noDataLabel.isHidden = isHidden
        statisticsCard.isHidden = !isHidden
    }
    
    private func addGradientBorderTo(view: UIView) {
        let gradient = CAGradientLayer()
        gradient.cornerRadius = 16
        gradient.frame = view.bounds
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.colors = [
            UIColor(hex: "#007BFA").cgColor,
            UIColor(hex: "#46E69D").cgColor,
            UIColor(hex: "#FD4C49").cgColor
        ]
        
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.path = UIBezierPath(roundedRect: view.bounds, cornerRadius: 16).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    private func getNumberOfTrackerRecords() -> Int {
        do {
            return try trackerRecordStore.getTrackerRecordCount()
        } catch {
            print("Error fetching tracker record count: \(error)")
            return 0
        }
    }
    
    
}
