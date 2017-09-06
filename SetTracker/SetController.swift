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

class SetController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addExerciseButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    var exercises: [Exercise] = []
    var set: Set!
    var current: Int = 0
    var started: Bool = false
    var finished: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadExercises()
        title = set.title!
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.back(_:)))
        
        if (set.endDate != nil){
            self.addExerciseButton.isHidden = true
            self.removeButton.isHidden = true
            return
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.startSet(_:)))
    }
    
    
    @IBAction func unwindToSet(segue:UIStoryboardSegue) {
        
    }
    
    
    @IBAction func deleteExercise(_ sender:UIButton){
        tableView.setEditing(!tableView.isEditing, animated: true)
    }

    @IBAction func back(_ sender:UIButton){
        if(started){
            started = false
            self.addExerciseButton.isHidden = false
            self.removeButton.isHidden = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.startSet(_:)))
            self.tableView.reloadData()
            return
        }
        performSegue(withIdentifier: "finishSet", sender: nil)
    }
    
    @IBAction func startSet(_ sender:UIButton){
        print("Starting Set")
        started = true
        self.addExerciseButton.isHidden = true
        self.removeButton.isHidden = true
        self.tableView.reloadData()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.finishSet(_:)))
    }
    
    @IBAction func finishSet(_ sender:UIButton){
        let finishedExercises = exercises.filter { $0.date != nil}
        if(finishedExercises.count != exercises.count){
            let alert = UIAlertController(title: "Alert", message: "Not all exercises have been finished!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            set.endDate = NSDate()
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }

            performSegue(withIdentifier: "finishSet", sender: nil)
        }
    }
    
    @IBAction func addExercise(_ sender:UIButton){
        print("Hi?")
        performSegue(withIdentifier: "searchExercise", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "searchExercise" {
            if let navigationController = segue.destination as? UINavigationController,
                let _ = navigationController.viewControllers.first as? SearchController {
            }
        }
        if segue.identifier == "editExercise"{
            print("editing exercise now")
            if let navigationController = segue.destination as? UINavigationController,
                let repViewController = navigationController.viewControllers.first as? RepViewController {
                let editedExercise = sender as? Exercise
                print(editedExercise!.name ?? "no value?")
                print("??????")
                repViewController.exercise = editedExercise
                repViewController.new = true
                repViewController.name = editedExercise!.name
            }
        }
        if segue.identifier == "finishSet" {
            print("unwinding")
            /*if let setsController = segue.destination as? SetsController {
                setsController.finishSet()
            }*/
        }
    }
    
    func addEntry(exercise: Exercise, new: Bool){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            if (!new){
                set.addToExercises(exercise)
                exercises.append(exercise)
            }
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        self.tableView.reloadData()
        print("Size is " + String(exercises.count) + "in here")
        //tableView.insertRows(at: [IndexPath(row: (exercises.count - 1), section: 0)], with: .none)
    }
    
    func loadExercises(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Exercise")
        print(set.exercises)
        do {
            if(set.exercises == nil){
                return
            }
            print(set.exercises!.count)
            for exercise in set.exercises!{
                exercises.append(exercise as! Exercise)
            }
            //exercises = try managedContext.fetch(fetchRequest) as! [Exercise]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
}

// MARK: - UITableViewDataSource

extension SetController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(started){
            let exercise = exercises[(indexPath as NSIndexPath).row]
            if(exercise.date != nil){
                return
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let date = NSDate()
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            exercise.date = date
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = " HH:mm:ss MM-dd"
            let convertedDate = dateformatter.string(from: (date as Date?)!)
            
            cell.textLabel?.text = exercise.value(forKeyPath: "name") as? String
            cell.detailTextLabel?.text = (exercise.value(forKeyPath: "equipment") as? String)! +
                "," + (exercise.value(forKeyPath: "weight") as? String)! + "," + (exercise.value(forKeyPath: "reps") as? String)! + ",finished at" + convertedDate
            cell.accessoryType = .checkmark
            
        }
        else{
            print("Item selected")
            tableView.deselectRow(at: indexPath, animated: true)
            let item = exercises[indexPath.row]
            self.performSegue(withIdentifier: "editExercise", sender: item)
        }
        
    }
}
extension SetController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue Reusable Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // Fetch Item
        let exercise = exercises[(indexPath as NSIndexPath).row]
        
        // Configure Table View Cell
        var dateText = ""
        if (exercise.date != nil){
            let date = exercise.date
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = " HH:mm:ss MM-dd"
            let convertedDate = dateformatter.string(from: (date as Date?)!)
            dateText = ", finished at" + convertedDate
            cell.accessoryType = .checkmark
        }
        
        cell.textLabel?.text = exercise.value(forKeyPath: "name") as? String
        cell.detailTextLabel?.text = (exercise.value(forKeyPath: "equipment") as? String)! +
            "," + (exercise.value(forKeyPath: "weight") as? String)! + "," + (exercise.value(forKeyPath: "reps") as? String)! + dateText
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            print("deleted")
            let context = appDelegate.persistentContainer.viewContext
            let deleted = exercises[indexPath.row]
            do{
                context.delete(deleted)
                try context.save()
                exercises.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .right)
            }
            catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
        }
    }
    
}
