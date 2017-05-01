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
    var locationLatitude: Double
    var locationLongitude: Double
    var startTime: String // YYYYMMDDHHMM
    var endTime: String // YYYYMMDDHHMM
    var maxParticipants: Int // Max number of people wanted at game
    var additionalInfo: String // String containing additional information that the admin posted
    var users: [String] // users who are coming to game
    var usersGuestNumber: [String: Int] // the number of additional people each user is beinging - DOES NOT INCLUDE THE ADMIN'S ADDITIONAL PARTICIPANTS
    var currentNumberOfParticipants: Int // number of users who are coming to the game + the number of participants they've invited - DOES NOT INCLUDE THE ADMIN'S ADDITIONAL PARTICIPANTS
    
    
    // Computed properties for upcoming games table view cells
    var startTimeInDisplayFormat: String {
        let hourRange = startTime.index(startTime.startIndex, offsetBy: 8)...startTime.index(startTime.startIndex, offsetBy: 9)
        let minuteRange = startTime.index(startTime.startIndex, offsetBy: 10)...startTime.index(startTime.startIndex, offsetBy: 11)
        let hourString = startTime[hourRange]
        let minuteString = startTime[minuteRange]
        
        if hourString == "00" {
            return "12:" + minuteString + "am"
        } else if hourString[hourString.startIndex] == "0" {
            return hourString[hourString.index(hourString.startIndex, offsetBy: 1)..<hourString.endIndex] + ":" + minuteString + "am"
        } else if Int(hourString)! < 12 {
            return hourString + ":" + minuteString + "am"
        }
        else {
            let pmHourString = String(Int(hourString)! - 12)
            if pmHourString == "00" {
                return "12:" + minuteString + "pm"
            } else if pmHourString[hourString.startIndex] == "0" {
                return hourString[hourString.index(hourString.startIndex, offsetBy: 1)..<hourString.endIndex] + ":" + minuteString + "pm"
            } else {
                return pmHourString + ":" + minuteString + "pm"
            }
        }
    }
    
    var abbreviatedMonthString: String {
        let monthRange = startTime.index(startTime.startIndex, offsetBy: 4)...startTime.index(startTime.startIndex, offsetBy: 5)
        let month = startTime[monthRange]
        switch month {
        case "01": return "JAN"
        case "02": return "FEB"
        case "03": return "MAR"
        case "04": return "APR"
        case "05": return "MAY"
        case "06": return "JUN"
        case "07": return "JUL"
        case "08": return "AUG"
        case "09": return "SEP"
        case "10": return "OCT"
        case "11": return "NOV"
        case "12": return "DEC"
        default: break
        }
        fatalError("Execution should not reach this point. See abbreviated month string in Game.swift.")
    }
    
    var dayOfStartTime: String {
        let dayRange = startTime.index(startTime.startIndex, offsetBy: 6)...startTime.index(startTime.startIndex, offsetBy: 7)
        return startTime[dayRange]
    }
}
