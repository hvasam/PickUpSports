//
//  User.swift
//  Pick Up Sports
//
//  Created by Harshavardhan Vasam on 2017-04-26.
//  Copyright © 2017 Harshavardhan Vasam. All rights reserved.
//

import UIKit
import Firebase

// When a user signs in, a User object should be created.
// When a user signs out, the User object should be deinitialized.

class User {
    let email: String
    let username: String
    var totalNumberOfGamesPosted: Int // User should not be able to sign in simultaneously from two devices, so this number/property is only updated through one instance of the object at any given time.
    init(email: String, username: String, totalNumberOfGamesPosted: Int) {
        self.email = email
        self.username = username
        self.totalNumberOfGamesPosted = totalNumberOfGamesPosted
    }
    
    func postedNewGame() {
        // update appropriate user properties
        totalNumberOfGamesPosted += 1
        FIRDatabase.database().reference().child("users/\(username)/totalNumberOfGamesPosted").setValue(totalNumberOfGamesPosted)
    }
}
