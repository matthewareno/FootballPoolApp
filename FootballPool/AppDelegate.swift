//
//  AppDelegate.swift
//  FootballPool
//
//  Created by Matthew Areno on 6/10/19.
//  Copyright © 2019 Matthew Areno. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		UIApplication.shared.setMinimumBackgroundFetchInterval(300)	// Run every 5 minutes
		
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		if (UIApplication.shared.backgroundRefreshStatus != .available) {
			client.logoutOfWebsite()
		}
		return
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Definitely close the connection
		client.logoutOfWebsite()
		return
	}

	func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		if let tabBarController = window?.rootViewController as? UITabBarController {
			switch(tabBarController.selectedIndex)
			{
			case 0:
				tabBarController.selectedViewController!.method(for: #selector(HomeViewController.refresh))
				break;
			case 1:
				tabBarController.selectedViewController!.method(for: #selector(PicksViewController.refresh))
				break;
			case 2:
				tabBarController.selectedViewController!.method(for: #selector(StandingsViewController.refresh))
				break;
			case 3:
				tabBarController.selectedViewController!.method(for: #selector(ScoresViewController.refresh))
				break;
			default:
				break;
			}
		}
	}
}

