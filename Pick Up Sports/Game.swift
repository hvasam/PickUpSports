//
//  Game.swift
//  Pick Up Sports
//
//  Created by Harshavardhan Vasam on 2017-04-02.
//  Copyright © 2017 Harshavardhan Vasam. All rights reserved.
//

import Foundation

struct Sport {
    static let badminton = "Badminton"
    static let basketball = "Basketball"
    static let football = "Football"
    static let rugby = "Rugby"
    static let soccer = "Soccer"
    static let softball = "Softball"
    static let tennis = "Tennis"
    static let ultimate = "Ultimate"
    static let volleyball = "Volleyball"
}

struct Game {
    let id: String // unique identifier of each game - the key to access data in Firebase (path: "games/gameDate/id") - this will act as the key
    
    // the remaining properties are children of the id key in Firebase
    let admin: String // username of user who created/posted the game
    let sport: String // type of sport
    var locationAddress: String // valid address
    var locationLatitude: String
    var locationLongitude: String
    var startTime: String // YYYYMMDDHHMM
    var endTime: String // YYYYMMDDHHMM
    var maxParticipants: Int // Max number of people wanted at game
    var additionalInfo: String // String containing additional information that the admin posted
    var users: [String] // users who are coming to game
    var usersGuestNumber: [String: Int] // the number of additional people each user is beinging
    var currentNumberOfParticipants: Int // number of users who are coming to the game + the number of people they're bringing
}
