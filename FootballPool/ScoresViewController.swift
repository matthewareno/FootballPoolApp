//
//  SecondViewController.swift
//  FootballPool
//
//  Created by Matthew Areno on 6/10/19.
//  Copyright © 2019 Matthew Areno. All rights reserved.
//

import UIKit

//**********************************************************************************
// Structure definition for converting website JSON objects into struct objects
//**********************************************************************************

/*
JSON Structure

{
	"gameWeek" : Int,
	"gameInfo" : [
	{
		"visitor" :
		{
			"team" :
			{
				"id" : Int,
				"name" : String,
				"score" : Int,
				"icon" : String,
				"rank" : Int
			}
		},
		"home" :
		{
			"team" :
			{
				"id" : Int,
				"name" : String,
				"score" : Int,
				"icon" : String,
				"rank" : Int
			}
		},
		"status" : Int,
		"date" : String,
		"time" : String,
	},
	...
	]
}

*/

struct WeeklyScores : Decodable {
	private enum CodingKeys: String, CodingKey {
		case gameWeek
		case gameInfo
	}
		
	struct GameInfo : Decodable {
		private enum CodingKeys: String, CodingKey {
			case visitor
			case home
			case status
			case date
			case time
		}
		
		struct Team : Decodable {
			private enum CodingKeys: String, CodingKey {
				case team
			}
			
			struct TeamInfo: Decodable {
				private enum CodingKeys: String, CodingKey {
					case id
					case name
					case score
					case icon
					case rank
				}
				
				let id: Int
				let name: String
				let score: Int
				let icon: String
				let rank: Int
				
				init() {
					id = 0
					name = ""
					score = 0
					icon = ""
					rank = 0
				}
				
				init(from decoder: Decoder) throws {
					let container = try decoder.container(keyedBy: CodingKeys.self)
					id = try container.decode(Int.self, forKey: .id)
					name = try container.decode(String.self, forKey: .name)
					score = try container.decode(Int.self, forKey: .score)
					icon = try container.decode(String.self, forKey: .icon)
					rank = try container.decode(Int.self, forKey: .rank)
				}
			}
			
			let team: TeamInfo
			
			init() {
				team = TeamInfo()
			}
			
			init(from decoder: Decoder) throws {
				let container = try decoder.container(keyedBy: CodingKeys.self)
				team = try container.decode(TeamInfo.self, forKey: .team)
			}
		}
		
		let visitor: Team
		let home: Team
		let status: Int
		let date: String
		let time: String
		
		init() {
			visitor = Team()
			home = Team()
			status = 0
			date = ""
			time = ""
		}
		
		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			visitor = try container.decode(Team.self, forKey: .visitor)
			home = try container.decode(Team.self, forKey: .home)
			status = try container.decode(Int.self, forKey: .status)
			date = try container.decode(String.self, forKey: .date)
			time = try container.decode(String.self, forKey: .time)
		}
	}
		
	let gameWeek: Int
	let gameInfo: [GameInfo]
		
	init() {
		gameWeek = -1
		gameInfo = [GameInfo]()
	}
		
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		gameWeek = try container.decode(Int.self, forKey: .gameWeek)
		gameInfo = try container.decode([GameInfo].self, forKey: .gameInfo)
	}
}

class FootballPickCell: UITableViewCell {
	@IBOutlet weak var visitorIcon: UIImageView!
	@IBOutlet weak var visitorName: UILabel!
	@IBOutlet weak var visitorScore: UILabel!
	@IBOutlet weak var homeIcon: UIImageView!
	@IBOutlet weak var homeName: UILabel!
	@IBOutlet weak var homeScore: UILabel!	
}

class ScoresViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,
	UITableViewDelegate, UITableViewDataSource
{
	@IBOutlet weak var PicksViewer: UITableView!
	@IBOutlet weak var WeekPicker: UIPickerView!
	@IBOutlet weak var webActivityIndicator: UIActivityIndicatorView!
	
	var pickerData : [String] = [String]()
	var weeklyScores : WeeklyScores = WeeklyScores()
	var currentWeek : Int = 1

	@objc func refresh() {
		GetWeeklyScores()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
		// Connect Picker Data
		self.WeekPicker.delegate = self
		self.WeekPicker.dataSource = self
		
		self.PicksViewer.delegate = self
		self.PicksViewer.dataSource = self
		self.webActivityIndicator.hidesWhenStopped = true
		self.webActivityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
		
		pickerData = ["Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6", "Week 7", "Week 8", "Week 9", "Week 10",
					  "Week 11", "Week 12", "Week 13", "Week 14", "Week 15", "Week 16", "Bowls"]
		
		GetWeeklyScores()
		PicksViewer.reloadData()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	func GetWeeklyScores() {
		if client.loggedIntoWebsite != true
		{
			self.displayErrorMessage(errorTitle: "Not logged in", errorMessage: "You must be logged into the website before you can access the standings.")
			return
		}
		else
		{
			//			webActivityIndicator.startAnimating()
			requestWeeklyScores(webpage: "scores.php", week: currentWeek)
			//			self.webActivityIndicator.stopAnimating()
			self.PicksViewer.reloadData()
		}
	}
	
	func requestWeeklyScores(webpage: String, week: Int) {
		let getParameters: [String: Any] = [
			"gameWeek": week
		]
		
		client.getWebPage(webpage: webpage, getParameters: getParameters, activityIndicator: webActivityIndicator) { returnValue in
			do {
				if returnValue != "" {
					let jsonData = returnValue.data(using: .utf8)!
					self.weeklyScores = try JSONDecoder().decode(WeeklyScores.self, from: jsonData)
				}
			} catch {
				print("JSONDecoder error: ", error)
			}
		}
	}
	
	func displayErrorMessage(errorTitle: String, errorMessage: String) {
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
		return pickerData.count;
	}
	
	// The data to return for the row and component (column) that's being passed in
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return pickerData[row]
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		// This method is triggered whenever the user make a change to the picker selection.
		// The parameter named row and component represents what was selected.
		currentWeek = row + 1
		GetWeeklyScores()
		PicksViewer.reloadData()
	}
	
	// Table View functions
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return weeklyScores.gameInfo.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		//		let tableViewCell: UITableViewCell = UITableViewCell()
		let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! FootballPickCell
		
		if(indexPath.row >= weeklyScores.gameInfo.count) {
			return cell
		}

		let gameInfo = weeklyScores.gameInfo[indexPath.row]
		
		cell.visitorIcon?.image = UIImage(named: gameInfo.visitor.team.icon)
		if(gameInfo.visitor.team.rank != 0) {
			cell.visitorName?.text = String(format: "#%i %@", gameInfo.visitor.team.rank, gameInfo.visitor.team.name)
		} else {
			cell.visitorName?.text = gameInfo.visitor.team.name
		}
		cell.visitorScore?.text = String(format: "%i", gameInfo.visitor.team.score)
		cell.homeIcon?.image = UIImage(named: gameInfo.home.team.icon)
		if(gameInfo.home.team.rank != 0) {
			cell.homeName?.text = String(format: "#%i %@", gameInfo.home.team.rank, gameInfo.home.team.name)
		} else {
			cell.homeName?.text = gameInfo.home.team.name
		}
		cell.homeScore?.text = String(format: "%i", gameInfo.home.team.score)
		
//		print("Cell width: \(cell.visitorIcon.bounds.width), height: \(cell.visitorIcon.bounds.height)")
		
		return cell
	}
}


