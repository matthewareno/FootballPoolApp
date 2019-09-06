//
//  ThirdViewController.swift
//  FootballPool
//
//  Created by Matthew Areno on 6/11/19.
//  Copyright © 2019 Matthew Areno. All rights reserved.
//

import UIKit

//**********************************************************************************
// Structure definition for converting website JSON objects into struct objects
//**********************************************************************************

/* JSON Structure for WeeklyStandings

{
	"standings": [
		{
			"gameWeek": Int,
			"players": [
				{
					"firstName": String,
					"lastName": String,
					"points": Int
				},
				...
			]
		},
		...
	]
}

*/
struct WeeklyStandings : Decodable {
	private enum CodingKeys: String, CodingKey {
		case weeklyStandings
	}
	struct WeeklyResults : Decodable {
		private enum CodingKeys: String, CodingKey {
			case gameWeek
			case players
		}
		
		struct WeeklyPlayer : Decodable {
			private enum CodingKeys: String, CodingKey {
				case firstName
				case lastName
				case points
			}
			
			let firstName: String
			let lastName: String
			let points: Int
			
			init() {
				firstName = ""
				lastName = ""
				points = -1
			}
			
			init(from decoder: Decoder) throws {
				let container = try decoder.container(keyedBy: CodingKeys.self)
				firstName = try container.decode(String.self, forKey: .firstName)
				lastName = try container.decode(String.self, forKey: .lastName)
				points = try container.decode(Int.self, forKey: .points)
			}
		}
		
		let gameWeek: Int
		let players: [WeeklyPlayer]
		
		init() {
			gameWeek = -1
			players = [WeeklyPlayer]()
		}
		
		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			gameWeek = try container.decode(Int.self, forKey: .gameWeek)
			players = try container.decode([WeeklyPlayer].self, forKey: .players)
		}
	}
	
	let results: [WeeklyResults]
	
	init() {
		results = [WeeklyResults]()
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		results = try container.decode([WeeklyResults].self, forKey: .weeklyStandings)
	}
}

class StandingsTableViewCell: UITableViewCell {
	@IBOutlet weak var userName: UILabel!
	@IBOutlet weak var userScore: UILabel!
}

class StandingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,
	UITableViewDelegate, UITableViewDataSource
{
	@IBOutlet weak var WeekPicker: UIPickerView!
	@IBOutlet weak var standingsView: UITableView!
	@IBOutlet weak var webActivityIndicator: UIActivityIndicatorView!
	
	var pickerData: [String] = [String]()
	var currentWeek: Int = 1
	var standings: WeeklyStandings = WeeklyStandings()
	
	@objc func refresh()
	{
		getWeeklyStandings()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		self.WeekPicker.delegate = self
		self.WeekPicker.dataSource = self
		self.standingsView.delegate = self
		self.standingsView.dataSource = self
		
		self.webActivityIndicator.hidesWhenStopped = true
		
		// Connect Picker Data
		pickerData = ["Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6", "Week 7", "Week 8", "Week 9", "Week 10",
					  "Week 11", "Week 12", "Week 13", "Week 14", "Week 15", "Week 16", "Bowls"]
		
		getWeeklyStandings()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	func getWeeklyStandings() {
		if client.loggedIntoWebsite != true
		{
			self.displayErrorMessager(errorTitle: "Not logged in", errorMessage: "You must be logged into the website before you can access the standings.")
			return
		}
		else
		{
			requestWeeklyStandings(webpage: "standings.php", week: currentWeek)
			self.standingsView.reloadData()
		}
	}
	
	func requestWeeklyStandings(webpage: String, week: Int) {
		let getParameters: [String: Any] = [
			"gameWeek": week
		]
		
		client.getWebPage(webpage: webpage, getParameters: getParameters, activityIndicator: webActivityIndicator) { returnValue in
			do {
				if returnValue != "" {
					let jsonData = returnValue.data(using: .utf8)!
					self.standings = try JSONDecoder().decode(WeeklyStandings.self, from: jsonData)
				}
			} catch {
				print("JSONDecoder error: ", error)
			}
		}
	}
	
	func displayErrorMessager(errorTitle: String, errorMessage: String) {
		let alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
		let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in return }
		alertController.addAction(OKAction)
		present(alertController, animated: true)
	}
	
	// Number of columns of data
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	// Number of rows of data
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pickerData.count
	}

	// The data to return for the row and component (column) that's being passed in
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return pickerData[row]
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		// This method is triggered whenever the user make a change to the picker selection.
		// The parameter named row and component represents what was selected.

		currentWeek = row + 1
		getWeeklyStandings()
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return standings.results.count
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return String(format: "Week %i Results", standings.results[0].gameWeek)
		}
		else {
			return "Overall Results"
		}
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return standings.results[section].players.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "UserStandingCell", for: indexPath) as! StandingsTableViewCell
		
		cell.userName?.text = String(format: "%@ %@", standings.results[indexPath.section].players[indexPath.row].firstName, standings.results[indexPath.section].players[indexPath.row].lastName)
		cell.userScore?.text = String(format: "%i", standings.results[indexPath.section].players[indexPath.row].points)
	
		return cell;
	}
}
