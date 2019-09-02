//
//  AddProjectViewController.swift
//  PP-CW2
//
//  Created by student on 5/22/19.
//  Copyright © 2019 studentasd. All rights reserved.
//
protocol ProjectViewDelegate {
    func reloadProjectHeader(updatedProject: Project)
}

import UIKit
import EventKit

class ProjectViewController: UIViewController {
    
    @IBOutlet weak var projectNameField: UITextField!
    @IBOutlet weak var notesField: UITextView!
    @IBOutlet weak var dueDateField: UITextField!
    @IBOutlet weak var prioritySelector: UISegmentedControl!
    
    var delegate: ProjectViewDelegate?
    
    var currentProject: Project?
    var priority = ["Low", "Medium", "High"]
    
    let datePicker:UIDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupDatePicker()
        
        if(self.currentProject != nil) {
            setupEditProjectView()
        }
        
    }
    
    func setupDatePicker() {
        datePicker.datePickerMode = .date
        dueDateField.inputView = datePicker
        
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
        
    }
    
    func setupEditProjectView() {
        projectNameField.text = currentProject?.project_name
        notesField.text = currentProject?.notes
        dueDateField.text = Helper.getStringFromDate(date: (currentProject?.due_date)!)
        prioritySelector.selectedSegmentIndex = priority.firstIndex(of: (currentProject?.priority)!)!
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        dueDateField.text = dateFormatter.string(from: sender.date)
        
    }
    
    @IBAction func cancelBtn(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtn(_ sender: UIBarButtonItem) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        if (projectNameField.text == "" || notesField.text == "" || dueDateField.text == "") {
            // alert
            Helper.showAlert(for: self, title: "Empty Fields", message: "Please fill in empty fields")
        } else {
            if(self.currentProject != nil) {
                currentProject?.project_name = projectNameField.text
                currentProject?.notes = notesField.text
                currentProject?.due_date = Helper.getDateFromString(date: dueDateField.text!)
                currentProject?.priority = prioritySelector.titleForSegment(at: prioritySelector.selectedSegmentIndex)
                
                // reload project on detail view
                delegate?.reloadProjectHeader(updatedProject: self.currentProject!)
            } else {
                let newProject = Project(context: context)
                newProject.project_name = projectNameField.text
                newProject.notes = notesField.text
                newProject.due_date = Helper.getDateFromString(date: dueDateField.text!)
                newProject.completed = 0
                newProject.priority = prioritySelector.titleForSegment(at: prioritySelector.selectedSegmentIndex)
                
            }
            
            appDelegate.saveContext()
            
            // dismiss popover
            dismiss(animated: true, completion: nil)
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
