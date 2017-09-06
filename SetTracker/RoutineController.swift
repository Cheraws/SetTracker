//
//  RoutineController.swift
//  SetTracker
//
//  Created by Robert Chang on 8/23/17.
//  Copyright © 2017 Robert. All rights reserved.
//

import UIKit
import Foundation
import CoreData


class RoutineController: UITableViewController, RepViewControllerDelegate, SearchControllerDelegate {


    
    var exercises = [NSManagedObject]()
    
    override func viewDidLoad(){

        loadItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editItems(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addItem(_:)))
        super.viewDidLoad()
        title = "Exercise Set"
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            exercises.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .right)
        }
        
    }
    
    @IBAction func unwindToRoutine(segue:UIStoryboardSegue) {
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "searchExercise" {
            if let navigationController = segue.destination as? UINavigationController,
                let searchController = navigationController.viewControllers.first as? SearchController {
                
            }
        }
    }
    
    func controller(controller: RepViewController, name: [String]) {

    }
    
    func controller(controller: SearchController) {

    }
    
    func addEntry(exercise: Exercise){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Exercise2",
                                                in: managedContext)!
        let value = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        value.setValue(exercise.name, forKeyPath: "name")
        value.setValue(exercise.weight, forKeyPath: "weight")
        value.setValue(exercise.equipment, forKeyPath: "equipment")
        value.setValue(exercise.reps, forKeyPath: "reps")
        exercises.append(value)
        do {
            try managedContext.save()
            exercises.append(value)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        print("Size is " + String(exercises.count))
        //tableView.insertRows(at: [IndexPath(row: (exercises.count - 1), section: 0)], with: .none)
    }
    
    func addItem(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "searchExercise", sender: self)
    }
    
    func loadItem(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Exercise2")
        do {
            exercises = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    fileprivate func pathForItems() -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        if let documents = paths.first, let documentsURL = URL(string: documents) {
            return documentsURL.appendingPathComponent("items").path
        }
        
        return nil
    }
    
    func editItems(_ sender:UIBarButtonItem){
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue Reusable Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // Fetch Item
        let exercise = exercises[(indexPath as NSIndexPath).row]
        
        // Configure Table View Cell
        cell.textLabel?.text = exercise.value(forKeyPath: "name") as? String
        cell.detailTextLabel?.text = (exercise.value(forKeyPath: "equipment") as? String)! +
        "," + (exercise.value(forKeyPath: "weight") as? String)! + "," + (exercise.value(forKeyPath: "reps") as? String)!
        
        
        cell.accessoryType = .detailDisclosureButton
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
}
