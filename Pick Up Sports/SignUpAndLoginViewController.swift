//
//  SignUpAndLoginViewController.swift
//  Pick Up Sports
//
//  Created by Harshavardhan Vasam on 2017-03-25.
//  Copyright © 2017 Harshavardhan Vasam. All rights reserved.
//

import UIKit
import Firebase

class SignUpAndLoginViewController: UIViewController {

    //MARK: Properties
    private var userMode = 0 // 0 for sign up, 1 for login
    private let loginModeName = "Login"
    private let signUpModeName = "Sign Up"
    private let switchToLoginModeString = "Don't have an account? Sign up"
    private let switchToSignUpModeString = "Already have an account? Login"
    private var firstTimeSetup = true
    private var databaseRef: FIRDatabaseReference? = nil
    private var databaseReference: FIRDatabaseReference? {
        get {
            return databaseRef
        }
        set(newValue) {
            if firstTimeSetup {
                firstTimeSetup = false
            }
            if databaseRef != newValue {
                databaseRef = newValue
            }
        }
    }
    
    
    //MARK: Outlets
    @IBOutlet weak var userInfoContainerView: UIView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signUpAndLoginButton: UIButton!
    @IBOutlet weak var switchModeButton: UIButton!
    
    //MARK: Constraint Outlet
    @IBOutlet weak var usernameTopConstraint: NSLayoutConstraint!
    
    // Only two possible modes: sign up, or login
    
    //MARK: Actions
    
    
    @IBAction func signUpOrLogin(_ sender: UIButton) {
        // Ensure that the required info has been provided
        if anyEmptyFieldsInMode(userMode) {
            alertForError("Insufficient Information", withMessage: "Make sure that you have provided the required information to continue.")
            return
        }
        
        // Unfortunate series of async methods nested together
 
        if userMode == 0 {
            // Create account in firebase
            // check the username availability and validity
            // check if email address is already tied to an account and validity
            // check the password complexity requirement
            
            
            // Usernames can only contain alphabetical letters (upper and lower case) and numbers
            guard usernameIsValid(name: username.text!) else {
                alertForError("Invalid Username", withMessage: "Must contain only letters and numbers.")
                return
            }
            
            // Anonymous user creation and sign in to access the database
            FIRAuth.auth()?.signInAnonymously { [unowned self] (user, error) in
                
                // Keep the users node synchronized by creating a database ref to it
                let usersDatabaseReference = self.databaseReference!.child("users")
                
                // what does it mean to keep synced? Sychronized with offlines writes? Or, synchronized with remote database changes? Or, both? 
                // Offline writes should NOT be allowed at any point in the app
                usersDatabaseReference.keepSynced(false)
                
                // query the database to see if the username is available
                usersDatabaseReference.child(self.username.text!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() { // snapshot.exists() returns true when snapshot value contains a non-null value
                        self.alertForError("Invalid Username", withMessage: "Username has already been taken.")
                    }
        
                    // Delete anonymous user after use
                    FIRAuth.auth()?.currentUser?.delete(completion: { (error) in
                        if error != nil {
                            // anon user could not be deleted
                            // the uid should be stored and sent to the app database for clean up when network connectivity resumes?
                        }
                     
                        // ensures snapshot value must be null
                        guard !snapshot.exists() else { return }
                        
                        // Create new user
                        FIRAuth.auth()?.createUser(withEmail: self.email.text!, password: self.password.text!) { [unowned self] (user: FIRUser?, error: Error?) -> Void in
                            if let error = error {
                                self.clearAllFields()
                                // Error in creating user in Firebase
                                let userInfo = error.localizedDescription
                                
                                // Try to create a valid error
                                guard let error = FIRAuthErrorCode(rawValue: error._code) else {
                                    self.alertForError("Unknown Error", withMessage: "Try again.")
                                    return
                                }
                                
                                switch error {
                                case .errorCodeInvalidEmail:
                                    self.alertForError("Invalid Email", withMessage: "Please use a valid email.")
                                case .errorCodeEmailAlreadyInUse:
                                    self.alertForError("Email Already In Use", withMessage: "Please register with a different email.")
                                case .errorCodeNetworkError:
                                    self.alertForError("Network Error", withMessage: "Check your connection.")
                                case .errorCodeWeakPassword:
                                    self.alertForError("Weak Password", withMessage: "\(userInfo)")
                                default:
                                    self.alertForError("Unknown Error", withMessage: "Please try again.")
                                }
                                return
                            }
                            
                            // Set displayname of the user in Auth/Users
                            guard let user = user else { return }
                            let nameSetupRequest = user.profileChangeRequest()
                            nameSetupRequest.displayName = self.username.text!
                            nameSetupRequest.commitChanges { (error) in
                                if error != nil {
                                    // has no implications within the app currently
                                }
                            }
                            
                            // Create user in database
                            let username = self.username.text!
                            let email = self.email.text!
                            usersDatabaseReference.child(username).setValue(["email": email])
                            
                            // Send email verification
                            FIRAuth.auth()?.currentUser?.sendEmailVerification { [unowned self] (error) in
                                if error != nil {
                                    // Error in sending email verification
                                    usersDatabaseReference.child(username).removeValue() // remove user from database
                                    user.delete(completion: nil) // remove user from auth
                                    self.alertForError("Email Verification Error", withMessage: "Please sign up again.")
                                }
                                else {
                                    self.alertForError("Email Verification Sent", withMessage: "Please verify your email address.")
                                }
                            }
                            
                            // Clear all text fields
                            self.clearAllFields()
                        }
                        
                    })
                    
                })
            }
        }
        else {
            // Validate credentials in firebase
            FIRAuth.auth()?.signIn(withEmail: email.text!, password: password.text!) { [unowned self] (user, error) in
                if let error = error {
                    self.clearAllFields()
                    // failure scenarios?:

                    guard let error = FIRAuthErrorCode(rawValue: error._code) else {
                        fatalError("Error in creating FIRAuthErrorCode during sign-in.")
                    }
                    switch error {
                    case .errorCodeInvalidEmail:
                        self.alertForError("Invalid Email Address", withMessage: "Please try again.")
                    case .errorCodeWrongPassword:
                        self.alertForError("Incorrect Password", withMessage: "Please try again.")
                    case .errorCodeNetworkError:
                        self.alertForError("Network Error", withMessage: "Check your connection.")
                    default:
                        self.alertForError("Unknown Error", withMessage: "Please try again.")
                    }
                    return
                }
                
                // check if email has been verified
                guard let user = user else { return }
                guard user.isEmailVerified else {
                    self.alertForError("Unverified Email Address", withMessage: "Complete the verification steps sent to your email.")
                    return
                }
                
                // success scenario:
                self.clearAllFields()
                self.performSegue(withIdentifier: "segue", sender: self)
            }
        }
    }
    
    @IBAction func switchBetweenLoginAndSignUp(_ sender: UIButton) {
        clearAllFields()
        if userMode == 0 {
            // switch to login mode
        
            username.isHidden = true
            usernameTopConstraint.constant -= self.email.frame.origin.y - self.username.frame.origin.y
            signUpAndLoginButton.setTitle(loginModeName, for: UIControlState.normal)
            switchModeButton.setTitle(switchToLoginModeString, for: UIControlState.normal)
            userMode = 1
        }
        else {
            // switch to sign up mode
            
            username.isHidden = false
            usernameTopConstraint.constant += self.email.frame.origin.y - self.username.frame.origin.y
            signUpAndLoginButton.setTitle(signUpModeName, for: UIControlState.normal)
            switchModeButton.setTitle(switchToSignUpModeString, for: UIControlState.normal)
            userMode = 0
        }
    }
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        FIRDatabase.database().persistenceEnabled = false
        databaseReference = FIRDatabase.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: Helper Methods
    
    func anyEmptyFieldsInMode(_ mode: Int) -> Bool {
        guard let email = email.text else { return true }
        guard let password = password.text else { return true }
        if userMode == 0 {
            guard let username = username.text else { return true }
            return username == "" || email == "" || password == ""
        }
        else {
            return email == "" || password == ""
        }
    }
    
    func clearAllFields() {
        username.text = ""
        email.text = ""
        password.text = ""
    }
    
    func alertForError(_ error: String, withMessage message: String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(acceptAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Helper Methods: Account sign up requirements/validation
    
    
    func usernameIsValid(name: String) -> Bool {
        // check to see if name only contains letters (case insensitive) and numbers
        let lowercaseName = name.lowercased()
        let alphaSet = "qwertyuiopasdfghjklzxcvbnm"
        let numSet = "123456789"
        for character in lowercaseName.characters {
            guard alphaSet.contains(String(character)) || numSet.contains(String(character)) else { return false }
        }
        return true
    }
    
    
    // Coincidentally, the minimum character limit (of 6) happens to be the same restriction that Firebase uses by default
    // Uncomment the following method and add additional requirements if needed
    /*
    func meetsPasswordComplexityRequirements(password: String) -> Bool {
        guard password.characters.count >= 6 else { return false }
        return true
    }
    */

}

