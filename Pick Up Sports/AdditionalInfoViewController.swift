//
//  AdditionalInfoViewController.swift
//  Pick Up Sports
//
//  Created by Harshavardhan Vasam on 2017-04-17.
//  Copyright © 2017 Harshavardhan Vasam. All rights reserved.
//

import UIKit

class AdditionalInfoViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    //MARK: Properties
    let placeholderTextForAdditionalInfoTextView = "Ex: Looking to play a 7v7 pick up soccer game at Washington Square Park! I am bringing 4 people with me; looking for 10 more people. [User would set the max participants field above to 10 in this case.]"
    let characterLimitForMaxParticipantsTextField = 2
    let characterLimitForAdditionalInfoTextView = 300
    var delegate: GameCreationDelegate?
    var maxParticipants: Int?
    
    //MARK: Outlets
    @IBOutlet weak var infoBox: UIView! {
        didSet {
            infoBox.layer.borderWidth = 3
            infoBox.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
            infoBox.layer.cornerRadius = 3
        }
    }
    
    @IBOutlet weak var maxParticipantsTextField: UITextField! {
        didSet {
            maxParticipantsTextField.backgroundColor = UIColor.clear
            maxParticipantsTextField.layer.borderWidth = 2
            maxParticipantsTextField.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
            maxParticipantsTextField.layer.cornerRadius = 2
            maxParticipantsTextField.text = ""
            maxParticipantsTextField.delegate = self
        }
    }
    
    @IBOutlet weak var additionalInfoTextView: UITextView! {
        didSet {
            additionalInfoTextView.backgroundColor = UIColor.clear
            additionalInfoTextView.layer.borderWidth = 2
            additionalInfoTextView.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
            additionalInfoTextView.layer.cornerRadius = 2
            additionalInfoTextView.text = placeholderTextForAdditionalInfoTextView
            additionalInfoTextView.textColor = UIColor.darkGray
            additionalInfoTextView.delegate = self
        }
    }
    
    //MARK: Actions
    @IBAction func postGame(_ sender: UIButton) {
        // check start time once more
        guard let startTime = delegate?.startTime else {
            return
        }
        let timeIntervalFromCurrentTimeToStartTime = startTime.timeIntervalSince(Date())
        guard timeIntervalFromCurrentTimeToStartTime > 540.001 else {
            // warn user that startTime needs to be edited to a time that is at least 15 min from current time
            let alert = UIAlertController(title: "Start Date Invalid", message: "Start time must be at least 15 minutes ahead of current time. Go back and edit start time.", preferredStyle: .alert)
            let acceptAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(acceptAction)
            present(alert, animated: true, completion: nil)
            return
        }
        
        // save maxParticipants and additionalInfo to delgate
        maxParticipants = Int(maxParticipantsTextField.text ?? "")
        guard maxParticipants != nil else {
            // alert with message about needing a valid int for maxParticipants
            return
        }
        delegate?.maxParticipants = maxParticipants
        if additionalInfoTextView.text != placeholderTextForAdditionalInfoTextView && additionalInfoTextView.text != "" {
            delegate?.additionalInfo = additionalInfoTextView.text
        }
        
        // post game
        delegate?.postGame()
    }
    
    //MARK: Methods
    override func viewDidAppear(_ animated: Bool) {
        guard delegate?.additionalInfoViewController == nil else {
            return
        }
        delegate?.additionalInfoViewController = self
    }
    
    //MARK: UITextFieldDelegate methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let lengthOfStringAfterReplacement = textField.text!.characters.count - range.length + string.characters.count
        maxParticipants = Int(string)
        return lengthOfStringAfterReplacement <= characterLimitForMaxParticipantsTextField && ( maxParticipants != nil || string == "" )
    }
    
    //MARK: UITextViewDelegate methods
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderTextForAdditionalInfoTextView {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = placeholderTextForAdditionalInfoTextView
            textView.textColor = UIColor.darkGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let lengthOfStringAfterReplacement = textView.text.characters.count - range.length + text.characters.count
        return lengthOfStringAfterReplacement <= characterLimitForAdditionalInfoTextView
    }
}
