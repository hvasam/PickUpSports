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

struct SkillLevel {
    static let any = "Any"
    static let beginner = "Beginner"
    static let intermediate = "Intermediate"
    static let advanced = "Advanced"
}

struct Game {
    let admin: String // username of user who created/posted the game
    let id: String // unique identifier of each game
    let sport: String // type of sport
    var location: String // valid address
    var startTime: String // YYYYMMDDHHMM // MM can be one of 00, 15, 30, 45
    var endTime: String // Max 12 hours past startTime

    var gameSuspended: Bool // if game suspended by admin - potentially in doubt
    var users: [String] // users who are coming to game
    var usersGuestNumber: [String: Int] // the number of additional people each user is beinging
    var currentNumberOfParticipants: Int // number of users who are coming to the game + the number of people they're bringing
}


// you also have to think about timezones

// Other features you might need/want
/*
 var minParticipantsRequired: Int // Minimum number of people required for game - or None
 var maxParticipants: Int // Max number of people required for game - or None
 var pricePerPerson: Double // if applicable
 var skillLevel: String // skill level of people desired for game
*/
