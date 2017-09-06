//
//  RepController.swift
//  SetTracker
//
//  Created by Robert Chang on 8/23/17.
//  Copyright © 2017 Robert. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol RepViewControllerDelegate {
    func controller(controller: RepViewController, name: [String])
}

class RepViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    
    @IBOutlet var label: UILabel!
    @IBOutlet var scrollLabel: UILabel!
    @IBOutlet var picker1: UIPickerView!
    @IBOutlet var picker2: UIPickerView!
    @IBOutlet var info: UIButton!
    @IBOutlet var guide: UITextView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    var name: String?
    
    var delegate: RepViewControllerDelegate?
    var data: [String] = []
    var time: [String] = []
    var stats: [String: String]!
    var exercise: Exercise!
    var new: Bool = false

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addToSet" {
            print("unwinding")
            if let setController = segue.destination as? SetController {
                setController.addEntry(exercise: exercise, new: new)
            }
        }
    }
    override func viewDidLoad() {
        title = name!
        
        let tlabel = UILabel(frame: CGRect(x:0, y:0 , width:200, height: 40))
        tlabel.text = self.title
        tlabel.font = UIFont(name: "Helvetica-Bold", size: 30.0)
        tlabel.adjustsFontSizeToFitWidth = true
        self.navigationItem.titleView = tlabel
        
        label = UILabel()
        scrollLabel = UILabel()
        guide = UITextView()
        imageView = UIImageView()
        picker1 = UIPickerView()
        picker2 = UIPickerView()
        scrollView = UIScrollView()
        
        picker1.tag = 1
        picker2.tag = 2
        view.addSubview(label)
        view.addSubview(picker1)
        view.addSubview(picker2)
        view.addSubview(scrollView)
        
        scrollView.addSubview(guide)
        scrollView.addSubview(imageView)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        picker1.translatesAutoresizingMaskIntoConstraints = false
        picker2.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        guide.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.1 * view.frame.height).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addItem(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel
            , target: self, action: #selector(self.cancel(_:)))
        
        let scraper = Scraper()
        scraper.scrapeSite(name:name!) {
            (result: [String: String]) in
            self.generateText(info: result)}
    }
    
    
    func addItem(_ sender: UIBarButtonItem) {
        print("hi?")
        performSegue(withIdentifier: "addToSet", sender: self)
    }
    
    func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion:nil)
    }
    
    func generateText(info: [String: String]) {
        self.stats = info
        label.text = "Equipment:" + info["equipment"]!
        label.textAlignment = NSTextAlignment.center
     
        
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.1 * view.frame.height).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        picker1.delegate = self
        picker1.dataSource = self
        
        picker1.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        picker1.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        picker1.topAnchor.constraint(equalTo:label.bottomAnchor).isActive = true
        picker1.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true
        
        if ((exercise == nil)) {
            print("new exercise")
            exercise = Exercise(context: managedContext)
        
            exercise.name = name!
            exercise.equipment = info["equipment"]
        }
        
        var weight = 0.0
        if (info["equipment"] == "Barbell"){
            weight = 45.0
            if(exercise.weight == nil){
                exercise.weight = String(weight) + " lbs"
            }
            for counter in 0 ... 19 {
                data.append(String(weight) + " lbs" )
                let weightString = (String(weight) + " lbs")
                if (weightString == exercise.weight){
                    picker1.selectRow(counter, inComponent: 0, animated: true)
                }
                weight = weight + 5
            }
        }
        else{
            weight = 5.0
            if(exercise.weight == nil){
                exercise.weight = String(weight) + " lbs"
            }
            for counter in 0 ... 40 {
                data.append(String(weight) + " lbs" )
                let weightString = (String(weight) + " lbs")
                if (weightString == exercise.weight){
                    picker1.selectRow(counter, inComponent: 0, animated: true)
                }
                weight = weight +  2.5

            }
        }
        
        
        picker2.delegate = self
        picker2.dataSource = self
        
        picker2.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        picker2.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        picker2.topAnchor.constraint(equalTo:picker1.bottomAnchor).isActive = true
        picker2.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true
        
        var reps = 1
        for counter in 0 ... 30 {
            if(exercise.reps == nil){
                exercise.reps = String(reps) + " reps"
            }
            time.append(String(reps) + " reps" )
            let timeString = String(reps) + " reps"
            if (timeString == exercise.reps){
                print("Happening")
                picker2.selectRow(counter, inComponent: 0, animated: true)
            }
            reps += 1
        }
        

    
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95).isActive = true
        scrollView.topAnchor.constraint(equalTo:picker2.bottomAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo:view.bottomAnchor, constant: -10).isActive = true
        scrollView.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true
        
        scrollView.layer.borderWidth = 3
        scrollView.layer.borderColor = UIColor.black.cgColor
        scrollView.contentSize.height = view.bounds.height
        insertScrollText(info: info)
        
    }
    
    func insertScrollText(info: [String: String]){
        let boldText  =  info["description"]! + "\n" + info["guide"]!
        
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: boldText)
        
        guide.attributedText = attributedText
        guide.textAlignment = NSTextAlignment.center
        
        guide.font = UIFont.boldSystemFont(ofSize: 12.0)
        
        guide.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9).isActive = true
        guide.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.5).isActive = true
        
        guide.topAnchor.constraint(equalTo:scrollView.topAnchor).isActive = true
        guide.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        let images = info["images"]!
        let truncated = images.substring(to: images.index(before: images.endIndex))
        let myStringArr = truncated.components(separatedBy: ",")
        var imageList = [UIImage]()
        
        for string in myStringArr{
            let url = URL(string: string)!
            let data = try? Data(contentsOf: url)
            imageList.append(UIImage(data: data!)!)
        }
        
        imageView.image = imageList[0]
        imageView.animationImages = imageList
        self.imageView.animationDuration = 5.0
        self.imageView.startAnimating()
        
        
        imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1).isActive = true
        imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.5).isActive = true
        imageView.topAnchor.constraint(equalTo: guide.bottomAnchor, constant:20).isActive = true
        imageView.centerXAnchor.constraint(equalTo:scrollView.centerXAnchor).isActive = true


    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 1){
            return data.count
        }
        if (pickerView.tag == 2){
            return time.count
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if (pickerView.tag == 1){
            exercise.weight = data[row]
        }
        if (pickerView.tag == 2){
            exercise.reps = time[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 1){
            return String(data[row])
        }
        if (pickerView.tag == 2){
            return String(time[row])
        }
        return "1"
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    
}
