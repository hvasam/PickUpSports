//
//  PostGameNavigationController.swift
//  Pick Up Sports
//
//  Created by Harshavardhan Vasam on 2017-04-24.
//  Copyright © 2017 Harshavardhan Vasam. All rights reserved.
//

import UIKit
import Firebase

class PostGameNavigationController: UINavigationController, GameCreationDelegate {
    
    //MARK: GameCreationDelegate Properties
    var sport: String = ""
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var startTime: Date?
    var endTime: Date?
    var maxParticipants: Int?
    var additionalInfo: String?
    var listOfSportsTableViewController: ListOfSportsTableViewController?
    var locationViewController: LocationViewController?
    var timingsViewController: TimingsViewController?
    var additionalInfoViewController: AdditionalInfoViewController?
    
    //MARK: Properties
    let usersDatabaseReference = FIRDatabase.database().reference().child("users")
    let gamesDatabaseReference = FIRDatabase.database().reference().child("games")
    let user = (UIApplication.shared.delegate as! AppDelegate).user!
    
    //MARK: GameCreationDelegate Methods
    func pushLocationViewControllerOnToNavigationStack() {
        guard let locationViewController = locationViewController else {
            return
        }
        pushViewController(locationViewController, animated: true)
    }
    
    func pushTimingsViewControllerOnToNavigationStack() {
        guard let timingsViewController = timingsViewController else {
            return
        }
        pushViewController(timingsViewController, animated: true)
    }
    
    func pushAdditionalInfoViewControllerOnToNavigationStack() {
        guard let additionalInfoViewController = additionalInfoViewController else {
            return
        }
        pushViewController(additionalInfoViewController, animated: true)
    }
    
    // Save to Firebase Database
    func postGame() {
        guard let startTimeStringDescription = startTime?.description else {
            return
        }
        
        let yearRange = startTimeStringDescription.startIndex...startTimeStringDescription.index(startTimeStringDescription.startIndex, offsetBy: 3)
        let monthRange = startTimeStringDescription.index(startTimeStringDescription.startIndex, offsetBy: 5)...startTimeStringDescription.index(startTimeStringDescription.startIndex, offsetBy: 6)
        let dayRange = startTimeStringDescription.index(startTimeStringDescription.startIndex, offsetBy: 8)...startTimeStringDescription.index(startTimeStringDescription.startIndex, offsetBy: 9)
        
        let dateOfGame = startTimeStringDescription[yearRange] + startTimeStringDescription[monthRange] + startTimeStringDescription[dayRange]
        
        let gameID = user.username + String(user.totalNumberOfGamesPosted + 1)
        let gameReference = gamesDatabaseReference.child("\(dateOfGame)/\(gameID)")
        
        gameReference.child("admin").setValue(user.username)
        gameReference.child("sport").setValue(sport)
        gameReference.child("locationAddress").setValue(address!)
        gameReference.child("locationLatitude").setValue(latitude!)
        gameReference.child("locationLongitude").setValue(longitude!)
        gameReference.child("startTime").setValue(startTime!.description)
        gameReference.child("endTime").setValue(endTime!.description)
        gameReference.child("maxParticipants").setValue(maxParticipants!)
        gameReference.child("additionalInfo").setValue(additionalInfo ?? "")
        gameReference.child("users").setValue([user.username])
        
        // Notify user that new game has been posted
        user.postedNewGame()
        
        // Dismiss game creation VC stack
        dismiss(animated: true, completion: nil)
    }
    
    
    deinit {
        listOfSportsTableViewController = nil
        locationViewController = nil
        timingsViewController = nil
        additionalInfoViewController = nil
    }
}

// Delegate will responsible for storing the sport
protocol GameCreationDelegate: class {
    // Required input from user to create game
    var sport: String { get set }
    var address: String? { get set }
    var latitude: Double? { get set }
    var longitude: Double? { get set }
    var startTime: Date? { get set }
    var endTime: Date? { get set }
    var maxParticipants: Int? { get set }
    var additionalInfo: String? { get set }
    
    // Normally, VCs are popped when the user goes back in the navigation stack.
    // Need to keep strong references to VCs in the game creation sequence when user is navigating back and forth in the sequence.
    // This helps preserve the changes that the user has made.
    var listOfSportsTableViewController: ListOfSportsTableViewController? { get set }
    var locationViewController: LocationViewController? { get set }
    var timingsViewController: TimingsViewController? { get set }
    var additionalInfoViewController: AdditionalInfoViewController? { get set }
    
    // Methods for pushing VCs on to the navigation stack if they've been previously saved.
    func pushLocationViewControllerOnToNavigationStack()
    func pushTimingsViewControllerOnToNavigationStack()
    func pushAdditionalInfoViewControllerOnToNavigationStack()
    
    // Needed when the user completes the game creation sequence.
    func postGame()
}

