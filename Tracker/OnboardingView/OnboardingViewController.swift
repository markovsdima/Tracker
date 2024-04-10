//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 06.04.2024.
//

import UIKit

class OnboardingViewController: UIPageViewController {
    
    // MARK: - Private Properties
    private lazy var pages = [OnboardingHelper]()
    private let firstPageImage: UIImage = .Onboarding.firstPage
    private let secondPageImage: UIImage = .Onboarding.secondPage
    private var pagesViewControllers = [OnboardingPageViewController]()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pagesViewControllers.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypBlack.withAlphaComponent(0.3)
        pageControl.isEnabled = false
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        return pageControl
    }()
    
    private lazy var startUsingAppButton: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = .ypBlack
        button.addTarget(self, action: #selector(startUsingAppButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstPage = OnboardingHelper(backgroundImage: firstPageImage, titleText: "Отслеживайте только \n то, что хотите")
        let secondPage = OnboardingHelper(backgroundImage: secondPageImage, titleText: "Даже если это \n не литры воды и йога")
        pages.append(firstPage)
        pages.append(secondPage)
        print(pagesViewControllers)
        
        for page in pages {
            pagesViewControllers.append(OnboardingPageViewController(helper: page))
        }
        
        setViewControllers([pagesViewControllers[0]], direction: .forward, animated: true)
        
        configureUI()
    }
    
    // MARK: Initializers
    override init(
        transitionStyle style: UIPageViewController.TransitionStyle,
        navigationOrientation: UIPageViewController.NavigationOrientation,
        options: [UIPageViewController.OptionsKey : Any]? = nil
    ) {
        super.init(transitionStyle: .scroll, navigationOrientation: navigationOrientation)
        dataSource = self
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        view.addSubview(pageControl)
        view.addSubview(startUsingAppButton)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: startUsingAppButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 6),
            
            startUsingAppButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            startUsingAppButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startUsingAppButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startUsingAppButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid configuration") }
        
        let tabBarController = TabBarViewController()
        window.rootViewController = tabBarController
        UserDefaults.standard.set(true, forKey: "firstLaunchTookPlace")
    }
    
    @objc private func startUsingAppButtonDidTap() {
        switchToTabBarController()
    }
}

// MARK: - UIPageViewControllerDataSource & Delegate
extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // viewControllerBefore
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewController = viewController as? OnboardingPageViewController else { return nil }
        
        guard let viewControllerIndex = pagesViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return pagesViewControllers.last
        }
        
        return pagesViewControllers[previousIndex]
    }
    
    // viewControllerAfter
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewController = viewController as? OnboardingPageViewController else { return nil }
        
        guard let viewControllerIndex = pagesViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pagesViewControllers.count else {
            return pagesViewControllers.first
        }
        
        return pagesViewControllers[nextIndex]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool) {
        if
            let currentViewController = pageViewController.viewControllers?.first,
            let currentIndex = pagesViewControllers.firstIndex(
                of: currentViewController as? OnboardingPageViewController ?? OnboardingPageViewController(helper: OnboardingHelper())
        ) {
            pageControl.currentPage = currentIndex
        }
    }
    
}
