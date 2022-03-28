//
//  SplashViewController.swift
//  WeChat
//
//  Created by Zohaib on 19/03/2022.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.goToDashboard()
            
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        self.viewDidAppear(animated)
//        self.goToDashboard()
//    }
    func goToDashboard(){
        
        if let _ = AccountController.shared.accessToken{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Dashboard", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "UserDashboardViewController") as! UserDashboardViewController
            nextViewController.modalPresentationStyle = .fullScreen
            self.present(nextViewController, animated:true, completion:nil)
        }else{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            let navigationController = UINavigationController(rootViewController: nextViewController)
                    navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
    }

}
