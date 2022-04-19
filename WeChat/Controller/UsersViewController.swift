//
//  UsersViewController.swift
//  WeChat
//
//  Created by Zohaib on 28/03/2022.
//

import UIKit
import Loaf



class UsersViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersCellId", for: indexPath) as! UsersTableViewCell
        let dataItem = users[indexPath.row]["name"]
        cell.setUser(name: dataItem!)
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetedUser = users[indexPath.row]
        self.dismiss(animated: true, completion: { [weak self ] in
            self?.completion?(targetedUser)
            
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
//        if let searchQuery = searchController.searchBar.text {
//            filterUsers(searchQuery: searchQuery)
//        }
        
        
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchQuery = searchController.searchBar.text {
            
            filterUsers(searchQuery: searchQuery)
        }
        
    }
    
    @IBOutlet weak var usersTableView: UITableView!
    
    
    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty : Bool{
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var hasFetched: Bool = false
    var users =  [[String: String]]()
    var results = [[String: String]]()
    var completion : ((([String: String]) -> Void))?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        usersTableView.delegate = self
        usersTableView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Users..."
        searchController.searchBar.delegate = self
        
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        // 5
        definesPresentationContext = true
        self.usersTableView.tableHeaderView = searchController.searchBar

        usersTableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.height)
        
        if !self.checkConnectivity() {
            self.usersTableView.setEmptyView(title: "No Internet Connection.", message: "Please Check Your connection and try again.", image: "connection")
            return
        }
        fetchUsers()
        

        // Do any additional setup after loading the view.
    }
    
    func fetchUsers(){
        LoadingOverlay.shared.showOverlay(view: view)
        DatabaseManager.shared.fetchAllUsers(completion: {[weak self]result in
            LoadingOverlay.shared.hideOverlayView()
            guard let strongSelf = self else{
                return
            }
            
            switch result{
            case .success(let usersCollection):
                if usersCollection.count > 0 {
                    strongSelf.hasFetched = true
                    strongSelf.users = usersCollection
                    strongSelf.usersTableView.reloadData()
                }else{
                    strongSelf.usersTableView.setEmptyView(title: "No Users Found.", message: "No Users Registered At The Moment.", image: "empty")
                    
                }
                
                break
            case .failure(let error):
                strongSelf.usersTableView.setEmptyView(title: "Could Not Fetch Users.", message: "\(error)", image: "connection")
                break
            }
        })
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func filterUsers(searchQuery: String){
        
                
        if hasFetched {
            // Users are already loaded from the firebase database. we just need to filter them.
            filterWithQuery(with: searchQuery)
            
            
        }else{
            // Fetch the users from firebase database and filter
            DatabaseManager.shared.fetchAllUsers(completion: {[weak self]result in
                
                guard let strongSelf = self else{
                    return
                }
                
                switch result{
                case .success(let usersCollection):
                    strongSelf.hasFetched = true
                    strongSelf.users = usersCollection
                    strongSelf.filterWithQuery(with: searchQuery)
                    
                    break
                case .failure(let error):
                    strongSelf.usersTableView.setEmptyView(title: "Could Not Fetch Users.", message: "\(error)", image: "connection")
                    break
                }
            })
        }
    }
    func filterWithQuery(with term: String){
        
        
        self.usersTableView.restore()
        guard hasFetched else {
            return
        }
        
        let filteredResults: [[String: String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else{
                return false
            }
            return name.hasPrefix(term.lowercased())
        })
        self.users = []
        self.users = filteredResults
        self.usersTableView.restore()
        if self.results.isEmpty {
            self.usersTableView.setEmptyView(title: "No users Found.", message: "No users found for the search.", image: "empty")
            return
        }
        self.usersTableView.reloadData()
    }
}
