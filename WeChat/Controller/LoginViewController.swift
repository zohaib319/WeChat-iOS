//
//  LoginViewController.swift
//  WeChat
//
//  Created by Zohaib on 19/03/2022.
//

import UIKit
import Loaf
import FirebaseAuth
import FBSDKLoginKit


class LoginViewController: UIViewController, LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else{
            Loaf.init("Unable to Login With Facebook At the moment.", sender: self).show()
            return
        }
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, first_name, last_name,  picture.type(large)"],
                                                         httpMethod: .get)
        facebookRequest.start(completion: {connection,result, error in
            guard let facebookRequestResult = result as? [String:Any], error == nil else {
                Loaf.init("Unable to Login With Facebook At the moment.", sender: self).show()
                return
            }
            
            print("\(facebookRequestResult)")
            guard let firstName = facebookRequestResult["first_name"] as? String, let lastName = facebookRequestResult["last_name"] as? String, let fbEmail = facebookRequestResult["email"] as? String,
                  let picture = facebookRequestResult["picture"] as? [String: Any],
                  let pictureData = picture["data"] as? [String: Any],
                  let pictureURl = pictureData["url"] as? String else{
                      Loaf.init("Unable to get user data from facebook.", sender: self).show()
                      return
                  }
            print("picture url is \(pictureURl)")
            self.userDefaults?.set(fbEmail, forKey: "user_email")
            self.userDefaults?.set("\(firstName) \(lastName)", forKey: "username")
            
            let chatUser = User(firstName: firstName, lastName: lastName, email: fbEmail)
            DatabaseManager.shared.userExists(email: fbEmail, completion: {exists in
                
                print(exists)
                
                if !exists {
                    DatabaseManager.shared.inserUserIntoFirebaseDatabase(with: chatUser, completion: {done in
                        
                        if done {
                            guard let url = URL(string: pictureURl) else{
                                print("not a valid url from facebook")
                                return
                            }
                            
                            URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
                                
                                guard let data = data else {
                                    print("cannot convert url to data")
                                    return
                                }
                                let fileName = chatUser.profilePictureFileName
                                
                                StorageManager.shared.uploadProfilePictureToFirebase(with: data, fileName: fileName, completion: {result in
                                    switch result{
                                    case .success(let downloadURL):
                                        print("\(downloadURL)")
                                        self.userDefaults?.set(downloadURL, forKey: "user_profile_picture")
                                        self.userDefaults?.synchronize()
                                        break
                                    case .failure(let error):
                                        print("Storage Manager Error \(error)")
                                        break
                                    }
                                })
                                
                                
                            }).resume()
                        }
                        
                    })
                    
                }
            })
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential){[weak self]authResult, error in
                guard let strongSelf = self else{
                    return
                }
                guard authResult != nil, error == nil else {
                    if let error = error {
                        print("Unable to Login with Facebook at the moment. \(error)")
                    }
                    
                    return
                }
                guard let result = authResult else{
                    return
                }
                let user = result.user
                print("Logged In User \(user)")
                
                // Save User Data.
                // Email etc.
                
                AccountController.shared.save(accessToken: user.uid)
                let storyBoard : UIStoryboard = UIStoryboard(name: "Dashboard", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "UserDashboardViewController") as! UserDashboardViewController
                nextViewController.modalPresentationStyle = .fullScreen
                strongSelf.present(nextViewController, animated:true, completion:nil)
                
                
            }
            
            
        })
        
        
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var loginWithFB: FacebookButton!
    
    let userDefaults = UserDefaults(suiteName: "userDefaults")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerButtonTapped))
        
        loginWithFB.permissions = ["public_profile","email"]
        loginWithFB.delegate = self
        
    }
    
    @objc func registerButtonTapped(){
        self.performSegue(withIdentifier: "registerControllerSegue", sender: self)
    }
    @IBAction func loginButtonPressed(_ sender: Any) {
        validateFields()
    }
    func validateFields(){
        if emailTF.text == "" {
            Loaf.init("Please input email to login.", sender: self).show()
            return
        }
        if passwordTF.text == "" {
            Loaf.init("Please input password to login.", sender: self).show()
            return
        }
        
        // firebase login here.
        FirebaseAuth.Auth.auth().signIn(withEmail: emailTF.text!, password: passwordTF.text!, completion: {[weak self]authResult, error in
            
            guard let strongSelf = self else{
                print("could not get a reference to strong self")
                return
            }
            
            guard let result = authResult, error == nil else{
                print("Error logging in user")
                return
            }
            
            let user = result.user
            print("Logged In User \(user)")
            
            strongSelf.userDefaults?.set(strongSelf.emailTF.text, forKey: "user_email")
            // get username from firebase node.
            
            guard let enteredEmail = strongSelf.emailTF.text else{
                print("user didn't entered email.")
                return
            }
            let safeEmail = DatabaseManager.getSafeEmail(email: enteredEmail)
            
            // query firebase database and get firstname and last name.
            DatabaseManager.shared.getDataFromNode(path: safeEmail, completion: {[weak self]result in
                switch(result){
                case .success(let data):
                    guard let userData = data as? [String: Any] else{
                        print("unable to parse user data")
                        return
                    }
                    guard let firstName = userData["firstName"] as? String,
                          let lastName = userData["lastName"] as? String else{
                              print("could not parse user data")
                              return
                          }
                    self?.userDefaults?.set("\(firstName) \(lastName)", forKey: "username")
                    
                case .failure(let error):
                    print("could not fetch data from node \(error)")
                }
            })
            
            
            AccountController.shared.save(accessToken: user.uid)
            let storyBoard : UIStoryboard = UIStoryboard(name: "Dashboard", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "UserDashboardViewController") as! UserDashboardViewController
            nextViewController.modalPresentationStyle = .fullScreen
            self?.present(nextViewController, animated:true, completion:nil)
        })
    }
    
    @IBOutlet weak var loginWithFBPressed: FacebookButton!
    
}
