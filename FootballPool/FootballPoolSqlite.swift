//
//  FootballPoolSqlite.swift
//  FootballPool
//
//  Created by Matthew Areno on 6/12/19.
//  Copyright © 2019 Matthew Areno. All rights reserved.
//

import UIKit
import Foundation
import SQLite3

struct FootballPoolGame {
	var gameId : Int64 = 0
	var visitorId : Int64 = 0
	var visitorFirstScore : Int32 = 0
	var visitorSecondScore : Int32 = 0
	var visitorThirdScore : Int32 = 0
	var visitorFourthScore : Int32 = 0
	var visitorOtScore : Int32 = 0
	var visitorFinalScore : Int32 = 0
	var homeId : Int64 = 0
	var homeFirstScore : Int32 = 0
	var homeSecondScore : Int32 = 0
	var homeThirdScore : Int32 = 0
	var homeFourthScore : Int32 = 0
	var homeOtScore : Int32 = 0
	var homeFinalScore : Int32 = 0
	var winnerId : Int64 = 0
	var gameStatus : Int32 = 0
	var gameWeek : Int32 = 0
	var gameDate : String = ""
	var gameTime : String = ""
	var gameOdds : String = ""
	var gameDivision : Int32 = 0
	var gameChronology : Int32 = 0
	var gameSiteNeutral : Int32 = 0
}

struct FootballPoolTeam {
	var teamId : Int64 = 0
	var teamName : String = ""
	var teamFullName : String = ""
	var teamWins : Int32 = 0
	var teamLoses : Int32 = 0
	var teamTies : Int32 = 0
	var teamURL : String = ""
	var teamIconFile : String = ""
	var teamRanking : Int32 = 0
}

struct FootballPoolPick {
	var gameId : Int64 = 0
	var winner : Int64 = 0
	var week : Int32 = 0
	var type : String = ""
	var points : Int32 = 0
	var underdog : Int32 = 0
	var chronology : Int32 = 0
}

struct FootballPoolUserPick {
	var pickId : Int64 = 0
	var gameId : Int64 = 0
	var userId : Int64 = 0
	var winnerId : Int64 = 0
	var gameWeek : Int32 = 0
	var pickChronology : Int32 = 0
}

struct FootballPoolRank {
	var teamId : Int64 = 0
	var week : Int32 = 0
	var rank : Int32 = 0
}

struct FootballPoolResult {
	var userId : Int64 = 0
	var points : Int32 = 0
	var week : Int32 = 0
}

struct FootballPoolUser {
	var userId : Int64 = 0
	var firstName : String = ""
	var lastName : String = ""
	var userName : String = ""
	var email : String = ""
	var regularPoints : Int32 = 0
	var conferencePoints : Int32 = 0
	var seasonWins : Int32 = 0
	var conferenceId : Int32 = 0
	var overallWins : Int32 = 0
	var overallLoses : Int32 = 0
	var overallTies : Int32 = 0
	var conferenceWins : Int32 = 0
	var conferenceLoses : Int32 = 0
	var conferenceTies : Int32 = 0
	var theme : Int32 = 0
}

class FootballPoolSqlite: NSObject {
	var db : OpaquePointer? = nil
	
	deinit {
		closeDatabase()
	}
	
	func openDatabase() {
		if db != nil
		{
			return
		}
		
		let localPathURL:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as! URL
		let localDatabaseURL = localPathURL.appendingPathComponent("football_2018.sqlite")
		
		if sqlite3_open(localDatabaseURL.path, &db) == SQLITE_OK {
			print("Successfully opened connection to database.")
		}
		else {
			print("Failed to open conection to database. Does it exist?")
		}
	}
	
	func closeDatabase() {
		if db != nil {
			sqlite3_close(db)
			db = nil
		}
	}
	
	func readGameData(gameList : inout [Int64: FootballPoolGame]) {
		let queryString : String = "SELECT * FROM Games"
		var stmt : OpaquePointer?
		
		gameList.removeAll()
		
		if db == nil {
			openDatabase()
		}
		
		if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
			let errmsg = String(cString : sqlite3_errmsg(db)!)
			print("error preparing select: \(errmsg)")
			closeDatabase()
			return
		}
		
		while(sqlite3_step(stmt) == SQLITE_ROW) {
			let newGame = FootballPoolGame(
				gameId : sqlite3_column_int64(stmt, 0),
				visitorId : sqlite3_column_int64(stmt, 1),
				visitorFirstScore : sqlite3_column_int(stmt, 2),
				visitorSecondScore : sqlite3_column_int(stmt, 3),
				visitorThirdScore : sqlite3_column_int(stmt, 4),
				visitorFourthScore : sqlite3_column_int(stmt, 5),
				visitorOtScore : sqlite3_column_int(stmt, 6),
				visitorFinalScore : sqlite3_column_int(stmt, 7),
				homeId : sqlite3_column_int64(stmt, 8),
				homeFirstScore : sqlite3_column_int(stmt, 9),
				homeSecondScore : sqlite3_column_int(stmt, 10),
				homeThirdScore : sqlite3_column_int(stmt, 11),
				homeFourthScore : sqlite3_column_int(stmt, 12),
				homeOtScore : sqlite3_column_int(stmt, 13),
				homeFinalScore : sqlite3_column_int(stmt, 14),
				winnerId : sqlite3_column_int64(stmt, 15),
				gameStatus : sqlite3_column_int(stmt, 16),
				gameWeek : sqlite3_column_int(stmt, 17),
				gameDate : String(cString: sqlite3_column_text(stmt, 18)),
				gameTime : String(cString: sqlite3_column_text(stmt, 19)),
				gameOdds : String(cString: sqlite3_column_text(stmt, 20)),
				gameDivision : sqlite3_column_int(stmt, 21),
				gameChronology : sqlite3_column_int(stmt, 22),
				gameSiteNeutral : sqlite3_column_int(stmt, 23)
			)
			gameList[newGame.gameId] = newGame
		}
		
		return
	}
	
	func readGameDataByWeek(gameWeek : Int32, gameList : inout [FootballPoolGame]) {
		let queryString = String(format: "SELECT * FROM Games WHERE gameWeek=%i", gameWeek)
		var stmt : OpaquePointer?
		
		gameList.removeAll()
		
		if db == nil {
			openDatabase()
		}
		
		if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
			let errmsg = String(cString : sqlite3_errmsg(db)!)
			print("error preparing select: \(errmsg)")
			closeDatabase()
			return
		}
		
		while(sqlite3_step(stmt) == SQLITE_ROW) {
			let newGame = FootballPoolGame(
				gameId : sqlite3_column_int64(stmt, 0),
				visitorId : sqlite3_column_int64(stmt, 1),
				visitorFirstScore : sqlite3_column_int(stmt, 2),
				visitorSecondScore : sqlite3_column_int(stmt, 3),
				visitorThirdScore : sqlite3_column_int(stmt, 4),
				visitorFourthScore : sqlite3_column_int(stmt, 5),
				visitorOtScore : sqlite3_column_int(stmt, 6),
				visitorFinalScore : sqlite3_column_int(stmt, 7),
				homeId : sqlite3_column_int64(stmt, 8),
				homeFirstScore : sqlite3_column_int(stmt, 9),
				homeSecondScore : sqlite3_column_int(stmt, 10),
				homeThirdScore : sqlite3_column_int(stmt, 11),
				homeFourthScore : sqlite3_column_int(stmt, 12),
				homeOtScore : sqlite3_column_int(stmt, 13),
				homeFinalScore : sqlite3_column_int(stmt, 14),
				winnerId : sqlite3_column_int64(stmt, 15),
				gameStatus : sqlite3_column_int(stmt, 16),
				gameWeek : sqlite3_column_int(stmt, 17),
				gameDate : String(cString: sqlite3_column_text(stmt, 18)),
				gameTime : String(cString: sqlite3_column_text(stmt, 19)),
				gameOdds : String(cString: sqlite3_column_text(stmt, 20)),
				gameDivision : sqlite3_column_int(stmt, 21),
				gameChronology : sqlite3_column_int(stmt, 22),
				gameSiteNeutral : sqlite3_column_int(stmt, 23)
			)
			gameList.append(newGame)
		}
		
		return
	}
	
	func readTeamData(teamList : inout [Int64: FootballPoolTeam]) {
		let queryString = "SELECT * FROM Teams"
		var stmt : OpaquePointer?
		
		teamList.removeAll()
		
		if db == nil {
			openDatabase()
		}
		
		if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
			let errmsg = String(cString : sqlite3_errmsg(db)!)
			print("error preparing select: \(errmsg)")
			closeDatabase()
			return
		}
		
		while(sqlite3_step(stmt) == SQLITE_ROW) {
			let newTeam = FootballPoolTeam (teamId: sqlite3_column_int64(stmt, 0),
											teamName: String(cString: sqlite3_column_text(stmt, 1)),
											teamFullName: String(cString: sqlite3_column_text(stmt, 2)),
											teamWins: sqlite3_column_int(stmt, 3),
											teamLoses: sqlite3_column_int(stmt, 4),
											teamTies: sqlite3_column_int(stmt, 5),
											teamURL: String(cString: sqlite3_column_text(stmt, 6)),
											teamIconFile: String(cString: sqlite3_column_text(stmt, 7)),
											teamRanking: sqlite3_column_int(stmt, 8))
			
			teamList[newTeam.teamId] = newTeam
		}
	}
	
	func readPicksByWeek(week : Int32, pickList : inout [FootballPoolPick]) {
		let queryString = String(format: "SELECT * FROM Picks WHERE week=%i", week)
		var stmt : OpaquePointer?
		
		pickList.removeAll()
		
		if db == nil {
			openDatabase()
		}
		
		if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
			let errmsg = String(cString : sqlite3_errmsg(db)!)
			print("error preparing select: \(errmsg)")
			return
		}
		
		while(sqlite3_step(stmt) == SQLITE_ROW) {
			let newPick = FootballPoolPick (gameId: sqlite3_column_int64(stmt, 0),
											winner: sqlite3_column_int64(stmt, 1),
											week: sqlite3_column_int(stmt, 2),
											type: String(cString: sqlite3_column_text(stmt, 3)),
											points: sqlite3_column_int(stmt, 4),
											underdog: sqlite3_column_int(stmt, 5),
											chronology: sqlite3_column_int(stmt, 6))
			pickList.append(newPick)
		}
	}
	
	func readPicksByWeekSorted(week : Int32, pickList : inout [Int64: FootballPoolPick]) {
		let queryString = String(format: "SELECT * FROM Picks WHERE week=%i", week)
		var stmt : OpaquePointer?
		
		pickList.removeAll()
		
		if db == nil {
			openDatabase()
		}
		
		if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
			let errmsg = String(cString : sqlite3_errmsg(db)!)
			print("error preparing select: \(errmsg)")
			return
		}
		
		while(sqlite3_step(stmt) == SQLITE_ROW) {
			let newPick = FootballPoolPick (gameId: sqlite3_column_int64(stmt, 0),
											winner: sqlite3_column_int64(stmt, 1),
											week: sqlite3_column_int(stmt, 2),
											type: String(cString: sqlite3_column_text(stmt, 3)),
											points: sqlite3_column_int(stmt, 4),
											underdog: sqlite3_column_int(stmt, 5),
											chronology: sqlite3_column_int(stmt, 6))
			pickList[newPick.gameId] = newPick
		}
	}

	func readUserPicksByWeek(week : Int32, userId : Int64, userPickList : inout [Int64: FootballPoolUserPick]) {
		let queryString = String(format: "SELECT * FROM UserPicks WHERE week=%i AND userId=%i", week, userId)
		var stmt : OpaquePointer?
		
		userPickList.removeAll()
		
		print(queryString)
		
		if db == nil {
			openDatabase()
		}
		
		if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
			let errmsg = String(cString : sqlite3_errmsg(db)!)
			print("error preparing select: \(errmsg)")
			return
		}
		
		while(sqlite3_step(stmt) == SQLITE_OK) {
			let newPick = FootballPoolUserPick (pickId: sqlite3_column_int64(stmt, 0),
												gameId: sqlite3_column_int64(stmt, 1),
												userId: sqlite3_column_int64(stmt, 2),
												winnerId: sqlite3_column_int64(stmt, 3),
												gameWeek: sqlite3_column_int(stmt, 4),
												pickChronology: sqlite3_column_int(stmt, 5))
			userPickList[newPick.gameId] = newPick
		}

	}
	
	func readRankingsData(rankList : inout [[FootballPoolRank]]) {
		let queryString = "SELECT * FROM Rankings"
		var stmt : OpaquePointer?
		var week1Ranks = [FootballPoolRank]()
		var week2Ranks = [FootballPoolRank]()
		var week3Ranks = [FootballPoolRank]()
		var week4Ranks = [FootballPoolRank]()
		var week5Ranks = [FootballPoolRank]()
		var week6Ranks = [FootballPoolRank]()
		var week7Ranks = [FootballPoolRank]()
		var week8Ranks = [FootballPoolRank]()
		var week9Ranks = [FootballPoolRank]()
		var week10Ranks = [FootballPoolRank]()
		var week11Ranks = [FootballPoolRank]()
		var week12Ranks = [FootballPoolRank]()
		var week13Ranks = [FootballPoolRank]()
		var week14Ranks = [FootballPoolRank]()
		var week15Ranks = [FootballPoolRank]()
		var week16Ranks = [FootballPoolRank]()
		var week17Ranks = [FootballPoolRank]()
		
		rankList.removeAll()
		
		if db == nil {
			openDatabase()
		}
		
		if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
			let errmsg = String(cString : sqlite3_errmsg(db)!)
			print("error preparing select: \(errmsg)")
			return
		}
		
		while(sqlite3_step(stmt) == SQLITE_ROW) {
			let newRank = FootballPoolRank(teamId: sqlite3_column_int64(stmt, 0),
										   week: sqlite3_column_int(stmt, 1),
										   rank: sqlite3_column_int(stmt, 2))
			
			switch newRank.week {
			case 1:
				week1Ranks.append(newRank)
			case 2:
				week2Ranks.append(newRank)
			case 3:
				week3Ranks.append(newRank)
			case 4:
				week4Ranks.append(newRank)
			case 5:
				week5Ranks.append(newRank)
			case 6:
				week6Ranks.append(newRank)
			case 7:
				week7Ranks.append(newRank)
			case 8:
				week8Ranks.append(newRank)
			case 9:
				week9Ranks.append(newRank)
			case 10:
				week10Ranks.append(newRank)
			case 11:
				week11Ranks.append(newRank)
			case 12:
				week12Ranks.append(newRank)
			case 13:
				week13Ranks.append(newRank)
			case 14:
				week14Ranks.append(newRank)
			case 15:
				week15Ranks.append(newRank)
			case 16:
				week16Ranks.append(newRank)
			case 17:
				week17Ranks.append(newRank)
			default:
				print("Found game with week value of: \(newRank.week)")
			}
			
		}
		
		rankList.append(week1Ranks)
		rankList.append(week2Ranks)
		rankList.append(week3Ranks)
		rankList.append(week4Ranks)
		rankList.append(week5Ranks)
		rankList.append(week6Ranks)
		rankList.append(week7Ranks)
		rankList.append(week8Ranks)
		rankList.append(week9Ranks)
		rankList.append(week10Ranks)
		rankList.append(week11Ranks)
		rankList.append(week12Ranks)
		rankList.append(week13Ranks)
		rankList.append(week14Ranks)
		rankList.append(week15Ranks)
		rankList.append(week16Ranks)
		rankList.append(week17Ranks)
	}
	
	func readPicksData(pickList : inout [FootballPoolPick]) {
		let queryString = "SELECT * FROM Picks"
		var stmt : OpaquePointer?
		
		pickList.removeAll()
		
		if db == nil {
			openDatabase()
		}
		
		if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
			let errmsg = String(cString : sqlite3_errmsg(db)!)
			print("error preparing select: \(errmsg)")
			return
		}
		
		while(sqlite3_step(stmt) == SQLITE_ROW) {
			let newPick = FootballPoolPick (gameId: sqlite3_column_int64(stmt, 0),
											winner: sqlite3_column_int64(stmt, 1),
											week: sqlite3_column_int(stmt, 2),
											type: String(cString: sqlite3_column_text(stmt, 3)),
											points: sqlite3_column_int(stmt, 4),
											underdog: sqlite3_column_int(stmt, 5),
											chronology: sqlite3_column_int(stmt, 6))
			pickList.append(newPick)
		}
	}
	
	func readUserPicksData(userPickList : inout [FootballPoolUserPick]) {
		let queryString = "SELECT * FROM Picks"
		var stmt : OpaquePointer?
		
		userPickList.removeAll()
		
		if db == nil {
			openDatabase()
		}
		
		if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
			let errmsg = String(cString : sqlite3_errmsg(db)!)
			print("error preparing select: \(errmsg)")
			return
		}
		
		while(sqlite3_step(stmt) == SQLITE_ROW) {
			let newPick = FootballPoolUserPick (pickId: sqlite3_column_int64(stmt, 0),
												gameId: sqlite3_column_int64(stmt, 1),
												userId: sqlite3_column_int64(stmt, 2),
												winnerId: sqlite3_column_int64(stmt, 3),
												gameWeek: sqlite3_column_int(stmt, 4),
												pickChronology: sqlite3_column_int(stmt, 5))
			userPickList.append(newPick)
		}
	}

	func readUserFirstLastNames(userList : inout [Int64: FootballPoolUser]) {
		let queryString = "SELECT id,firstName,lastName FROM Users"
		var stmt : OpaquePointer?
		
		userList.removeAll()
		
		if db == nil {
			openDatabase()
		}
		
		if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
			let errmsg = String(cString : sqlite3_errmsg(db)!)
			print("error preparing select: \(errmsg)")
			return
		}
		
		while(sqlite3_step(stmt) == SQLITE_ROW) {
			let newUser = FootballPoolUser (userId: sqlite3_column_int64(stmt, 0),
											firstName: String(cString: sqlite3_column_text(stmt, 1)),
											lastName: String(cString: sqlite3_column_text(stmt, 2)),
											userName: "",
											email: "",
											regularPoints: 0,
											conferencePoints: 0,
											seasonWins: 0,
											conferenceId: 0,
											overallWins: 0,
											overallLoses: 0,
											overallTies: 0,
											conferenceWins: 0,
											conferenceLoses: 0,
											conferenceTies: 0,
											theme: 0)
			userList[newUser.userId] = newUser
		}
	}
	
	func readResults(resultList: inout [[FootballPoolResult]]) {
		var stmt : OpaquePointer?
		var currentWeek = 1
		
		resultList.removeAll()
		
		if db == nil {
			openDatabase()
		}
		
		while currentWeek <= 17 {
			let queryString = String(format: "SELECT * from WeeklyResults WHERE week=%i ORDER BY points DESC", currentWeek)
			var weeklyResults: [FootballPoolResult] = [FootballPoolResult]()
			
			if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
				let errmsg = String(cString : sqlite3_errmsg(db)!)
				print("error preparing select: \(errmsg)")
				return
			}
		
			while(sqlite3_step(stmt) == SQLITE_ROW) {
				let newResult = FootballPoolResult (userId: sqlite3_column_int64(stmt, 0),
													points: sqlite3_column_int(stmt, 1),
													week: sqlite3_column_int(stmt, 2))
				weeklyResults.append(newResult)
			}
			resultList.append(weeklyResults)
			currentWeek += 1
		}
	}
}
