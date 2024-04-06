//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 07.03.2024.
//

import UIKit

final class CreateTrackerViewController: UIViewController {
    
    // MARK: - UI Properties
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var regularEvent: UIButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.backgroundColor = .ypBlack
        button.tintColor = .ypWhite
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapRegularEvent), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var oneTimeEvent: UIButton = {
        let button = UIButton()
        button.setTitle("Нерегулярное событие", for: .normal)
        button.backgroundColor = .ypBlack
        button.tintColor = .ypWhite
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapOneTimeEvent), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        configureUI()
    }
    
    // MARK: - Private Methods
    private func configureUI() {
        view.addSubview(titleLabel)
        view.addSubview(regularEvent)
        view.addSubview(oneTimeEvent)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            regularEvent.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 295),
            regularEvent.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            regularEvent.heightAnchor.constraint(equalToConstant: 60),
            regularEvent.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            regularEvent.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            oneTimeEvent.topAnchor.constraint(equalTo: regularEvent.bottomAnchor, constant: 16),
            oneTimeEvent.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            oneTimeEvent.heightAnchor.constraint(equalToConstant: 60),
            oneTimeEvent.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            oneTimeEvent.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func didTapRegularEvent() {
        let view = CreateEventViewController(eventType: .regularEvent)
        view.delegate = self
//        view.willDismiss = {
//            self.view.isHidden = true
//        }
        view.didDismiss = {
            self.dismiss(animated: false)
        }
        
        present(view, animated: true)
    }
    
    @objc private func didTapOneTimeEvent() {
        let view = CreateEventViewController(eventType: .oneTimeEvent)
        view.delegate = self
        view.willDismiss = {
            self.view.isHidden = true
        }
        view.didDismiss = {
            self.dismiss(animated: false)
        }
        
        present(view, animated: true)
    }
    
}

// MARK: - CreateEventViewControllerDelegate
extension CreateTrackerViewController: CreateEventViewControllerDelegate {
    func dismissAnimated() {
        dismiss(animated: true)
    }
}
