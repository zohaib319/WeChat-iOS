//
//  ViewController.swift
//  WeChat
//
//  Created by Zohaib on 19/03/2022.
//

import UIKit

class ConversationsViewController: UIViewController {

    @IBOutlet weak var conversationsTableView: UITableView!
    
    var conversationsArray: [ConversationsModel] = []
    var userDefaults = UserDefaults(suiteName: "userDefaults")
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        conversationsTableView.delegate = self
        conversationsTableView.dataSource = self
        
        if !self.checkConnectivity() {
            conversationsTableView.setEmptyView(title: "No Internet Connection.", message:"Please check your internet connection and try again.", image: "connection")
            
            return
        }
        startListiningForConversationsUpdate()
        
        
    }
    
    func startListiningForConversationsUpdate(){
        guard let email = userDefaults?.string(forKey: "user_email") else{
            print("could not get user email")
            return
        }
        let safeEmail = DatabaseManager.getSafeEmail(email: email)
        DatabaseManager.shared.fetchAllConversations(for: safeEmail, completion: {[weak self]result in
            guard let strongSelf = self else{
                print("could not get strong self reference")
                return
            }
            print(result)
            switch(result){
            case .success(let conversations):
                if conversations.isEmpty {
                    strongSelf.conversationsTableView.setEmptyView(title: "No Conversations Here.", message: "You can start a chat by clicking compose button.", image: "empty")
                }else{
                    strongSelf.conversationsArray = conversations
                    DispatchQueue.main.async {
                        strongSelf.conversationsTableView.reloadData()
                    }
                    
                }
            case .failure(let error):
                print("Could not load conversations \(error)")
            }
                
            
            
        })
        
    }
    
    @IBAction func composeButtonClicked(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Dashboard", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "UsersViewController") as! UsersViewController
        nextViewController.modalPresentationStyle = .automatic
        nextViewController.completion = {[weak self] result in
            guard let strongSelf = self else{
                return
            }
            strongSelf.createNewConversation(result: result)
            print(result)
        }
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is UsersViewController {
            let vc = segue.destination as! UsersViewController
            vc.completion = {[weak self] result in
                guard let strongSelf = self else{
                    return
                }
                strongSelf.createNewConversation(result: result)
                print(result)
            }
        }
    }
    
    func createNewConversation(result: [String: String]){
        
        guard let name = result["name"], let email = result["email"] else{
            return
        }
        
        let vc = ChatViewController(with: email, name: name, conversationId: nil, isNewConversation: true)
        vc.title = name
        vc.isNewConversation = true
        vc.otherUserName = name
        navigationController?.pushViewController(vc, animated: true)
        
    }
    

}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conversationsArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationsCellId") as! ConversationTableViewCell
        let conversationItem = conversationsArray[indexPath.row]
        cell.setConversation(conversationItem: conversationItem)
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let email = conversationsArray[indexPath.row].otherUserEmail
        let name = conversationsArray[indexPath.row].name
        let conversationId = conversationsArray[indexPath.row].id
        let vc = ChatViewController(with: email, name: name, conversationId: conversationId, isNewConversation: false)
        vc.title = name
        vc.isNewConversation = false
        vc.otherUserName = name
        navigationController?.pushViewController(vc, animated: true)
    }
}

