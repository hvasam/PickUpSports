//
//  AdditionalInfoViewController.swift
//  Pick Up Sports
//
//  Created by Harshavardhan Vasam on 2017-04-17.
//  Copyright © 2017 Harshavardhan Vasam. All rights reserved.
//

import UIKit

class AdditionalInfoViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

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
    
    //MARK: Properties
    let placeholderTextForAdditionalInfoTextView = "Ex: Looking to play a 7v7 pick up soccer game at Washington Square Park! I am bringing 4 people with me. And, I am also bringing a ball."
    
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
    
    
}
