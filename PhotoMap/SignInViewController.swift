//
//  SignInViewController.swift
//  PhotoMap
//
//  Created by LunJohnZhang on 2018/11/19.
//  Copyright © 2018 Yulun Zhang. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController, UITextFieldDelegate {

    // user model
    private var data = DataModel.sharedInstance
    
    // IB outlets
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var SignInButton: UIButton!
    @IBOutlet weak var backImage: UIImageView!
    
    // adjust style of status bar
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SignInButton.isEnabled = false;
        SignInButton.alpha = 0.5
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backImage.image = Helper.helper.getBackground()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailTF.isFirstResponder {
            emailTF.resignFirstResponder()
            passwordTF.becomeFirstResponder()
        }
        else{
            passwordTF.resignFirstResponder()
        }
        endableSigninButton()
        return true
    }
    

    func endableSigninButton(){
        if let emailText = emailTF.text, let passwordText = passwordTF.text{
            if(emailText.count > 0 && passwordText.count > 0){
                SignInButton.isEnabled = true
                SignInButton.alpha = 1
            }
            else {
                SignInButton.isEnabled = false
                SignInButton.alpha = 0.5
            }
        }
    }
    
    @IBAction func BackgroundTapped(_ sender: UITapGestureRecognizer) {
        emailTF.resignFirstResponder()
        passwordTF.resignFirstResponder()
        endableSigninButton()
    }
    
    // IB action to handle sign in
    @IBAction func SignInTapped(_ sender: UIButton) {
        print("sign in tapped!")
        
        // get infor for sign in
        guard let email = emailTF.text else {return}
        guard let password = passwordTF.text else {return}
        
        // log in with password
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil{
                // print error
                print(error!.localizedDescription)
                
                // display error message on an alert
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
            else{
                Helper.helper.SwitchToTabBarVC()
                self.data.setCurrentUser(email: email)
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
