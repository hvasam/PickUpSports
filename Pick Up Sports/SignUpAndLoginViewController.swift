//
//  SignUpAndLoginViewController.swift
//  Pick Up Sports
//
//  Created by Harshavardhan Vasam on 2017-03-25.
//  Copyright © 2017 Harshavardhan Vasam. All rights reserved.
//

import UIKit
import Firebase

class SignUpAndLoginViewController: UIViewController, UITextFieldDelegate {

    //MARK: Properties
    private var userMode = 0 // 0 for sign up, 1 for login
    private let loginModeName = "Login"
    private let signUpModeName = "Sign Up"
    private let switchToLoginModeString = "Don't have an account? Sign up"
    private let switchToSignUpModeString = "Already have an account? Login"
    private var firstTimeSetup = true
    private var usersDatabaseReference: FIRDatabaseReference? = nil
    private var selectedTextField: UITextField?
    lazy var positionOfViewBeforeKeyboardDidShow: CGPoint = {
        return self.view.frame.origin
    }()
    
    //MARK: Outlets
    @IBOutlet weak var userInfoContainerView: UIView!
    @IBOutlet weak var username: UITextField! {
        didSet {
            username.delegate = self
        }
    }
    @IBOutlet weak var email: UITextField! {
        didSet {
            email.delegate = self
        }
    }
    @IBOutlet weak var password: UITextField! {
        didSet {
            password.delegate = self
        }
    }
    @IBOutlet weak var signUpAndLoginButton: UIButton!
    @IBOutlet weak var switchModeButton: UIButton!
    
    //MARK: Constraint Outlet
    @IBOutlet weak var usernameTopConstraint: NSLayoutConstraint!
    
    //MARK: Actions
    // Only two possible modes: sign up, or login
    @IBAction func signUpOrLogin(_ sender: UIButton) {
        // Ensure that the required info has been provided
        if anyEmptyFieldsInMode(userMode) {
            alertForError("Insufficient Information", withMessage: "Make sure that you have provided the required information to continue.")
            return
        }
 
        if userMode == 0 {
            // User creation process
            
            // Strictly ensures usernames only contain alphabetical characters (upper and lower case) and numbers
            guard usernameIsValid(name: username.text!) else {
                alertForError("Invalid Username", withMessage: "Must contain only letters and numbers.")
                return
            }
            
            // The following method begins the process of signing up a new user
            signUp()
        }
        else {
            // Sign in with given credentials
            signIn()
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
        
        // Manage view tranlation when keyboard appears
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    }
    
    //MARK: UITextField delegate methods + keyboard handling methods

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        selectedTextField = textField
        return true
    }
    
    func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let selectedTextField = self.selectedTextField else { return }
        let padding = selectedTextField.frame.size.height
        let positionOfBottomOfTextFieldWithPadding = (selectedTextField.superview?.convert(selectedTextField.frame.origin, to: self.view))!.y + selectedTextField.frame.size.height + padding
        if positionOfBottomOfTextFieldWithPadding > keyboardRect.origin.y {
            view.frame.origin.y = positionOfViewBeforeKeyboardDidShow.y - ((selectedTextField.superview?.convert(selectedTextField.frame.origin, to: self.view))!.y - (keyboardRect.origin.y -  2 * selectedTextField.frame.size.height))
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.frame.origin = self!.positionOfViewBeforeKeyboardDidShow
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Begins the process of signing up new users
    func signUp() {
        // Anonymous sign-in required to access users database for email/username info.
        anonymousSignIn()
    }
    
    // Anonymous sign-in required to access users database for email/username info.
    func anonymousSignIn() {
        FIRAuth.auth()?.signInAnonymously { [weak self] (user, error) in
            // Keep the users node synchronized by creating a database ref to it
            self?.usersDatabaseReference = FIRDatabase.database().reference().child("users")
            
            // what does it mean to keep synced? Sychronized with offlines writes? Or, synchronized with remote database changes? Or, both?
            // Offline writes should NOT be allowed at any point in the app
            self?.usersDatabaseReference?.keepSynced(false)
            
            // query the database to see if the username is available
            self?.checkUsernameAvailability()
        }
    }
    
    // Query the database to see if the username is available
    func checkUsernameAvailability() {
        self.usersDatabaseReference?.child(self.username.text!).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() { // snapshot.exists() returns true when snapshot value contains a non-null value
                self.alertForError("Invalid Username", withMessage: "Username has already been taken.")
                self.clearAllFields()
            }
            
            // Delete anonymous user after use
            self.deleteUser(snapshot: snapshot)
        })
    }
    
    // Delete anonymous user after use
    func deleteUser(snapshot: FIRDataSnapshot) {
        FIRAuth.auth()?.currentUser?.delete(completion: { (error) in
            if error != nil {
                // anon user could not be deleted
                // the uid should be stored and sent to the app database for clean up when network connectivity resumes?
            }
            
            // ensures snapshot value must be null
            guard !snapshot.exists() else { return }
            
            // Create new user in Firebase
            self.createUser()
        })
    }
    
    // Create new user in Firebase
    func createUser() {
        FIRAuth.auth()?.createUser(withEmail: self.email.text!, password: self.password.text!) { [weak self] (user: FIRUser?, error: Error?) -> Void in
            if let error = error {
                self?.clearAllFields()
                // Error in creating user in Firebase
                let userInfo = error.localizedDescription
                
                // Try to create a valid error
                guard let error = FIRAuthErrorCode(rawValue: error._code) else {
                    self?.alertForError("Unknown Error", withMessage: "Try again.")
                    return
                }
                
                switch error {
                case .errorCodeInvalidEmail:
                    self?.alertForError("Invalid Email", withMessage: "Please use a valid email.")
                case .errorCodeEmailAlreadyInUse:
                    self?.alertForError("Email Already In Use", withMessage: "Please register with a different email.")
                case .errorCodeNetworkError:
                    self?.alertForError("Network Error", withMessage: "Check your connection.")
                case .errorCodeWeakPassword:
                    self?.alertForError("Weak Password", withMessage: "\(userInfo)")
                default:
                    self?.alertForError("Unknown Error", withMessage: "Please try again.")
                }
                return
            }
            
            // Set displayname of the user in Auth/Users
            guard let user = user else { return }
            let nameSetupRequest = user.profileChangeRequest()
            nameSetupRequest.displayName = self?.username.text!
            nameSetupRequest.commitChanges { (error) in
                if error != nil {
                    // has no implications within the app currently
                }
            }
            
            // Create user in database
            self?.usersDatabaseReference?.child(self!.username.text!).setValue(["email": self!.email.text!])
            
            // Send email verification
            self?.sendEmailVerification()
            
            // Clear all text fields
            self?.clearAllFields()
        }
    }
    
    // Send email verification
    func sendEmailVerification() {
        FIRAuth.auth()?.currentUser?.sendEmailVerification { [weak self] (error) in
            if error != nil {
                // Error in sending email verification
                self?.alertForError("Contact Support", withMessage: "Verification email was not sent.")
            }
            else {
                self?.alertForError("Email Verification Sent", withMessage: "Please verify your email address.")
            }
        }
    }
    
    // Sign in existing user with given credentials
    func signIn() {
        // Validate credentials in firebase
        FIRAuth.auth()?.signIn(withEmail: email.text!, password: password.text!) { [weak self] (user, error) in
            if let error = error {
                self?.clearAllFields()
                // failure scenarios?:
                
                guard let error = FIRAuthErrorCode(rawValue: error._code) else {
                    self?.alertForError("Unknown Error", withMessage: "Try again.")
                    return
                }
                switch error {
                case .errorCodeInvalidEmail:
                    self?.alertForError("Invalid Email Address", withMessage: "Please try again.")
                case .errorCodeWrongPassword:
                    self?.alertForError("Incorrect Password", withMessage: "Please try again.")
                case .errorCodeNetworkError:
                    self?.alertForError("Network Error", withMessage: "Check your connection.")
                default:
                    self?.alertForError("Unknown Error", withMessage: "Please try again.")
                }
                return
            }
            
            // check if email has been verified
            guard let user = user else { return }
            guard user.isEmailVerified else {
                self?.alertForError("Unverified Email Address", withMessage: "Complete the verification steps sent to your email.")
                return
            }
            
            // success scenario:
            // create user object for reference
            guard let providerData = FIRAuth.auth()?.currentUser?.providerData,
                  providerData.count > 0,
                  let username = providerData[0].displayName,
                  let email = providerData[0].email,
                  let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            var totalNumberOfGamesPosted = 0
            FIRDatabase.database().reference().child("users/\(username)/totalNumberOfGamesPosted").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    totalNumberOfGamesPosted = snapshot.value as! Int
                    appDelegate.user = User(email: email, username: username, totalNumberOfGamesPosted: totalNumberOfGamesPosted)
                }
            })
            
            // reset login VC
            self?.clearAllFields()
            
            // segue to successful sign-in VC
            self?.performSegue(withIdentifier: "segue", sender: self)
        }
    }

    // Alerts builder method
    func alertForError(_ error: String, withMessage message: String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(acceptAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Helper Methods
    // Checks to see if any of the relevant (sign-up vs sign-in) fields are empty
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
    
    // Clears all user-info text fields
    func clearAllFields() {
        username.text = ""
        email.text = ""
        password.text = ""
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
