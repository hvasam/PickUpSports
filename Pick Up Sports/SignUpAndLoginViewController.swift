//
//  SignUpAndLoginViewController.swift
//  Pick Up Sports
//
//  Created by Harshavardhan Vasam on 2017-03-25.
//  Copyright © 2017 Harshavardhan Vasam. All rights reserved.
//

// IMPORTANT: remove all fatalErrors() and substitute them with actual error handling solutions instead of letting the app crash

// RELEVANT ERRORS:
// errorCodeEmailAlreadyInUse = 17007 - Indicates the email used to attempt a sign up is already in use.
// errorCodeInvalidEmail = 17008 - Indicates the email is invalid.
// errorCodeWrongPassword = 17009 - Indicates the user attempted sign in with a wrong password.
// errorCodeRequiresRecentLogin = 17014 - Indicates the user has attemped to change email or password more than 5 minutes after signing in.
// errorCodeWeakPassword = 17026 - Indicates an attempt to set a password that is considered too weak.

// Have to come up with a way to deal with the following:
// Subset of errors that are COMMON to all Firebase apis:
// errorCodeNetworkError = 17020 - Indicates a network error occurred (such as a timeout, interrupted connection, or unreachable host). These types of errors are often recoverable with a retry. The @c NSUnderlyingError field in the NSError.userInfo dictionary will contain the error encountered.
// errorCodeUserNotFound = 17011 - Indicates the user account was not found. This could happen if the user account has been deleted.
// errorCodeUserTokenExpired = 17021 - Indicates the saved token has expired, for example, the user may have changed account password on another device. The user needs to sign in again on the device that made this request.
// errorCodeTooManyRequests = 17010 - Indicates that too many requests were made to a server method. Retry again after some time.
// errorCodeInvalidAPIKey = 17023 - Indicates an invalid API key was supplied in the request.
// errorCodeAppNotAuthorized = 17028 - Indicates the App is not authorized to use Firebase Authentication with the provided API Key.
// errorCodeKeychainError = 17995 - Indicates an error occurred when accessing the keychain. The NSLocalizedFailureReasonErrorKey and NSUnderlyingErrorKey fields in the NSError.userInfo dictionary will contain more information about the error encountered.
// errorCodeInternalError = 17999 - Indicates an internal error occurred.

// Gray area: 
// Auth provider errors? errorCodeProviderAlreadyLinked = 17015 vs errorCodeNoSuchProvider = 17016
// errorCodeInvalidUserToken = 17017 - Indicates user’s saved auth credential is invalid, the user needs to sign in again.
// errorCodeUserMismatch = 17024 - Indicates that an attempt was made to reauthenticate with a user which is not the current user.
// errorCodeInvalidMessagePayload = 17031 - Indicates that there are invalid parameters in the payload during a send password reset * email attempt.
// errorCodeInvalidSender = 17032 - Indicates that the sender email is invalid during a send password reset email attempt.
// errorCodeInvalidRecipientEmail = 17033 - Indicates that the recipient email is invalid.
// errorCodeCredentialTooOld -- deprecated?


import UIKit
import Firebase

class SignUpAndLoginViewController: UIViewController {

    //MARK: Properties
    private var userMode = 0 // 0 for sign up, 1 for login
    private let loginModeName = "Login"
    private let signUpModeName = "Sign Up"
    private let switchToLoginModeString = "Don't have an account? Sign up"
    private let switchToSignUpModeString = "Already have an account? Login"
    private var databaseReference: FIRDatabaseReference? = nil
    private var databaseListenerHandler: UInt = 0
    
    // For testing
    private var numberForChange = 0
    private var changeCount = 0
    
    
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
            
            // Anon sign in
            
            FIRAuth.auth()?.signInAnonymously { [unowned self] (user, error) in
                print("The user id is: \(user?.uid)")
                // Concurrent case: two new users are registering with the same username
                
                self.databaseReference!.child("users").child(self.username.text!).observeSingleEvent(of: .value, with: { [unowned self] (snapshot) in
                    print("The snapshot value is \(snapshot.value)")
                    print("The current user before signOut is \(FIRAuth.auth()?.currentUser)")
                    print("The value of numberForChange is \(self.numberForChange)")
                    self.numberForChange = 350
                    self.changeCount += 1
                    try? FIRAuth.auth()?.signOut()
                    print("The value of numberForChange is \(self.numberForChange)")
                    print("The current user after signOut is \(FIRAuth.auth()?.currentUser)")
                })
            }
            
        
            
            // must query database to ensure that username hasn't been taken
            
            // create a serial dispatch queue to handle user sign-up/login
            // let signUpQueue = DispatchQueue(label: "signUpQueue", qos: DispatchQoS.userInitiated)
        
            /*
            databaseReference?.child("users").observeSingleEvent(of: .value, with: {
                [unowned self] (snapshot) in
                    print("called")
                    if snapshot.value != nil {
                        print("The value of snapshot is: \(snapshot.value)")
                        self.alertForError("Invalid Username", withMessage: "Username has already been taken.")
                        return
                    }
                    print("The value of snapshot is: \(snapshot.value)")
                }
            )
            */
            
            FIRAuth.auth()?.createUser(withEmail: self.email.text!, password: self.password.text!) { [unowned self] (user: FIRUser?, error: Error?) -> Void in
                if let error = error {
                    self.clearAllFields()
                    // Error in creating user in Firebase
                    let userInfo = error.localizedDescription
                    guard let error = FIRAuthErrorCode(rawValue: error._code) else {
                        fatalError("Error in creating FIRAuthErrorCode during user creation.")
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
                }
                
                /*
                // Use the following when additional requirements are added to meetsPasswordComplexityRequirements(password:)
                guard self.meetsPasswordComplexityRequirements(password: self.password.text ?? "") else {
                    // Explain password requirement errors
                    self.alertForError("Weak Password", withMessage: "The password must be 6 characters long or more.")
                    return
                }
                */
                
                guard let user = user else { return }
                let nameSetupRequest = user.profileChangeRequest()
                nameSetupRequest.displayName = self.username.text!
                nameSetupRequest.commitChanges { (error) in
                    if let error = error {
                        // Error in setting display name
                        fatalError("Error in setting display name: \(error)")
                    }
                }
                
                // Send email verification
                FIRAuth.auth()?.currentUser?.sendEmailVerification { (error) in
                    if let error = error {
                        // Error in sending email verification
                        fatalError("Error in sending email verification \(error)")
                    }
                }
                self.alertForError("Email Verification Sent", withMessage: "Please verify your email address.")
                
                // Create user in database
                print("Before creating user in database")
                self.databaseReference!.child("users").child(self.username.text!).setValue(["email": self.email.text!])
                print("After creating user in database")
                self.clearAllFields()
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
        //print("\(self.signUpAndLoginButton.titleLabel?.text)")
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
        databaseReference = FIRDatabase.database().reference()
        // Do any additional setup after loading the view, typically from a nib.
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

