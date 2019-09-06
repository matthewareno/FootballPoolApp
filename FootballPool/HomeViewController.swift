//
//  HomeViewController.swift
//  FootballPool
//
//  Created by Matthew Areno on 7/5/19.
//  Copyright © 2019 Matthew Areno. All rights reserved.
//

import UIKit

/*
JSON Structure

{
	"firstName" : String,
	"lastName" : String,
	"currentWeek" : Int,
	"weeklyPoints" : Int,
	"weeklyRank" : Int,
}
*/

struct UserHome : Decodable {
	private enum CodingKeys: String, CodingKey {
		case firstName
		case lastName
		case currentWeek
		case weeklyPoints
		case weeklyRank
	}
	
	let firstName : String
	let lastName : String
	let currentWeek : Int
	let weeklyPoints : Int
	let weeklyRank : Int
	
	init() {
		firstName = ""
		lastName = ""
		currentWeek = 0
		weeklyPoints = 0
		weeklyRank = 0
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		firstName = try container.decode(String.self, forKey: .firstName)
		lastName = try container.decode(String.self, forKey: .lastName)
		currentWeek = try container.decode(Int.self, forKey: .currentWeek)
		weeklyPoints = try container.decode(Int.self, forKey: .weeklyPoints)
		weeklyRank = try container.decode(Int.self, forKey: .weeklyRank)
	}
}

class HomeViewController: UIViewController {
	@IBOutlet weak var homeMessage: UILabel!
//	@IBOutlet weak var webActivityIndicator: UIActivityIndicatorView!
	var userHomeData : UserHome = UserHome()
	
	@IBAction func logoutButton(_ sender: Any) {
		client.logoutOfWebsite(activityIndicator: nil) { returnValue in
			if returnValue == -1
			{
				self.displayErrorMessage(errorTitle: "Logout failed", errorMessage: "Unable to logout of football pool website.")
				return
			}
			return
		}
	}
	
	func displayErrorMessage(errorTitle: String, errorMessage: String) {
		let alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
		let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in return }
		alertController.addAction(OKAction)
		present(alertController, animated: true)
	}
	
	@objc func refresh() {
		self.GetUserPage()
		self.GetUserPage()
		self.homeMessage.text = String(format:
			"Welcome %@ %@.\r\nThe current game week is %i.\r\nLast week you scored %i points, which ranked #%i in the pool",
									   self.userHomeData.firstName,
									   self.userHomeData.lastName,
									   self.userHomeData.currentWeek,
									   self.userHomeData.weeklyPoints,
									   self.userHomeData.weeklyRank )
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

//		self.webActivityIndicator.hidesWhenStopped = true
//		self.webActivityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
		self.refresh()
    }
    
	func GetUserPage() {
		if client.loggedIntoWebsite != true
		{
			self.displayErrorMessage(errorTitle: "Not logged in", errorMessage: "You must be logged into the website before you can access the standings.")
			return
		}
		else
		{
			let getParameters: [String: Any] = [:]
			
			client.getWebPage(webpage: "private.php", getParameters: getParameters, activityIndicator: nil) { returnValue in
				do {
					if returnValue != "" {
						let jsonData = returnValue.data(using: .utf8)!
						self.userHomeData = try JSONDecoder().decode(UserHome.self, from: jsonData)
					}
				} catch {
					print("JSONDecoder error: ", error)
				}
			}
		}
	}
}
