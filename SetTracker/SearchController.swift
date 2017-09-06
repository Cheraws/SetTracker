//
//  SearchController.swift
//  FairHelper
//
//  Created by Robert Chang on 12/8/16.
//  Copyright © 2016 Robert. All rights reserved.
//

import UIKit


extension String {
    
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    
}
protocol SearchControllerDelegate {
    func controller(controller: SearchController)
    
}


class SearchController: UITableViewController, UISearchResultsUpdating {
    

    
    var items = [Item]()
    var originalItems = [Item]()
    var exercise: String?
    @IBOutlet var searchController: UISearchController!
    
    var delegate: SearchControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Exercises"
        
        let path = Bundle.main.url(forResource: "exercises", withExtension: "txt")
        //loading list of Companies
        do{
            let text2 = try String(contentsOf: path!, encoding: String.Encoding.utf8)
            let values = text2.components(separatedBy: "\n")
            for name in values{
                if(name == ""){
                    continue
                }
                
                let item = Item(name: name.lowercased())
                items.append(item)
                //tableView.insertRows(at: [IndexPath(row: (items.count - 1), section: 0)], with: .none)
                
            }
        }
        catch{
            print("error")
        }
        originalItems = items
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.back(_:)))
        
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        // Do any additional setup after loading the view.
    }
    func editItems(_ sender:UIBarButtonItem){
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    @IBAction func back(_ sender:UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "Rep"){
            let controller = segue.destination as! UINavigationController
            let repController = controller.viewControllers.first as! RepViewController
            repController.name = self.exercise
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = item.name
        return cell
    }
    
    fileprivate func loadItems() {
        if let filePath = pathForItems() , FileManager.default.fileExists(atPath: filePath) {
            if let archivedItems = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [Item] {
                items = archivedItems
                print (filePath)
            }
        }
    }
    
    func saveItems() {
        if let filePath = pathForItems() {
            NSKeyedArchiver.archiveRootObject(items, toFile: filePath)
        }
    }
    
    fileprivate func pathForItems() -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        if let documents = paths.first, let documentsURL = URL(string: documents) {
            return documentsURL.appendingPathComponent("items2").path
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .right)
            //saveItems()
        }
        
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Item selected")
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        self.exercise = item.name
        //delegate?.controller(controller: self, name: item.name)
        self.performSegue(withIdentifier: "Rep", sender: item.name)
  
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchText: searchController.searchBar.text!)
        print("searching now")
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        if searchText.characters.count == 0{
            items = originalItems
            tableView.reloadData()
            return
        }
        let a = Item(name: searchText)
        var original = [Item]()
        original.append(a)
        let filteredItems = originalItems.filter { exercise in
            return exercise.name.lowercased().contains(searchText.lowercased())
        }
        items = original + filteredItems
        tableView.reloadData()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
