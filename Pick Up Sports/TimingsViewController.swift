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
            // Since the time intervals for the date picker are 5 minutes apart, round up to the nearest 5 min mark after adding the 15 minutes. Ex: if current time is 03:22:32, return 03:40:00
            let currentDate = Date()
            let timeIntervalSince1970 = currentDate.timeIntervalSince1970
            let fiveMinutesInSeconds = 300.0
            let totalSecondsAfterPreviousFiveMinuteMark = timeIntervalSince1970.truncatingRemainder(dividingBy: fiveMinutesInSeconds)
            if totalSecondsAfterPreviousFiveMinuteMark < 60.0 {
                return Date(timeIntervalSince1970: timeIntervalSince1970 + 900.0)
            }
            return Date(timeIntervalSince1970: timeIntervalSince1970 - totalSecondsAfterPreviousFiveMinuteMark + 1200.0)
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
        }
    }
    @IBOutlet weak var endTimeDatePicker: UIDatePicker! {
        didSet {
            endTimeDatePicker.minuteInterval = 5
            endTimeDatePicker.isUserInteractionEnabled = false
        }
    }
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var setTimingsButton: UIButton!
    @IBOutlet weak var coverView: UIView!
    
    //MARK: Actions
    @IBAction func setStartTime(_ sender: UIButton) {
        
        guard let buttonLabelText = startTimeButton.titleLabel?.text else {
            return
        }
        
        if buttonLabelText == "Change Start Time" {
            coverEndTimeDatePicker()
            endTimeDatePicker.isUserInteractionEnabled = false
            startTimeDatePicker.isUserInteractionEnabled = true
            startTimeButton.setTitle("Set Start Time", for: .normal)
            setStartDateConstraints()
        }
        
        guard buttonLabelText == "Set Start Time" else {
            return
        }
        
        // check date validity
        guard startDateIsValid(date: startTimeDatePicker.date) else {
            // give user warning about startDate being invalid.
            setStartDateConstraints() // update constraints
            return
        }
        
        // set date
        dateOfStartTime = startTimeDatePicker.date
        
        // and disable startTimeDatePicker
        coverStartTimeDatePicker()
        startTimeDatePicker.isUserInteractionEnabled = false
        
        // enable endTimeDatePicker to be set
        endTimeDatePicker.isUserInteractionEnabled = true
        
        // change the text on the button (ex: "Change start time")
        startTimeButton.setTitle("Change Start Time", for: .normal)
        
        // set constraints for endDateTimePicker
        setEndDateConstraints()
    }
    
    @IBAction func setTimings(_ sender: UIButton) {
        let timeIntervalBetweenCurrentDateAndStartDate = dateOfStartTime.timeIntervalSince(Date())
        guard timeIntervalBetweenCurrentDateAndStartDate > 840.001 else {
            let alert = UIAlertController(title: "Start Date Invalid", message: "Time must be at least 15 minutes ahead of current Time.", preferredStyle: .alert)
            let acceptAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(acceptAction)
            present(alert, animated: true, completion: nil)
            return
        }
        
        // save end time
        dateOfEndTime  = endTimeDatePicker.date
        
        // SAVE (START AND END TIME) SELECTION TO MODEL
        
        // segue to additional info
        performSegue(withIdentifier: "setAdditionalInfo", sender: self)
    }
    
    //MARK: Methods
    
    override func viewDidLoad() {
        setStartDateConstraints()
        startTimeDatePicker.setDate(startTimeDatePicker.minimumDate!, animated: true)
    }
    
    func setStartDateConstraints() {
        startTimeDatePicker.minimumDate = DateConstraints.minimumDateFromNow
        startTimeDatePicker.maximumDate = DateConstraints.maximumDateFromNow
    }
    
    func setEndDateConstraints() {
        endTimeDatePicker.minimumDate = Date(timeInterval: 1800.0, since: dateOfStartTime) // minimum time of 30 min
        endTimeDatePicker.maximumDate = Date(timeInterval: 43200.0, since: dateOfStartTime) // maximum time of 12 hours
    }
    
    func startDateIsValid(date: Date) -> Bool {
        let timeIntervalFromNowToChosenDate = startTimeDatePicker.date.timeIntervalSince(Date())
        if timeIntervalFromNowToChosenDate < DateConstraints.minimumTimeIntervalFromNow {
            return false
        }
        return true
    }
    
    // Called when setting endTimeDatePicker
    func coverStartTimeDatePicker() {
        let localCoverView: UIView = coverView
        UIView.animate(withDuration: 0.3) {
            localCoverView.frame = CGRect(x: localCoverView.frame.origin.x,
                                          y: localCoverView.superview!.bounds.height * CoverViewFrameOptions.yPositionRatioToSuperViewHeightForCoveringStartTimeDatePicker,
                                          width: localCoverView.frame.width,
                                          height: localCoverView.frame.height * CoverViewFrameOptions.heightRatioOfStartTimeCoverToEndTimeCover)
        }
    }
    
    // Called when setting startTimeDatePicker
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
