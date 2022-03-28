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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        conversationsTableView.delegate = self
        conversationsTableView.dataSource = self
        
        if !self.checkConnectivity() {
            conversationsTableView.setEmptyView(title: "No Internet Connection.", message:"Please check your internet connection and try again.", image: "connection")
            
            return
        }
        fetchConversations()
        
        
    }
    
    func fetchConversations(){
        conversationsArray.append(ConversationsModel(title: "Jenny"))
        conversationsArray.append(ConversationsModel(title: "Meclaren"))
        conversationsArray.append(ConversationsModel(title: "Shahzaib"))
        
        conversationsTableView.reloadData()
    }
    
    @IBAction func composeButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "newConversationSegue", sender: self)
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
        let dataItem = conversationsArray[indexPath.row]
        cell.setConversation(conversationItem: dataItem)
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "chatControllerSegue", sender: self)
    }
    
}

