//
//  ViewController.swift
//  Netflix
//
//  Created by Ios Developer on 7.11.2022.
//

import UIKit

class MainTabBarViewController: UITabBarController{

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        let vc1 = UINavigationController(rootViewController: HomeViewController())
        let vc2 = UINavigationController(rootViewController: UpcomingViewController())
        let vc3 = UINavigationController(rootViewController: SearchViewController())
        let vc4 = UINavigationController(rootViewController: DownloadsViewController())
        
        vc1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        vc2.tabBarItem = UITabBarItem(title: "Coming Soon", image: UIImage(systemName: "play.circle"), tag: 1)
        vc3.tabBarItem = UITabBarItem(title: "Top  Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        vc4.tabBarItem = UITabBarItem(title: "Downloads", image: UIImage(systemName: "arrow.down.to.line"), tag: 1)
    
        tabBar.tintColor = .label

        setViewControllers([vc1,vc2,vc3,vc4], animated: true)
      
        
        
        
    }


}

