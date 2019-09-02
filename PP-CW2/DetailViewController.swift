//
//  DetailViewController.swift
//  PP-CW2
//
//  Created by student on 5/21/19.
//  Copyright © 2019 studentasd. All rights reserved.
//

import UIKit
import EventKit
import CoreData
import UserNotifications

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, TaskCellDelegate, ProjectViewDelegate, TaskViewDelegate {
    
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var projectNote: UILabel!
    @IBOutlet weak var projectPriority: UILabel!
    @IBOutlet weak var progressBar: CircularProgressBar!
    @IBOutlet weak var timeLeft: CircularProgressBar!
    @IBOutlet weak var projectHeader: UIView!
    @IBOutlet weak var btnEvent: UIBarButtonItem!
    @IBOutlet weak var btnNotify: UIBarButtonItem!
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    @IBOutlet weak var tasksTableView: UITableView!
    @IBOutlet weak var detailView: UIView!
    
    var managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var project: Project?
    var tasks: [Task]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(self.project == nil) {
            self.navigationController?.isNavigationBarHidden = true
            detailView.isHidden = true
        } else {
            detailView.isHidden = false
            
            let nib = UINib.init(nibName: "TasksTableViewCell", bundle: nil)
            self.tasksTableView.register(nib, forCellReuseIdentifier: "TasksTableViewCell")
            
            self.tasksTableView.delegate = self
            self.tasksTableView.dataSource = self
            
            configureProjectHeader()
        }
        
        btnNotify.isEnabled = false
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTask" {
            if let addTaskView = segue.destination as? TaskViewController {
                addTaskView.delegate = self
                addTaskView.selectedProject = project
            }
        }
        if segue.identifier == "editProject" {
            if let editProjectView = segue.destination as? ProjectViewController {
                editProjectView.delegate = self
                editProjectView.currentProject = self.project
            }
        }
    }
    
    func reloadProjectProgress() {
        self.configureProjectProgress()
    }
    
    func reloadProjectHeader(updatedProject: Project) {
        project = updatedProject
        self.configureProjectHeader()
    }
    
    func getTask(ofCell: TasksTableViewCell) -> Task? {
        if let indexPath = tasksTableView.indexPath(for: ofCell) {
            return fetchedResultsController.object(at: indexPath)
        }
        return nil
    }
    
    func displayEditTaskView(forTask: Task, controller: TaskViewController) {
        controller.task = forTask
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    func configureProjectHeader() {
        navigationItem.title = project?.project_name
        
        projectName?.text = project?.project_name
        projectNote?.text = project?.notes
        projectPriority?.text = project?.priority
        
        configureProjectProgress()
        
        timeLeft.setProgress(to: (Double(getTimeLeft(for: project!)) / 100), withAnimation: true, type: "days")
    }
    
    func configureProjectProgress() {
        var overallProgress = 0
        var sum_percentage = 0
        var no_of_tasks = 0
        for task in (self.project?.tasks)! as! Set<Task> {
            sum_percentage += Int(task.completed)
            no_of_tasks += 1
        }
        if(no_of_tasks != 0) {
            overallProgress = (sum_percentage / no_of_tasks)
        }
        progressBar.safePercent = 70
        progressBar.setProgress(to: (Double(overallProgress) / 100), withAnimation: true, type: "")
    }
    
    func getTimeLeft(for project: Project) -> Int {
        let diffInDays = Calendar.current.dateComponents([.day], from: Date(), to: project.due_date!).day
        
        return diffInDays!
    }
    
    @IBAction func editTableCell(_ sender: UIBarButtonItem) {
        if(self.tasksTableView.isEditing == true) {
            sender.title = "Edit"
            self.tasksTableView.setEditing(false, animated: true)
        }else {
            sender.title = "Done"
            self.tasksTableView.setEditing(true, animated: true)
        }
    }
    
    @IBAction func addEvent(_ sender: UIBarButtonItem) {
        let eventStore : EKEventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(String(describing: error))")
                
                let event:EKEvent = EKEvent(eventStore: eventStore)
                
                event.title = self.project?.project_name
                event.startDate = Date()
                event.endDate = self.project?.due_date
                event.notes = self.project?.notes
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                }
                
                // alert
                Helper.showAlert(for: self, title: "Event Added", message: "A new event has been created for this project in the calendar")
            }
            else{
                Helper.showAlert(for: self, title: "No Access", message: "Please grant access to Calendar in order to save event")
            }
        }
    }
    
    @IBAction func createNotification(_ sender: UIBarButtonItem) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
            (granted, error) in
            if granted {
                
                let content = UNMutableNotificationContent()
                content.title = "Task Overdue"
                content.body = "Due date for the task is passed!"
                
                let selectedTask = self.fetchedResultsController.object(at: self.tasksTableView.indexPathForSelectedRow!)
                let dateComponent = Calendar.current.dateComponents(Set(arrayLiteral: Calendar.Component.day), from: selectedTask.due_date!)
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
                
                let request = UNNotificationRequest(identifier: String(format: "%@%x", "taskNotification-", selectedTask.objectID), content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) {
                    error in
                    guard error == nil else { return }
                    Helper.showAlert(for: self, title: "Notifcation Set", message: String(format: "%@%x", "A notification has been scheduled for the task: ", selectedTask.task_name!))
                }
            }
            else {
                Helper.showAlert(for: self, title: "No Access", message: "Please grant access to Notifcations in order to create one")
            }
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController<Task> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let selectedProject = self.project
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "task_name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if(self.project != nil){
            let predicate = NSPredicate(format:"project == %@", selectedProject!)
            fetchRequest.predicate = predicate
        }else{
            let predicate = NSPredicate(format:"project == %@", "")
            fetchRequest.predicate = predicate
        }
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Task>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tasksTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tasksTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tasksTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tasksTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tasksTableView.deleteRows(at: [indexPath!], with: .fade)
            configureProjectProgress()
        case .update:
            configureCell(tasksTableView.cellForRow(at: indexPath!)! as! TasksTableViewCell, withTasks: anObject as! Task)
        case .move:
            configureCell(tasksTableView.cellForRow(at: indexPath!)! as! TasksTableViewCell, withTasks: anObject as! Task)
            tasksTableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tasksTableView.endUpdates()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        btnNotify.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tasksTableView.dequeueReusableCell(withIdentifier: "TasksTableViewCell", for: indexPath) as! TasksTableViewCell
        let tasks = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withTasks: tasks)
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func configureCell(_ cell: TasksTableViewCell, withTasks tasks: Task) {
        cell.taskName!.text = tasks.task_name
        cell.notes!.text = tasks.note
        cell.percentage!.text = String(tasks.completed)
        cell.progressBar.progressValue = CGFloat(tasks.completed)
        
        let diffInDays = Calendar.current.dateComponents([.day], from: Date(), to: tasks.due_date!).day
        cell.timeLeft.text = String(diffInDays!)
    }
    
}
