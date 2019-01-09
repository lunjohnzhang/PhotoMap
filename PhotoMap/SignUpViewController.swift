//
//  SignUpViewController.swift
//  PhotoMap
//
//  Created by LunJohnZhang on 2018/11/19.
//  Copyright © 2018 Yulun Zhang. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController, UITextFieldDelegate {

    // user model
    private var data = DataModel.sharedInstance
    
    // IBOutlets
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmTF: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var backImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.alpha = 0.5
        signUpButton.isEnabled = false
    }
    
    // adjust style of status bar
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewWillAppear(_ animated: Bool) {
        backImage.image = Helper.helper.getBackground()
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        // sign up the user
        print("sign up tapped!")
        
        guard let name = nameTF.text else {return}
        guard let email = emailTF.text else {return}
        guard let pass = passwordTF.text else {return}
        guard let confirm = confirmTF.text else {return}
        
        print("pass: \(pass)")
        print("confirm: \(confirm)")
        
        // if password and confirm password are different, let the user enter confirm password again
        if pass != confirm {
            let passwordError = UIAlertController(title: "Error", message: "Passwords do not conform! Please recheck!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let reEnterAction = UIAlertAction(title: "Re-enter", style: .default) {(action) in
                self.confirmTF.becomeFirstResponder()
                self.confirmTF.text = ""
            }
            passwordError.addAction(cancelAction)
            passwordError.addAction(reEnterAction)
            
            self.present(passwordError, animated: true, completion: nil)
            return
        }
        
        // if they are the same, create the user
        // create user in firebase
        Auth.auth().createUser(withEmail: email, password: pass) { user, error in
            // if error = nil and user != nil
            if error == nil && user != nil {
                print("User successfually created")
                
                // resign first responder
                self.nameTF.resignFirstResponder()
                self.emailTF.resignFirstResponder()
                self.passwordTF.resignFirstResponder()
                self.confirmTF.resignFirstResponder()
                
                // add the newly registered user to the plist
                self.data.addUser(newUser: User(name: name, email: email))
                
                // switch to success view
                Helper.helper.SwitchToTabBarVC()
                self.data.setCurrentUser(email: email)
            } else{
                // print the error to console
                print("Error: \(error!.localizedDescription)")
                
                // show the error message to the user using alert
                let errorAlter = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let tryAgainAction = UIAlertAction(title: "Try Again", style: .default, handler: {(action) in
                    self.emailTF.text = ""
                    self.passwordTF.text = ""
                })
                errorAlter.addAction(cancelAction)
                errorAlter.addAction(tryAgainAction)
                self.present(errorAlter, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func BackgroundTapped(_ sender: Any) {
        nameTF.resignFirstResponder()
        emailTF.resignFirstResponder()
        passwordTF.resignFirstResponder()
        confirmTF.resignFirstResponder()
        enableSignUp()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if nameTF.isFirstResponder {
            nameTF.resignFirstResponder()
            emailTF.becomeFirstResponder()
        }
        else if emailTF.isFirstResponder {
            emailTF.resignFirstResponder()
            passwordTF.becomeFirstResponder()
        }
        else if passwordTF.isFirstResponder {
            passwordTF.resignFirstResponder()
            confirmTF.becomeFirstResponder()
        }
        else if confirmTF.isFirstResponder{
            confirmTF.resignFirstResponder()
        }
        enableSignUp()
        return true
    }
    
    func enableSignUp(){
        if let name = nameTF.text, let email = emailTF.text, let password = passwordTF.text, let confirm = confirmTF.text {
            if name.count > 0 && email.count > 0, password.count > 0, confirm.count > 0{
                signUpButton.isEnabled = true
                signUpButton.alpha = 1
            }
            else{
                signUpButton.isEnabled = false
                signUpButton.alpha = 0.5
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
