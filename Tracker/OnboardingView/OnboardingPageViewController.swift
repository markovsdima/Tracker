//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 06.04.2024.
//

import UIKit

class OnboardingPageViewController: UIViewController {
    
    // MARK: - UI Properties
    private lazy var backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var startUsingAppButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = .ypBlack
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var subView: [UIView] = [self.backgroundImage, self.titleLabel, self.startUsingAppButton]
    
    // MARK: - Init
    init(helper: OnboardingHelper) {
        super.init(nibName: nil, bundle: nil)
        //edgesForExtendedLayout = []
        backgroundImage.image = helper.backgroundImage
        titleLabel.text = helper.titleText
        //startUsingAppButton = helper.startUsingAppButton
        
        for view in subView { self.view.addSubview(view) }
        
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 432),
            titleLabel.leftAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
//            startUsingAppButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 50),
//            startUsingAppButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            startUsingAppButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20),
//            startUsingAppButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
