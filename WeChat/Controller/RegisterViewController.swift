//
//  RegisterViewController.swift
//  WeChat
//
//  Created by Zohaib on 19/03/2022.
//

import UIKit
import Loaf
import ImagePicker
import FirebaseAuth


class RegisterViewController: UIViewController, ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        let profileImage = images[0]
        profilePicture.image = profileImage
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
        print("cancelled")
    }
    
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profilePicture: UIImageView!
    
    
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    
    var userDefaults = UserDefaults(suiteName: "userDefaults")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        
        profilePicture.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profilePictureTapped))
        profilePicture.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
    }
    @objc func profilePictureTapped(){
        openImagePicker()
    }
    func openImagePicker(){
        let configuration = ImagePickerConfiguration()
        let imagePickerController = ImagePickerController(configuration: configuration)
        configuration.doneButtonTitle = "Done"
        configuration.noImagesTitle = "No Images to display here."
        configuration.recordLocation = false
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 2
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        validateFields()
    }
    func validateFields(){
        if firstNameTF.text == "" {
            Loaf.init("Please input first name to register.", sender: self).show()
            return
        }
        if lastName.text == "" {
            Loaf.init("Please input last name to register.", sender: self).show()
            return
        }
        if emailTF.text == "" {
            Loaf.init("Please input email to register.", sender: self).show()
            return
        }
        if passwordTF.text == "" {
            Loaf.init("Please input password to register.", sender: self).show()
            return
        }
        
        // register with firebase.
        var safeEmail = self.emailTF.text!.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        /// check if the user already exists with this email
//        DatabaseManager.shared.userExists(email: (safeEmail), completion: {[weak self] exists in
//            print(exists)
//            if exists {
//                Loaf.init("This email already taken.", sender: (self)!).show()
//                return
//            }
            
            
            FirebaseAuth.Auth.auth().createUser(withEmail: (self.emailTF.text!), password: (self.passwordTF.text!), completion: {[weak self]authResult, error in
                guard let result = authResult, error == nil else{
                    
                    Loaf.init(error!.localizedDescription, sender: (self)!).show()
                    return
                }
                let user = result.user
                print("User Created \(user)")
                
                
                // inserting user to firebase database.
                let chatuser = User(firstName: (self?.firstNameTF.text!)!, lastName: (self?.lastName.text!)! , email: (self?.emailTF.text!)!)
                
                self?.userDefaults?.set(self?.emailTF.text!, forKey: "user_email")
                
                DatabaseManager.shared.inserUserIntoFirebaseDatabase(with: chatuser, completion: {done in
                    
                    // User is inserted successfully
                    if done {
                        guard let image = self?.profilePicture.image, let data = image.pngData() else{
                            return
                        }
                        let fileName = chatuser.profilePictureFileName
                        
                        StorageManager.shared.uploadProfilePictureToFirebase(with: data, fileName: fileName, completion: {result in
                            switch result{
                            case .success(let downloadURL):
                                print("\(downloadURL)")
                                self?.userDefaults?.set(downloadURL, forKey: "user_profile_picture")
                                self?.userDefaults?.synchronize()
                                break
                            case .failure(let error):
                                print("Storage Manager Error \(error)")
                                break
                            }
                        })
                        
                    }
                })
                
                AccountController.shared.save(accessToken: user.uid)
                let storyBoard : UIStoryboard = UIStoryboard(name: "Dashboard", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "UserDashboardViewController") as! UserDashboardViewController
                nextViewController.modalPresentationStyle = .fullScreen
                self?.present(nextViewController, animated:true, completion:nil)
            })
            
            
        
        
        
        
    }
    
}
