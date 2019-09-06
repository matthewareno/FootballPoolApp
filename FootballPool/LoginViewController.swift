//
//  FirstViewController.swift
//  FootballPool
//
//  Created by Matthew Areno on 6/10/19.
//  Copyright © 2019 Matthew Areno. All rights reserved.
//

import UIKit

var numberOfWeeks = 17
var client : FootballPoolNetworkClient = FootballPoolNetworkClient()

let appName = "FootballPoolPickems"

struct Credentials {
	var url: String
	var username: String
	var password: String
}

enum KeychainError: Error {
	case noPassword
	case unexpectedPasswordData
	case unhandledError(status: OSStatus)
}

extension String {
	var isAlphanumeric: Bool {
		return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
	}
}

class LoginViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var websiteField: UITextField!
	@IBOutlet weak var usernameField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var webActivityIndicator: UIActivityIndicatorView!
	
	var credentials = Credentials(url: "", username: "", password: "")
	
	@IBAction func loginButton(_ sender: Any) {
		if validateUserFields() == false {
			return
		}
		
		client.serverURL = websiteField.text ?? ""
		self.webActivityIndicator.startAnimating()
		client.loginToWebsite(webpage: websiteField.text!, username: usernameField.text!, password: passwordField.text!, activityIndicator: webActivityIndicator) { returnValue in
			if returnValue == -1
			{
				self.displayErrorMessage(errorTitle: "Login failed", errorMessage: "Unable to log into football pool website.")
				return
			}
			return
		}
		self.webActivityIndicator.stopAnimating()
		if self.credentials.url == "" || self.credentials.username == "" || self.credentials.password == "" {
			addUserCredentials()
		}
		if self.credentials.url != self.websiteField.text ||
			self.credentials.username != self.usernameField.text ||
			self.credentials.password != self.passwordField.text {
			removeUserCredentials()
			addUserCredentials()
		}
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	
		self.websiteField.delegate = self
		self.usernameField.delegate = self
		self.passwordField.delegate = self
		
		self.webActivityIndicator.hidesWhenStopped = true
		self.webActivityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
		self.webActivityIndicator.color = .green
		
		if searchForUserCredentials() == true {
			self.websiteField.text = self.credentials.url
			self.usernameField.text = self.credentials.username
			self.passwordField.text = self.credentials.password
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.websiteField.resignFirstResponder()
		self.usernameField.resignFirstResponder()
		self.passwordField.resignFirstResponder()
		return true
	}
	
	func addUserCredentials() {
		self.credentials.url = self.websiteField.text!
		self.credentials.username = self.usernameField.text!
		self.credentials.password = self.passwordField.text!
		let password = self.credentials.password.data(using: String.Encoding.utf8)!
		let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
									kSecAttrLabel as String: appName,
									kSecAttrAccount as String: self.credentials.username,
									kSecAttrServer as String: self.credentials.url,
									kSecValueData as String: password]
		let status = SecItemAdd(query as CFDictionary, nil)
		guard status == errSecSuccess else {
			let errorString = SecCopyErrorMessageString(status, nil)
			displayErrorMessage(errorTitle: "Keychain Error", errorMessage: errorString! as String)
			return
		}
	}
	
	func removeUserCredentials() {
		let server = self.credentials.url
		let account = self.credentials.username
		let password = self.credentials.password.data(using: String.Encoding.utf8)!
		let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
									kSecAttrLabel as String: appName,
									kSecAttrAccount as String: account,
									kSecAttrServer as String: server,
									kSecValueData as String: password]
		
		SecItemDelete(query as CFDictionary)
	}
	
	func searchForUserCredentials( ) -> Bool {
		let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
									kSecAttrLabel as String: appName,
									kSecMatchLimit as String: kSecMatchLimitOne,
									kSecReturnAttributes as String: true,
									kSecReturnData as String: true]
		var item: CFTypeRef?

		let status = SecItemCopyMatching(query as CFDictionary, &item)
		guard status != errSecItemNotFound else {
			return false
		}
		guard status == errSecSuccess else { displayErrorMessage(errorTitle: "Keychain Error", errorMessage: "Error searching for user credentials")
			return false
		}
		guard let existingItem = item as? [String : Any],
			let passwordData = existingItem[kSecValueData as String] as? Data,
			let password = String(data: passwordData, encoding: String.Encoding.utf8),
			let account = existingItem[kSecAttrAccount as String] as? String,
			let server = existingItem[kSecAttrServer as String] as? String else {
				displayErrorMessage(errorTitle: "Keychain Error", errorMessage: "Error extracting user credentials")
				return false
		}
		credentials.url = server
		credentials.username = account
		credentials.password = password
		
		return true
	}
	
	func displayErrorMessage(errorTitle: String, errorMessage: String) {
		let alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
		let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in return}
		alertController.addAction(OKAction)
		
		present(alertController, animated: true)
	}
	
	func validateUserFields() -> Bool {
		if websiteField.hasText == false {
			displayErrorMessage(errorTitle: "No connection", errorMessage: "No website information was provided. Please provide the URL for your website.")
			return false
		}
		if usernameField.hasText == false {
			displayErrorMessage(errorTitle: "No connection", errorMessage: "No username information was provided. Please provide the username for your website account.")
			return false
		}
		if usernameField?.text?.isAlphanumeric == false {
			displayErrorMessage(errorTitle: "Invalid Username", errorMessage: "Username may only contain alphanumeric characters.")
			return false
		}
		if passwordField.hasText == false {
			displayErrorMessage(errorTitle: "No connection", errorMessage: "No password information was provided. Please provide the password for your website account.")
			return false
		}
		if passwordField?.text?.isAlphanumeric == false {
			displayErrorMessage(errorTitle: "Invalid Password", errorMessage: "Password may only contain alphanumeric characters.")
			return false

		}
		
		return true
	}
}

