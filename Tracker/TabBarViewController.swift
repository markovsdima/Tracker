//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 10.02.2024.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTabs()
        
        
    }
    
    // MARK: - Private Methods
    private func configureTabs() {
        let trackersViewController = UINavigationController(rootViewController: TrackersViewController())
        let statisticsViewController = StatisticsViewController()
        
        // Set Tab Images
        trackersViewController.tabBarItem.image = UIImage(named: "Trackers Tab Icon")
        statisticsViewController.tabBarItem.image = UIImage(named: "Statistics Tab Icon")
        
        // Set Titles
        trackersViewController.tabBarItem.title = "Трекеры"
        statisticsViewController.tabBarItem.title = "Статистика"
        
        tabBar.tintColor = UIColor.ypBlue
        tabBar.backgroundColor = UIColor.ypWhite
        
        setViewControllers([trackersViewController, statisticsViewController], animated: true)
    }
}
