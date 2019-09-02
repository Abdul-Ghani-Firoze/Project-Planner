//
//  AddTaskViewController.swift
//  PP-CW2
//
//  Created by student on 5/24/19.
//  Copyright © 2019 studentasd. All rights reserved.
//
protocol TaskViewDelegate {
    func reloadProjectProgress()
}

import UIKit

class TaskViewController: UIViewController {
    
    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var noteField: UITextView!
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var dueDateField: UITextField!
    @IBOutlet weak var percentageField: UILabel!
    @IBOutlet weak var percentageSlider: UISlider!
    
    var delegate: TaskViewDelegate?
    
    var selectedProject: Project?
    var task: Task?
    
    let startDatePicker:UIDatePicker = UIDatePicker()
    let dueDatePicker:UIDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupDatePickers()
        
        if(self.task != nil) {
            setupEditTaskView()
        }
    }
    
    func setupEditTaskView() {
        taskNameField.text = task?.task_name
        noteField.text = task?.note
        startDateField.text = Helper.getStringFromDate(date: (task?.start_date)!)
        dueDateField.text = Helper.getStringFromDate(date: (task?.due_date)!)
        if let percentageValue = task?.completed {
            percentageField.text = String(percentageValue)
            percentageSlider.value = Float(percentageValue) / 100
        }
    }
    
    func setupDatePickers() {
        startDatePicker.datePickerMode = .date
        dueDatePicker.datePickerMode = .date
        
        startDateField.inputView = startDatePicker
        dueDateField.inputView = dueDatePicker
        
        startDatePicker.addTarget(self, action: #selector(self.startDateChanged(sender:)), for: UIControl.Event.valueChanged)
        
        dueDatePicker.addTarget(self, action: #selector(self.dueDateChanged(sender:)), for: UIControl.Event.valueChanged)
    }
    
    @objc func startDateChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        startDateField.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func dueDateChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        dueDateField.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func percentageChanged(_ sender: UISlider) {
        let value = sender.value * 100
        percentageField.text = String(format: "%.0f", value)
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
        
        if (taskNameField.text == "" || noteField.text == "" || startDateField.text == "" || dueDateField.text == "") {
            // alert
            Helper.showAlert(for: self, title: "Empty fields", message: "Please fill in empty fields")
        } else {
            if(self.task != nil) {
                task?.task_name = taskNameField.text
                task?.note = noteField.text
                task?.start_date = Helper.getDateFromString(date: startDateField.text!)
                task?.due_date = Helper.getDateFromString(date: dueDateField.text!)
                task?.completed = Int16(percentageField.text!)!
                
            } else {
                let newTask = Task(context: context)
                newTask.task_name = taskNameField.text
                newTask.note = noteField.text
                newTask.start_date = Helper.getDateFromString(date: startDateField.text!)
                newTask.due_date = Helper.getDateFromString(date: dueDateField.text!)
                newTask.completed = Int16(percentageField.text!)!
                
                selectedProject?.addToTasks(newTask)
            }
            
            delegate?.reloadProjectProgress()
            
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
