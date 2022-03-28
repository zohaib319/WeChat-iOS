//
//  SettingsViewController.swift
//  WeChat
//
//  Created by Zohaib on 26/03/2022.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class SettingsViewController: UIViewController {

    let userDefaults = UserDefaults(suiteName: "userDefaults")
    
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userProfilePicture.layer.masksToBounds = true
        userProfilePicture.layer.cornerRadius = userProfilePicture.bounds.width / 2
        
        
        
        
        guard let valueFromDefaults = userDefaults?.string(forKey: "user_profile_picture") else{
            print("no profile picture found in defaults")
            // get download url and download from firebase.
            self.loader.startAnimating()
            self.loader.isHidden = false
            guard let email = userDefaults?.string(forKey: "user_email") else{
                print("no user email found")
                return
            }
            let safeEmail = DatabaseManager.getSafeEmail(email: email)
            print(safeEmail)
            let path = "images/\(safeEmail)_profile_picture.png"
            print(path)
            
            StorageManager.shared.getDownloadURl(from: path, completion: {result in
                switch result{
                case .success(let downloadURL):
                    
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: downloadURL) {
                            DispatchQueue.main.async {
                                self.userProfilePicture.image = UIImage(data: data)
                                self.loader.stopAnimating()
                                self.loader.isHidden = true
                            }
                        }//make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                        else{
                            DispatchQueue.main.async {
                                self.userProfilePicture.image = UIImage(named: "avatar")
                                self.loader.stopAnimating()
                                self.loader.isHidden = true
                            }
                        }
                    }
                    
                    break
                case .failure(let error):
                    print(error)
                    break
                    
                    
                }
            })
            
            
            self.loader.stopAnimating()
            self.loader.isHidden = true
            return
        }
        
        guard let url = URL(string: valueFromDefaults) else{
            print("Invalid URL from defaults")
            userProfilePicture.image = UIImage(named: "avatar")
            self.loader.stopAnimating()
            self.loader.isHidden = true
            return
        }
        
        loader.startAnimating()
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.userProfilePicture.image = UIImage(data: data)
                    self.loader.stopAnimating()
                    self.loader.isHidden = true
                }
            }//make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            else{
                DispatchQueue.main.async {
                    self.userProfilePicture.image = UIImage(named: "avatar")
                    self.loader.stopAnimating()
                    self.loader.isHidden = true
                }
            }
        }
    }
    
    @IBAction func logoutButtonPressewd(_ sender: Any) {
        
        FBSDKLoginKit.LoginManager().logOut()
        do{
            try FirebaseAuth.Auth.auth().signOut()
            AccountController.shared.deleteAccessToken()
            self.dismiss(animated: true, completion: nil)
        }
        catch{
            print("could not logout at the moment.")
        }
        
    }
    


}
