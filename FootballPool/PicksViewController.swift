//
//  PicksTableTableViewController.swift
//  FootballPool
//
//  Created by Matthew Areno on 6/14/19.
//  Copyright © 2019 Matthew Areno. All rights reserved.
//

import UIKit

//**********************************************************************************
// Structure definition for converting website JSON objects into struct objects
//**********************************************************************************

/*
JSON Structure for submitted picks

{
	"weeklyPicks":
	{
		"gamePicks" : [
		{
			"gameId" : Int,
			"userPick" : Int
		}
		]
	}
}

*/

struct SubmittedPicks : Encodable {
	private enum CodingKeys: String, CodingKey {
		case weeklyPicks
	}
	
	struct GamePicks : Encodable {
		private enum CodingKeys: String, CodingKey {
			case gameId
			case userPick
		}
		
		var gameId: Int
		var userPick: Int
		
		init() {
			gameId = 0
			userPick = 0
		}
		
		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encode(gameId, forKey: .gameId)
			try container.encode(userPick, forKey: .userPick)
		}
	}
	
	var picks: [GamePicks]
	
	init() {
		picks = [GamePicks]()
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(picks, forKey: .weeklyPicks)
	}
		
	
}

/*
JSON Structure

{
	"weeklyPicks" :
	{
		"player" :
		{
			"firstName" : String,
			"lastName" : String
		},
		"gameWeek" : Int,
		"standardPicks" :
		{
			"gamePicks" : [
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
				"winnerId" : Int,
				"userPick" : Int
			},
			...
			]
		},
		"gotwPicks" :
		{
			"gamePicks" : [
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
				"winnerId" : Int,
				"userPick" : Int
			},
			...
			]
		},
		"upsetPicks" :
		{
			"gamePicks" : [
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
						"icon" : String
						"rank" : Int
					}
				},
				"status" : Int,
				"date" : String,
				"time" : String,
				"winnerId" : Int,
				"userPick" : Int
				}
			},
			...
			]
		}
	}
}

*/

struct WeeklyPicks : Codable {
	private enum CodingKeys: String, CodingKey {
		case weeklyPicks
	}
	
	struct WeeklyEntry: Codable {
		private enum CodingKeys: String, CodingKey {
			case player
			case gameWeek
			case standardPicks
			case gotwPicks
			case upsetPicks
		}
		
		struct Player : Codable {
			private enum CodingKeys: String, CodingKey {
				case firstName
				case lastName
			}
			
			var firstName: String
			var lastName: String
			
			init() {
				firstName = ""
				lastName = ""
			}
			
			init(from decoder: Decoder) throws {
				let container = try decoder.container(keyedBy: CodingKeys.self)
				firstName = try container.decode(String.self, forKey: .firstName)
				lastName = try container.decode(String.self, forKey: .lastName)
			}
			
			func encode(to encoder: Encoder) throws {
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode(firstName, forKey: .firstName)
				try container.encode(lastName, forKey: .lastName)
			}
		}
		
		struct GamePicks : Codable {
			private enum CodingKeys: String, CodingKey {
				case visitor
				case home
				case gameId
				case status
				case date
				case time
				case odds
				case winnerId
				case underdog
				case userPick
			}
			
			struct Team : Codable {
				private enum CodingKeys: String, CodingKey {
					case team
				}
					
				struct TeamInfo: Codable {
					private enum CodingKeys: String, CodingKey {
						case id
						case name
						case score
						case icon
						case rank
						case wins
						case loses
						case ties
					}
					
					var id: Int
					var name: String
					var score: Int
					var icon: String
					var rank: Int
					var wins: Int
					var loses: Int
					var ties: Int
						
					init() {
						id = 0
						name = ""
						score = 0
						icon = ""
						rank = 0
						wins = 0
						loses = 0
						ties = 0
					}
						
					init(from decoder: Decoder) throws {
						let container = try decoder.container(keyedBy: CodingKeys.self)
						id = try container.decode(Int.self, forKey: .id)
						name = try container.decode(String.self, forKey: .name)
						score = try container.decode(Int.self, forKey: .score)
						icon = try container.decode(String.self, forKey: .icon)
						rank = try container.decode(Int.self, forKey: .rank)
						wins = try container.decode(Int.self, forKey: .wins)
						loses = try container.decode(Int.self, forKey: .loses)
						ties = try container.decode(Int.self, forKey: .ties)
					}
					
					func encode(to encoder: Encoder) throws {
						var container = encoder.container(keyedBy: CodingKeys.self)
						try container.encode(id, forKey: .id)
						try container.encode(name, forKey: .name)
						try container.encode(score, forKey: .score)
						try container.encode(icon, forKey: .icon)
						try container.encode(rank, forKey: .rank)
						try container.encode(wins, forKey: .wins)
						try container.encode(loses, forKey: .loses)
						try container.encode(ties, forKey: .ties)
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
				
				func encode(to encoder: Encoder) throws {
					var container = encoder.container(keyedBy: CodingKeys.self)
					try container.encode(team, forKey: .team)
				}
			}
			
			let visitor: Team
			let home: Team
			let gameId: Int
			let status: Int
			let date: String
			let time: String
			let odds: String
			let winnerId: Int
			let underdog: Int
			var userPick: Int
			
			init() {
				visitor = Team()
				home = Team()
				gameId = 0
				status = 0
				date = ""
				time = ""
				odds = ""
				winnerId = 0
				underdog = 0
				userPick = 0
			}
				
			init(from decoder: Decoder) throws {
				let container = try decoder.container(keyedBy: CodingKeys.self)
				visitor = try container.decode(Team.self, forKey: .visitor)
				home = try container.decode(Team.self, forKey: .home)
				gameId = try container.decode(Int.self, forKey: .gameId)
				status = try container.decode(Int.self, forKey: .status)
				date = try container.decode(String.self, forKey: .date)
				time = try container.decode(String.self, forKey: .time)
				odds = try container.decode(String.self, forKey: .odds)
				winnerId = try container.decode(Int.self, forKey: .winnerId)
				underdog = try container.decode(Int.self, forKey: .underdog)
				userPick = try container.decode(Int.self, forKey: .userPick)
			}
			
			func encode(to encoder: Encoder) throws {
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode(visitor, forKey: .visitor)
				try container.encode(home, forKey: .home)
				try container.encode(gameId, forKey: .gameId)
				try container.encode(status, forKey: .status)
				try container.encode(date, forKey: .date)
				try container.encode(time, forKey: .time)
				try container.encode(odds, forKey: .odds)
				try container.encode(winnerId, forKey: .winnerId)
				try container.encode(underdog, forKey: .underdog)
				try container.encode(userPick, forKey: .userPick)
			}
		}
		
		var player: Player
		var gameWeek: Int
		var standardPicks: [GamePicks]
		var gotwPicks: [GamePicks]
		var upsetPicks: [GamePicks]
		
		init() {
			player = Player()
			gameWeek = -1
			standardPicks = [GamePicks]()
			gotwPicks = [GamePicks]()
			upsetPicks = [GamePicks]()
		}
		
		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			player = try container.decode(Player.self, forKey: .player)
			gameWeek = try container.decode(Int.self, forKey: .gameWeek)
			standardPicks = try container.decode([GamePicks].self, forKey: .standardPicks)
			gotwPicks = try container.decode([GamePicks].self, forKey: .gotwPicks)
			upsetPicks = try container.decode([GamePicks].self, forKey: .upsetPicks)
		}
		
		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encode(player, forKey: .player)
			try container.encode(gameWeek, forKey: .gameWeek)
			try container.encode(standardPicks, forKey: .standardPicks)
			try container.encode(gotwPicks, forKey: .gotwPicks)
			try container.encode(upsetPicks, forKey: .upsetPicks)
		}
	}
	
	var picks: WeeklyEntry
	
	init() {
		picks = WeeklyEntry()
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		picks = try container.decode(WeeklyEntry.self, forKey: .weeklyPicks)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(picks, forKey: .weeklyPicks)
	}
}

class EditPicksViewCell: UITableViewCell {
	@IBOutlet weak var editGameOdds: UILabel!
	@IBOutlet weak var editVisitorIcon: UIImageView!
	@IBOutlet weak var editVisitorName: UILabel!
	@IBOutlet weak var editVisitorSelect: UIImageView!
	@IBOutlet weak var editHomeName: UILabel!
	@IBOutlet weak var editHomeIcon: UIImageView!
	@IBOutlet weak var editGameDate: UILabel!
	@IBOutlet weak var editHomeSelect: UIImageView!
}

class PicksTeamViewCell: UITableViewCell {
	@IBOutlet weak var visitorIcon: UIImageView!
	@IBOutlet weak var visitorName: UILabel!
	@IBOutlet weak var visitorScore: UILabel!
	@IBOutlet weak var homeIcon: UIImageView!
	@IBOutlet weak var homeName: UILabel!
	@IBOutlet weak var homeScore: UILabel!
	@IBOutlet weak var gameDate: UILabel!
	@IBOutlet weak var gameStatus: UILabel!
}

class PicksViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
	@IBOutlet weak var submitButton: UIButton!
	@IBOutlet weak var picksWeek: UIPickerView!
	@IBOutlet weak var picksTableView: UITableView!
	
	var pickerData : [String] = [String]()
	var weeklyPicks : WeeklyPicks = WeeklyPicks()
	var submitPicks : SubmittedPicks = SubmittedPicks()
	var currentWeek : Int = 1
	var editPicks = false
	var standardSelections : [Bool] = [Bool]()
	var gotwSelections : [Bool] = [Bool]()
	var upsetSelections : [Bool] = [Bool]()
	
	let cellSpacingHeight: CGFloat = 50
	let rowSpacingHeight: CGFloat = 200
	
	@objc func refresh() {
		self.submitButton.setTitle("Edit", for: .normal)
		self.editPicks = false
		GetWeeklyPicks()
		self.submitButton.setTitle("Edit", for: .normal)
		resetPickSelections()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.picksWeek.delegate = self
		self.picksWeek.dataSource = self
		self.picksTableView.delegate = self
		self.picksTableView.dataSource = self
		self.submitButton.setTitle("Edit", for: .normal)
		
		currentWeek = 1
		pickerData = ["Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6", "Week 7", "Week 8", "Week 9", "Week 10", "Week 11", "Week 12", "Week 13", "Week 14", "Week 15", "Week 16", "Bowls"]
		
		GetWeeklyPicks()
		self.submitButton.setTitle("Edit", for: .normal)
		resetPickSelections()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.refresh()
	}

	@IBAction func submitButton(_ sender: Any) {
		if self.editPicks == false { // This is the regular screen and we are moving to the edit screen
			resetPickSelections()
			GetWeeklyPicks(gameWeek: self.currentWeek)
			updatePickSelections()
			self.editPicks = true
			self.submitButton.setTitle("Submit", for: .normal)
			self.picksTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
		} else { // This is the edit screen and we are submitting picks
			recordPicks()
			SubmitWeeklyPicks(gameWeek: self.currentWeek)
			resetPickSelections()
			self.editPicks = false
			self.submitButton.setTitle("Edit", for: .normal)
			self.picksTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
		}
	}
	
	func GetWeeklyPicks(gameWeek: Int? = nil ) {
		if client.loggedIntoWebsite != true
		{
			self.displayErrorMessage(errorTitle: "Not logged in", errorMessage: "You must be logged into the website before you can access picks.")
			return
		}
		getPicks(webpage: "picks.php", week: gameWeek)
		if self.weeklyPicks.picks.gameWeek != self.currentWeek {
			self.currentWeek = self.weeklyPicks.picks.gameWeek
			self.picksWeek.selectRow(self.currentWeek-1, inComponent: 0, animated: false)
		}
		self.picksTableView.reloadData()
	}
	
	func PostWeeklyPicks(gameWeek: Int) {
		if client.loggedIntoWebsite != true
		{
			self.displayErrorMessage(errorTitle: "Not logged in", errorMessage: "You must be logged into the website before you can post your picks.")
			return
		}
		postPicks(webpage: "picks.php", week: gameWeek)
		if self.weeklyPicks.picks.gameWeek != self.currentWeek {
			self.currentWeek = self.weeklyPicks.picks.gameWeek
			self.picksWeek.selectRow(self.currentWeek-1, inComponent: 0, animated: false)
		}
		self.picksTableView.reloadData()
	}
	
	func SubmitWeeklyPicks(gameWeek: Int) {
		if client.loggedIntoWebsite != true {
			self.displayErrorMessage(errorTitle: "SubmitWeeklyPicks", errorMessage: "Not currently logged into website.")
			return
		}
		submitPicks(webpage: "picks.php", week: gameWeek)
		getPicks(webpage: "picks.php", week: gameWeek)
		self.picksTableView.reloadData()
	}
	
	func getPicks(webpage: String, week: Int? = nil) {
		var getParameters: [String: Any] = [String: Any]()
		if( week != nil ) {
			getParameters = [
				"gameWeek": week!
			]
		}
	
		client.getWebPage(webpage: webpage, getParameters: getParameters, activityIndicator: nil) { returnValue in
			do {
				if returnValue != "" {
					let jsonData = returnValue.data(using: .utf8)!
					self.weeklyPicks = try JSONDecoder().decode(WeeklyPicks.self, from: jsonData)
				}
			} catch {
				print("JSONDecoder error: ", error)
			}
		}
	}
	
	func postPicks(webpage: String, week: Int) {
		var getParameters: [String: Any] = [String: Any]()
		getParameters = [
			"gameWeek": week
		]
		
		let postParameters: [String: Any] = [
			"edit_picks": 1
		]
			
		client.postWebPage(webpage: webpage, getParameters: getParameters, postParameters: postParameters, activityIndicator: nil) { returnValue in
			do {
				if returnValue["response"] != "" {
					let jsonData = returnValue["data"]!.data(using: .utf8)!
					self.weeklyPicks = WeeklyPicks()
					self.weeklyPicks = try JSONDecoder().decode(WeeklyPicks.self, from: jsonData)
				}
			} catch {
				print("JSONDecoder error: ", error)
			}
		}
	}
	
	func submitPicks(webpage: String, week: Int) {
		if ((self.weeklyPicks.picks.standardPicks.count == 0) &&
			(self.weeklyPicks.picks.gotwPicks.count == 0) &&
			(self.weeklyPicks.picks.upsetPicks.count == 0)) {
			return
		}
		
		do {
			let jsonData = try JSONEncoder().encode(self.submitPicks)
			let response = String(data: jsonData, encoding: .utf8)
			
			let getParameters: [String: Any] = [
				"gameWeek": week
			]
			let postParameters: [String: Any] = [
				"submit_picks": 1,
				"pick_data": response!
			]
		
			client.postWebPage(webpage: webpage, getParameters: getParameters, postParameters: postParameters, activityIndicator: nil) { returnValue in
				if returnValue["response"] != "" {
					self.displayErrorMessage(errorTitle: "Pick Submission", errorMessage: "Picks successfully submitted.")
					return
				}
			}
		} catch {
			print("JSONEncoder error: ", error)
		}
	}
	
	func hasUserEnteredPicks() -> Bool {
		for pick in weeklyPicks.picks.standardPicks {
			if pick.userPick != 0 {
				return true
			}
		}
		for pick in weeklyPicks.picks.gotwPicks {
			if pick.userPick != 0 {
				return true
			}
		}
		for pick in weeklyPicks.picks.upsetPicks {
			if pick.userPick != 0 {
				return true
			}
		}

		return false
	}
	
	func recordPicks() {
		if self.weeklyPicks.picks.standardPicks.count > 0 {
			for index in 1...self.weeklyPicks.picks.standardPicks.count {
				var newPick : SubmittedPicks.GamePicks = SubmittedPicks.GamePicks()
				newPick.gameId = self.weeklyPicks.picks.standardPicks[index-1].gameId
				if self.standardSelections[index-1] == false {
					newPick.userPick = self.weeklyPicks.picks.standardPicks[index-1].visitor.team.id
				} else {
					newPick.userPick = self.weeklyPicks.picks.standardPicks[index-1].home.team.id
				}
				self.submitPicks.picks.append(newPick)
			}
		}
		if self.weeklyPicks.picks.gotwPicks.count > 0 {
			for index in 1...self.weeklyPicks.picks.gotwPicks.count {
				var newPick : SubmittedPicks.GamePicks = SubmittedPicks.GamePicks()
				newPick.gameId = self.weeklyPicks.picks.gotwPicks[index-1].gameId
				if self.gotwSelections[index-1] == false {
					newPick.userPick = self.weeklyPicks.picks.gotwPicks[index-1].visitor.team.id
				} else {
					newPick.userPick = self.weeklyPicks.picks.gotwPicks[index-1].home.team.id
				}
				self.submitPicks.picks.append(newPick)
			}
		}
		if self.weeklyPicks.picks.upsetPicks.count > 0 {
			for index in 1...self.weeklyPicks.picks.upsetPicks.count {
				if self.upsetSelections[index-1] == true {
					var newPick : SubmittedPicks.GamePicks = SubmittedPicks.GamePicks()
					newPick.gameId = self.weeklyPicks.picks.upsetPicks[index-1].gameId
					newPick.userPick = self.weeklyPicks.picks.upsetPicks[index-1].underdog
					self.submitPicks.picks.append(newPick)
				}
			}
		}
	}
	
	func resetPickSelections() {
		self.standardSelections.removeAll()
		self.gotwSelections.removeAll()
		self.upsetSelections.removeAll()
		
		if self.weeklyPicks.picks.standardPicks.count != 0 {
			for _ in 1...self.weeklyPicks.picks.standardPicks.count {
				standardSelections.append(false)
			}
		}
		if self.weeklyPicks.picks.gotwPicks.count != 0 {
			for _ in 1...self.weeklyPicks.picks.gotwPicks.count {
				gotwSelections.append(false)
			}
		}
		if self.weeklyPicks.picks.upsetPicks.count != 0 {
			for _ in 1...self.weeklyPicks.picks.upsetPicks.count {
				upsetSelections.append(false)
			}
		}
	}
	
	func updatePickSelections() {
		for index in 1...self.weeklyPicks.picks.standardPicks.count {
			if self.weeklyPicks.picks.standardPicks[index-1].userPick != 0 {
				if self.weeklyPicks.picks.standardPicks[index-1].userPick == self.weeklyPicks.picks.standardPicks[index-1].home.team.id {
					standardSelections[index-1] = true;
				}
			}
		}
		for index in 1...self.weeklyPicks.picks.gotwPicks.count {
			if self.weeklyPicks.picks.gotwPicks[index-1].userPick != 0 {
				if self.weeklyPicks.picks.gotwPicks[index-1].userPick == self.weeklyPicks.picks.gotwPicks[index-1].home.team.id {
					gotwSelections[index-1] = true;
				}
			}
		}
		for index in 1...self.weeklyPicks.picks.upsetPicks.count {
			if self.weeklyPicks.picks.upsetPicks[index-1].userPick != 0 {
				if self.weeklyPicks.picks.upsetPicks[index-1].userPick == self.weeklyPicks.picks.upsetPicks[index-1].home.team.id {
					upsetSelections[index-1] = true;
				}
			}
		}
	}
	
	func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
		let size = image.size
		
		let widthRatio  = targetSize.width  / size.width
		let heightRatio = targetSize.height / size.height
		
		// Figure out what our orientation is, and use that to form the rectangle
		var newSize: CGSize
		if(widthRatio > heightRatio) {
			newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
		} else {
			newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
		}
		
		// This is the rect that we've calculated out and this is what is actually used below
		let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
		
		// Actually do the resizing to the rect using the ImageContext stuff
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		image.draw(in: rect)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage!
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
		GetWeeklyPicks(gameWeek: currentWeek)
		picksTableView.reloadData()
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		// One section for each pick type: standard, gotw, and upset
		return 3
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		var sectionTitle: String = ""
		
		switch( section ) {
		case 0:
			sectionTitle = "Standard Games"
			break
		case 1:
			sectionTitle = "Games of the Week"
			break
		case 2:
			sectionTitle = "Upset Games"
			break
		default:
			sectionTitle = "UNKNOWN STATE"
		}
		
		return sectionTitle
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var numOfRows: Int = 0
		
		switch( section ) {
		case 0:
			numOfRows = weeklyPicks.picks.standardPicks.count
			break
		case 1:
			numOfRows = weeklyPicks.picks.gotwPicks.count
			break
		case 2:
			numOfRows = weeklyPicks.picks.upsetPicks.count
			break
		default:
			numOfRows = 0
			break
		}
		return numOfRows
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let footerView = UIView()
		
		return footerView
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch(indexPath.section) {
		case 0:
			self.standardSelections[indexPath.row] = !(self.standardSelections[indexPath.row])
			break
		case 1:
			self.gotwSelections[indexPath.row] = !(self.gotwSelections[indexPath.row])
			break
		case 2:
			let numUpsetPicks = self.upsetSelections.count
			for index in 1...numUpsetPicks {
				if indexPath.row == (index-1) {
					self.upsetSelections[index-1] = true
				} else {
					self.upsetSelections[index-1] = false
				}
			}
			break
		default:
			break
		}
		self.picksTableView.reloadData()
		DispatchQueue.main.async {
			self.picksTableView.scrollToRow(at: indexPath, at: .top, animated: false)
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if self.editPicks == true {
			return LoadPickSelections(tableView, cellForRowAt: indexPath)
		} else {
			return LoadExistingPicks(tableView, cellForRowAt: indexPath)
		}
	}
	
	func LoadExistingPicks(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath) as! PicksTeamViewCell
		
		var gameInfo: WeeklyPicks.WeeklyEntry.GamePicks = WeeklyPicks.WeeklyEntry.GamePicks()
		
		switch(indexPath.section) {
		case 0:
			if(indexPath.row >= weeklyPicks.picks.standardPicks.count) {
				break
			}
			gameInfo = weeklyPicks.picks.standardPicks[indexPath.row]
			break
		case 1:
			if(indexPath.row >= weeklyPicks.picks.gotwPicks.count) {
				break
			}
			gameInfo = weeklyPicks.picks.gotwPicks[indexPath.row]
			break
		case 2:
			if(indexPath.row >= weeklyPicks.picks.upsetPicks.count) {
				break
			}
			gameInfo = weeklyPicks.picks.upsetPicks[indexPath.row]
			break
		default:
			break
		}
		
		cell.contentView.layer.borderColor = UIColor.clear.cgColor
		cell.contentView.layer.borderWidth = 5.0
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
		cell.gameDate?.text = gameInfo.date
		cell.gameStatus?.text = gameInfo.time
		
		cell.visitorScore.backgroundColor = UIColor.white
		cell.homeScore.backgroundColor = UIColor.white
		
		if((indexPath.section == 2) && (hasUserEnteredPicks() == false)) {
			if(gameInfo.underdog == gameInfo.visitor.team.id) {
				cell.visitorName.backgroundColor = UIColor.yellow
				cell.homeName.backgroundColor = UIColor.white
			} else if(gameInfo.underdog == gameInfo.home.team.id) {
				cell.visitorName.backgroundColor = UIColor.white
				cell.homeName.backgroundColor = UIColor.yellow
			} else {
				cell.visitorName.backgroundColor = UIColor.white
				cell.homeName.backgroundColor = UIColor.white
			}
		} else {
			cell.visitorName.backgroundColor = UIColor.white
			cell.homeName.backgroundColor = UIColor.white
		}
		
		if(indexPath.section != 2) {
			if( gameInfo.winnerId != 0 ) {
				if( gameInfo.userPick == gameInfo.winnerId) {
					if( gameInfo.userPick == gameInfo.visitor.team.id) {
						cell.visitorScore.backgroundColor = UIColor.green
					} else {
						cell.homeScore.backgroundColor = UIColor.green
					}
				} else {
					if( gameInfo.userPick == gameInfo.visitor.team.id) {
						cell.visitorScore.backgroundColor = UIColor.red
					} else {
						cell.homeScore.backgroundColor = UIColor.red
					}
				}
			} else {
				if(gameInfo.userPick != 0) {
					if(gameInfo.userPick == gameInfo.visitor.team.id) {
						cell.visitorName.backgroundColor = UIColor.gray
					} else {
						cell.homeName.backgroundColor = UIColor.gray
					}
				}
			}
		} else {
			if(gameInfo.winnerId != 0) {
				if(gameInfo.userPick == gameInfo.winnerId) {
					if( gameInfo.userPick == gameInfo.visitor.team.id) {
						cell.visitorScore.backgroundColor = UIColor.green
					} else {
						cell.homeScore.backgroundColor = UIColor.green
					}
				} else {
					if( gameInfo.userPick == gameInfo.visitor.team.id) {
						cell.visitorScore.backgroundColor = UIColor.red
					} else {
						cell.homeScore.backgroundColor = UIColor.red
					}
				}
			} else {
				if(gameInfo.userPick == gameInfo.visitor.team.id) {
					cell.visitorName.backgroundColor = UIColor.gray
				} else if(gameInfo.userPick == gameInfo.home.team.id) {
					cell.homeName.backgroundColor = UIColor.gray
				}
			}
		}
		
		return cell;
	}
	
	func LoadPickSelections(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "EditCell", for: indexPath) as! EditPicksViewCell
		
		var gameInfo: WeeklyPicks.WeeklyEntry.GamePicks = WeeklyPicks.WeeklyEntry.GamePicks()
		
		switch(indexPath.section) {
		case 0:
			if(indexPath.row >= weeklyPicks.picks.standardPicks.count) {
				break
			}
			gameInfo = weeklyPicks.picks.standardPicks[indexPath.row]
			if standardSelections[indexPath.row] == false {
				cell.editVisitorSelect?.image = UIImage(named: "Check.png")
				cell.editHomeSelect?.image = nil
			} else {
				cell.editHomeSelect?.image = UIImage(named: "Check.png")
				cell.editVisitorSelect?.image = nil
			}
			break
		case 1:
			if(indexPath.row >= weeklyPicks.picks.gotwPicks.count) {
				break
			}
			gameInfo = weeklyPicks.picks.gotwPicks[indexPath.row]
			if gotwSelections[indexPath.row] == false {
				cell.editVisitorSelect?.image = UIImage(named: "Check.png")
				cell.editHomeSelect?.image = nil
			} else {
				cell.editHomeSelect?.image = UIImage(named: "Check.png")
				cell.editVisitorSelect?.image = nil
			}
			break
		case 2:
			if(indexPath.row >= weeklyPicks.picks.upsetPicks.count) {
				break
			}
			gameInfo = weeklyPicks.picks.upsetPicks[indexPath.row]
			if gameInfo.underdog == gameInfo.visitor.team.id {
				cell.editVisitorName.backgroundColor = UIColor.yellow
				cell.editHomeName.backgroundColor = UIColor.white
			} else if gameInfo.underdog == gameInfo.home.team.id {
				cell.editVisitorName.backgroundColor = UIColor.white
				cell.editHomeName.backgroundColor = UIColor.yellow
			} else {
				cell.editVisitorName.backgroundColor = UIColor.white
				cell.editHomeName.backgroundColor = UIColor.white
			}
			
			if upsetSelections[indexPath.row] == false {
				cell.editVisitorSelect?.image = nil
				cell.editHomeSelect?.image = nil
			} else {
				if gameInfo.underdog == gameInfo.visitor.team.id {
					cell.editVisitorSelect?.image = UIImage(named: "Check.png")
					cell.editHomeSelect?.image = nil
				} else {
					cell.editHomeSelect?.image = UIImage(named: "Check.png")
					cell.editVisitorSelect?.image = nil
				}
			}
			break
		default:
			break
		}

		cell.contentView.layer.borderColor = UIColor.clear.cgColor
		cell.contentView.layer.borderWidth = 5.0
		cell.editVisitorIcon?.image = UIImage(named: gameInfo.visitor.team.icon)
		if(gameInfo.visitor.team.rank != 0) {
			if(gameInfo.visitor.team.ties == 0) {
				cell.editVisitorName?.text = String(format: "#%i %@ (%i-%i)",
													gameInfo.visitor.team.rank,
													gameInfo.visitor.team.name,
													gameInfo.visitor.team.wins,
													gameInfo.visitor.team.loses)
			} else {
				cell.editVisitorName?.text = String(format: "#%i %@ (%i-%i-%i)",
													gameInfo.visitor.team.rank,
													gameInfo.visitor.team.name,
													gameInfo.visitor.team.wins,
													gameInfo.visitor.team.loses,
													gameInfo.visitor.team.ties)
			}
		} else {
			if(gameInfo.visitor.team.ties == 0) {
				cell.editVisitorName?.text = String(format: "%@ (%i-%i)",
													gameInfo.visitor.team.name,
													gameInfo.visitor.team.wins,
													gameInfo.visitor.team.loses)
			} else {
				cell.editVisitorName?.text = String(format: "%@ (%i-%i-%i)",
													gameInfo.visitor.team.name,
													gameInfo.visitor.team.wins,
													gameInfo.visitor.team.loses,
													gameInfo.visitor.team.ties)
			}
		}
		cell.editHomeIcon?.image = UIImage(named: gameInfo.home.team.icon)
		if(gameInfo.home.team.rank != 0) {
			if(gameInfo.home.team.ties == 0) {
				cell.editHomeName?.text = String(format: "#%i %@ (%i-%i)",
													gameInfo.home.team.rank,
													gameInfo.home.team.name,
													gameInfo.home.team.wins,
													gameInfo.home.team.loses)
			} else {
				cell.editHomeName?.text = String(format: "#%i %@ (%i-%i-%i)",
													gameInfo.home.team.rank,
													gameInfo.home.team.name,
													gameInfo.home.team.wins,
													gameInfo.home.team.loses,
													gameInfo.home.team.ties)
			}
		} else {
			if(gameInfo.home.team.ties == 0) {
				cell.editHomeName?.text = String(format: "%@ (%i-%i)",
													gameInfo.home.team.name,
													gameInfo.home.team.wins,
													gameInfo.home.team.loses)
			} else {
				cell.editHomeName?.text = String(format: "%@ (%i-%i-%i)",
													gameInfo.home.team.name,
													gameInfo.home.team.wins,
													gameInfo.home.team.loses,
													gameInfo.home.team.ties)
			}
		}
		
		cell.editGameDate?.text = gameInfo.date
		cell.editGameOdds?.text = gameInfo.odds
		return cell
	}
}
