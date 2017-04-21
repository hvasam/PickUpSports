//
//  TimingsViewController.swift
//  Pick Up Sports
//
//  Created by Harshavardhan Vasam on 2017-04-15.
//  Copyright © 2017 Harshavardhan Vasam. All rights reserved.
//

import UIKit

class TimingsViewController: UIViewController {
    
    struct DateConstraints {
        static let minimumTimeIntervalFromNow: TimeInterval = 840.001
        static let maximumTimeIntervalFromNow: TimeInterval = 1210040.001
        static var minimumDateFromNow: Date {
            // Returns date that is 15 minutes ahead of current Time (HH:MM:SS), ex: if current time is 13:30:44, returns 13:45:00
            // Since the time intervals for the date picker are 5 minutes apart, round up to the nearest 5 min mark after adding the 15 minutes. Ex: current time is 03:22:32, returned time would be 03:40:00
            let currentDate = Date()
            let timeIntervalSince1970 = currentDate.timeIntervalSince1970
            let fiveMinutesInSeconds = 300.0
            let totalSecondsAfterPreviousFiveMinuteMark = timeIntervalSince1970.truncatingRemainder(dividingBy: fiveMinutesInSeconds)
            if totalSecondsAfterPreviousFiveMinuteMark < 60.0 {
                return Date(timeIntervalSince1970: timeIntervalSince1970 + 900.0)
            }
            return Date(timeIntervalSince1970: timeIntervalSince1970 + 1200.0)
        }
        static var maximumDateFromNow: Date {
            return Date(timeIntervalSinceNow: 1210000.0) // 1210000 seconds = 14 days
        }
    }
    
    struct CoverViewFrameOptions {
        static let yPositionRatioToSuperViewHeightForCoveringStartTimeDatePicker = CGFloat(0.0)
        static let yPositionRatioToSuperViewHeightForCoveringEndTimeDatePicker = CGFloat(0.5)
        static let heightRatioOfStartTimeCoverToEndTimeCover = CGFloat(0.85)
        static let heightRatioOfEndTimeCoverToStartTimeCover = CGFloat(1/0.85)
    }
    
    //MARK: Properties
    var dateOfStartTime = Date()
    var dateOfEndTime = Date()
    
    //MARK: Outlets
    @IBOutlet weak var startTimeDatePicker: UIDatePicker! {
        didSet {
            startTimeDatePicker.minuteInterval = 5
            startTimeDatePicker.minimumDate = DateConstraints.minimumDateFromNow
            startTimeDatePicker.maximumDate = DateConstraints.maximumDateFromNow
        }
    }
    @IBOutlet weak var endTimeDatePicker: UIDatePicker! {
        didSet {
            endTimeDatePicker.minuteInterval = 5
            endTimeDatePicker.isUserInteractionEnabled = false
        }
    }
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var setTimingsButton: UIButton! {
        didSet {
            setTimingsButton.isUserInteractionEnabled = false
        }
    }
    @IBOutlet weak var coverView: UIView!
    

    // have to make user choose start time that is at least 5 minutes ahead of current time
    // the end time cannot be more than 12 hours ahead of start timed
    
    //MARK: Actions
    @IBAction func setStartTime(_ sender: UIButton) {
        
        print("0")
        
        guard let buttonLabelText = startTimeButton.titleLabel?.text else {
            return
        }
        
        print("1")
        
        if buttonLabelText == "Change Start Time" {
            // discard any previously saved values
            coverEndTimeDatePicker()
            endTimeDatePicker.isUserInteractionEnabled = false
            startTimeDatePicker.isUserInteractionEnabled = true
            startTimeButton.setTitle("Set Start Time", for: .normal)
            setDateConstraints()
        }
        
        print("2")
        
        guard buttonLabelText == "Set Start Time" else {
            return
        }
        
        print("3")
        
        // check date validity
        guard startDateIsValid(date: startTimeDatePicker.date) else {
            // give user warning about startDate being invalid.
            setDateConstraints() // update constraints
            return
        }
        
        print("4")
        
        // set date
        dateOfStartTime = startTimeDatePicker.date
        
        // and disable startTimeDatePicker
        coverStartTimeDatePicker()
        startTimeDatePicker.isUserInteractionEnabled = false
        
        // enable endTimeDatePicker to be set
        endTimeDatePicker.isUserInteractionEnabled = true
        
        // change the text on the button (ex: "Change start time")
        startTimeButton.setTitle("Change Start Time", for: .normal)
    }
    
    @IBAction func setTimings(_ sender: UIButton) {
        // SAVE (START AND END TIME) SELECTION TO MODEL
        
        // segue to additional info
        performSegue(withIdentifier: "setAdditionalInfo", sender: self)
    }
    
    //MARK: Methods
    
    override func viewDidLoad() {
         startTimeDatePicker.setDate(startTimeDatePicker.minimumDate!, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setDateConstraints()
    }
    
    func setDateConstraints() {
        startTimeDatePicker.minimumDate = DateConstraints.minimumDateFromNow
        startTimeDatePicker.maximumDate = DateConstraints.maximumDateFromNow
    }
    
    func startDateIsValid(date: Date) -> Bool {
        print("The startTimeDatePicker date is: \(startTimeDatePicker.date)")
        print("The date is: \(Date())")
        let timeIntervalFromNowToChosenDate = startTimeDatePicker.date.timeIntervalSince(Date())
        print(timeIntervalFromNowToChosenDate)
        if timeIntervalFromNowToChosenDate < DateConstraints.minimumTimeIntervalFromNow {
            return false
        }
        return true
    }
    
    func coverStartTimeDatePicker() {
        let localCoverView: UIView = coverView
        UIView.animate(withDuration: 0.3) {
            localCoverView.frame = CGRect(x: localCoverView.frame.origin.x,
                                          y: localCoverView.superview!.bounds.height * CoverViewFrameOptions.yPositionRatioToSuperViewHeightForCoveringStartTimeDatePicker,
                                          width: localCoverView.frame.width,
                                          height: localCoverView.frame.height * CoverViewFrameOptions.heightRatioOfStartTimeCoverToEndTimeCover)
        }
    }
    
    func coverEndTimeDatePicker() {
        let localCoverView: UIView = coverView
        UIView.animate(withDuration: 0.3) {
            localCoverView.frame = CGRect(x: localCoverView.frame.origin.x,
                                          y: localCoverView.superview!.bounds.height * CoverViewFrameOptions.yPositionRatioToSuperViewHeightForCoveringEndTimeDatePicker,
                                          width: localCoverView.frame.width,
                                          height: localCoverView.frame.height * CoverViewFrameOptions.heightRatioOfEndTimeCoverToStartTimeCover)
        }
    }
}
