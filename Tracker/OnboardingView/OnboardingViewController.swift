//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 06.04.2024.
//

import UIKit

class OnboardingViewController: UIPageViewController {
    
    // MARK: - Private Properties
    private var pages = [OnboardingHelper]()
    private let firstPageImage: UIImage = .Onboarding.firstPage
    private let secondPageImage: UIImage = .Onboarding.secondPage
    
    private lazy var arrayPageViewController: [OnboardingPageViewController] = {
        var array = [OnboardingPageViewController]()
        for page in pages {
            array.append(OnboardingPageViewController(helper: page))
        }
        
        return array
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstPage = OnboardingHelper(backgroundImage: firstPageImage, titleText: "Отслеживайте только \n то, что хотите")
        let secondPage = OnboardingHelper(backgroundImage: secondPageImage, titleText: "Даже если это \n не литры воды и йога")
        pages.append(firstPage)
        pages.append(secondPage)
    }
    
    // MARK: Initializers
    override init(
        transitionStyle style: UIPageViewController.TransitionStyle,
        navigationOrientation: UIPageViewController.NavigationOrientation,
        options: [UIPageViewController.OptionsKey : Any]? = nil
    ) {
        super.init(transitionStyle: .scroll, navigationOrientation: navigationOrientation)
        setViewControllers([arrayPageViewController[0]], direction: .forward, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
