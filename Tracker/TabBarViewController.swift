//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 10.02.2024.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTabs()
    }
    
    private func configureTabs() {
        let vc1 = UINavigationController(rootViewController: TrackersViewController())
        //let vc1 = TrackersViewController()
        let vc2 = StatisticsViewController()
        
        // Set Tab Images
        vc1.tabBarItem.image = UIImage(named: "Trackers Tab Icon")
        vc2.tabBarItem.image = UIImage(named: "Statistics Tab Icon")
        
        // Set Titles
        vc1.tabBarItem.title = "Трекеры"
        vc2.tabBarItem.title = "Статистика"
        
//        let tab1 = UINavigationController(rootViewController: vc1)
//        let tab2 = UINavigationController(rootViewController: vc2)
        
        tabBar.tintColor = UIColor.ypBlue
        tabBar.backgroundColor = UIColor.ypWhite
        
        setViewControllers([vc1, vc2], animated: true)
    }
    
    
}