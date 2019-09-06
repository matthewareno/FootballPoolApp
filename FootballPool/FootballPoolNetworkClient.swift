//
//  FootballPoolNetworkClient.swift
//  FootballPool
//
//  Created by Matthew Areno on 6/16/19.
//  Copyright © 2019 Matthew Areno. All rights reserved.
//

import UIKit

//**********************************************************************************
// Web extension needed for creating POST parameters as part of URL requests
//**********************************************************************************
extension Dictionary {
	func percentEscaped() -> String {
		return map { (key, value) in
			let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
			let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
			return escapedKey + "=" + escapedValue
			}
			.joined(separator: "&")
	}
}

extension CharacterSet {
	static let urlQueryValueAllowed: CharacterSet = {
		let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
		let subDelimitersToEncode = "!$&'()*+,;="
		
		var allowed = CharacterSet.urlQueryAllowed
		allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
		return allowed
	}()
}

class FootballPoolNetworkClient: NSObject {
	var defaultSession = URLSession(configuration: .default)
	var dataTask : URLSessionDataTask?
	var errorMessage : String = String()
	var serverURL : String = String()
	let getSemaphore = DispatchSemaphore(value:	1)
	let postSemaphore = DispatchSemaphore(value: 1)
	var loggedIntoWebsite = false
	
	func loginToWebsite(webpage: String, username: String, password: String, activityIndicator: UIActivityIndicatorView? = nil, completion: @escaping (Int)->()) {
		getWebPage(webpage: "login.php", activityIndicator: activityIndicator) { returnData in
			if returnData == ""
			{
				print("loginToWebsite failed.")
				completion(-1)
				return
			}
		}
		
		let parameters: [String: Any] = [
			"username": username,
			"password": password,
			"submitPass": "Submit"
		]
		postWebPage(webpage: "login.php", postParameters: parameters, activityIndicator: activityIndicator) { returnData in
			if returnData["response"] == ""
			{
				print("sendLoginInformation failed.")
				completion(-1)
				return
			}
			if returnData["response"]!.contains("private.php") == true {
				print("Login successful.")
				self.loggedIntoWebsite = true;
				completion(0)
				return
			} else {
				print("Login FAILED.")
				completion(-1)
				return
			}
		}
		
		completion(0)
		return
	}
	
	func logoutOfWebsite(activityIndicator: UIActivityIndicatorView? = nil, completion: ((Int) -> Void)? = nil) {
		let parameters: [String: Any] = [:]
		
		postWebPage(webpage: "logout.php", postParameters: parameters, activityIndicator: activityIndicator) { returnData in
			if returnData["response"] == "" {
				print("logoutOfWebsite failed.")
				completion?(-1)
				self.loggedIntoWebsite = false;
				return
			}
			if returnData["response"]!.contains("login.php") == true {
				print("Logout successful.")
				self.loggedIntoWebsite = false;
				completion?(0)
				return
			} else {
				print("Logout failed.")
				completion?(-1)
				return
			}
		}
		
		completion?(0)
		return
	}
	
	func getWebPage(webpage: String, getParameters: [String: Any]? = nil, activityIndicator: UIActivityIndicatorView? = nil, completion: @escaping (String)->()) {
		var remoteURLString = serverURL + "/" + webpage
		if getParameters != nil && getParameters?.count != 0 {
			remoteURLString.append("?")
			remoteURLString.append(getParameters!.percentEscaped())
		}
		let remoteURL = URL(string: remoteURLString)
		var returnData : String = ""
		
		print("Fetching %s from webserver...", remoteURLString)
		
		if activityIndicator != nil {
			activityIndicator?.startAnimating()
		}
		getSemaphore.wait()
		dataTask = defaultSession.dataTask(with: remoteURL!) { (data, response, error) in
			guard let response = response as? HTTPURLResponse, error == nil else {
				print("error", error ?? "Unknown error")
				completion("")
				self.getSemaphore.signal()
				return
			}
			guard (200 ... 299) ~= response.statusCode else {
				print("statusCode should be 2xx, but is \(response.statusCode)")
				print("response = \(response)")
				completion("")
				self.getSemaphore.signal()
				return
			}

			returnData = String(data: data!, encoding: .utf8) ?? ""
			print("Successfully retrieved webpage.")
			completion(returnData)
			self.getSemaphore.signal()
			return
		}
		dataTask?.resume()
		getSemaphore.wait()
		getSemaphore.signal()
		if activityIndicator != nil {
			activityIndicator?.stopAnimating()
		}
	}
	
	func postWebPage(webpage: String, getParameters: [String: Any]? = nil, postParameters: [String: Any]? = nil, activityIndicator: UIActivityIndicatorView? = nil, completion: @escaping ([String: String])->())  {
		var remoteURLString = serverURL + "/" + webpage
		if getParameters != nil && getParameters?.count != 0 {
			remoteURLString.append("?")
			remoteURLString.append(getParameters!.percentEscaped())
		}
		let remoteURL = URL(string: remoteURLString)
		var request = URLRequest(url: remoteURL!)
		
		print("Posting %s to webserver...", remoteURLString)
		
		request.httpMethod = "POST"
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		
		if postParameters != nil {
			request.httpBody = postParameters!.percentEscaped().data(using: .utf8)
		}
		
		if activityIndicator != nil {
			activityIndicator?.startAnimating()
		}
		postSemaphore.wait()
		dataTask = defaultSession.dataTask(with: request) { (data, response, error) in
			guard let response = response as? HTTPURLResponse, error == nil else {
				print("error", error ?? "Unknown error")
				let result: [String: String] = ["response": ""]
				completion(result)
				self.postSemaphore.signal()
				return
			}
			if response.url != nil {
				let returnData = response.url?.absoluteString
				let result: [String: String] = ["response" : returnData!,
											    "data" : String(data: data!, encoding: .utf8) ?? ""]
				completion(result)
				self.postSemaphore.signal()
				return
			} else {
				let result: [String: String] = ["response": ""]
				completion(result)
				self.postSemaphore.signal()
				return
			}
		}
		dataTask?.resume()
		postSemaphore.wait()
		postSemaphore.signal()
		if activityIndicator != nil {
			activityIndicator?.stopAnimating()
		}
	}

/*	func retrieveDatabase() -> Int8 {
		let errorCode : Int8 = 0
		
		let localPathURL:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as! URL
		let localDatabaseURL = localPathURL.appendingPathComponent("football.sqlite")
		let remoteDatabaseURL = URL(string: "https://www.trusecsys.com/football_2018.sqlite")
		
		let sessionConfig = URLSessionConfiguration.default
		let session = URLSession(configuration: sessionConfig)
		let request = URLRequest(url: remoteDatabaseURL!)
		
		let task = session.downloadTask(with: request) { (tempLocalURL, response, error) in
			if let tempLocalURL = tempLocalURL, error == nil {
				if let statusCode = (response as? HTTPURLResponse)?.statusCode {
					print("Successfully downloaded database file. Status code: \(statusCode)")
				}
				
				do {
					try FileManager.default.copyItem(at: tempLocalURL, to: localDatabaseURL)
					print("Successfully wrote database to file: \(localDatabaseURL)")
				} catch (let writeError) {
					print("Error creating a file \(localDatabaseURL) : \(writeError)")
					errorCode = -2
				}
			} else {
				print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "Unknown");
				errorCode = -1
			}
		}
		task.resume()
		return errorCode
	}*/
}
