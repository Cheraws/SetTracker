//
//  TestController.swift
//  SetTracker
//
//  Created by Robert Chang on 9/1/17.
//  Copyright © 2017 Robert. All rights reserved.
//

import Foundation
/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreData

class SetsController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var sets: [Set] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sets"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addSet(_:)))
        loadSets()
        
        print (sets.count)
        
    }
    func reload(){
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(tableView != nil){
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            self.tableView.reloadData()
        }
    }
    
    @IBAction func unwindToSets(segue:UIStoryboardSegue) {
        
    }
    
    
    @IBAction func deleteSet(_ sender:UIButton){
        print("removing set?")
        tableView.setEditing(!tableView.isEditing, animated: true)
        
    }
    
    
    @IBAction func addSet(_ sender:UIButton){
        
        let alertController = UIAlertController(title: "Alert", message: "Add a set", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        let addAction = UIAlertAction(title: "Add", style: .default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            self.createSet(title: firstTextField.text!)
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter title for set"
        }
        alertController.addAction(addAction)
        self.present(alertController, animated: true, completion: nil)
        //tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    func createSet(title: String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let set = Set(context: managedContext)
        set.title = title
        set.startDate = NSDate()
        do {
            try managedContext.save()
            sets.append(set)
            performSegue(withIdentifier: "modifySet", sender: set)
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "modifySet" {
            print("Executed?")
            if let navigationController = segue.destination as? UINavigationController,
                let setController = navigationController.viewControllers.first as? SetController {
                let newSet = sender as! Set
                setController.set = newSet
            }
        }
    }
    
    func addSet(set: Set){
        print("10000")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            try managedContext.save()
            sets.append(set)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        self.tableView.reloadData()
        //tableView.insertRows(at: [IndexPath(row: (exercises.count - 1), section: 0)], with: .none)
    }
    
    func loadSets(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Set")
        do {
            sets = try managedContext.fetch(fetchRequest) as! [Set]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
}

// MARK: - UITableViewDataSource
extension SetsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return sets.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue Reusable Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // Fetch Item
        let set = sets[(indexPath as NSIndexPath).row]
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm:ss yyyy-MM-dd"
        let startDate = dateformatter.string(from: (set.startDate as Date?)!)
        var endDate = ""
        cell.textLabel?.text = set.title!
        var activity = ","

        cell.detailTextLabel?.text = String(set.exercises!.count) + activity + startDate
        if(set.endDate != nil){
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "HH:mm:ss yyyy-MM-dd"
            let endDate = dateformatter.string(from: (set.endDate as Date?)!)

            cell.detailTextLabel?.text = String(set.exercises!.count) + activity + startDate + " to " + endDate
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            sets.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .right)
        }
    }
    
}

extension SetsController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Item selected")
        tableView.deselectRow(at: indexPath, animated: true)
        let item = sets[indexPath.row]
        self.performSegue(withIdentifier: "modifySet", sender: item)
    }
}
