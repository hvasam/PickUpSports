//
//  ViewController.swift
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

class ViewController: UIViewController {

    //MARK: Properties
    private var userMode = 0 // 0 for sign up, 1 for login
    private let loginModeName = "Login"
    private let signUpModeName = "Sign Up"
    private let switchToLoginModeString = "Don't have an account? Sign up"
    private let switchToSignUpModeString = "Already have an account? Login"
    
    
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
        if userMode == 0 {
            // Create account in firebase
            // check the username availability and validity
            // check if email address is already tied to an account and validity?
            // check the password complexity requirement
            
            FIRAuth.auth()?.createUser(withEmail: email.text!, password: password.text!) { [unowned self] (user: FIRUser?, error: Error?) -> Void in
                if let error = error {
                    self.clearAllFields()
                    // Error in creating user in Firebase
                    let userInfo = error.localizedDescription
                    guard let error = FIRAuthErrorCode(rawValue: error._code) else {
                        fatalError("Error in creating FIRAuthErrorCode during user creation.")
                    }
                    
                    switch error {
                    case .errorCodeInvalidEmail:
                        self.alertForError("Invalid Email", withMessage: "Please use a different email.")
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
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: Helper Methods
    
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
    
    /*
    func usernameIsAvailable(name: String) -> Bool {
        
        // check availability
    }
    */
    
    // Coincidentally, the minimum character limit (of 6) happens to be the same restriction that Firebase uses by default
    // Uncomment the following method if addition requirements are needed
    /*
    func meetsPasswordComplexityRequirements(password: String) -> Bool {
        guard password.characters.count >= 6 else { return false }
        return true
    }
    */

}

