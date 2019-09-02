//
//  TasksTableViewCell.swift
//  PP-CW2
//
//  Created by student on 5/22/19.
//  Copyright © 2019 studentasd. All rights reserved.
//

protocol TaskCellDelegate {
    func getTask(ofCell: TasksTableViewCell) -> Task?
    func displayEditTaskView(forTask: Task, controller: TaskViewController)
}

import UIKit

class TasksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var notes: UILabel!
    @IBOutlet weak var percentage: UILabel!
    @IBOutlet weak var timeLeft: UILabel!
    @IBOutlet weak var progressBar: LinearProgressBar!
    @IBOutlet weak var btnEdit: UIButton!
    
    var delegate: TaskCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        progressBar.barColorForValue = { value in
            switch value {
            case 0..<20:
                return UIColor.red
            case 20..<60:
                return UIColor.orange
            case 60..<80:
                return UIColor.yellow
            default:
                return UIColor.green
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func editTask(_ sender: UIButton) {
        
        let editTaskViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TaskViewController") as! TaskViewController
        editTaskViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        editTaskViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        editTaskViewController.preferredContentSize = CGSize(width: 315, height: 550)
        
        let editTaskPopover = editTaskViewController.popoverPresentationController
        editTaskPopover?.sourceView = sender
        
        if let task = delegate?.getTask(ofCell: self) {
            delegate?.displayEditTaskView(forTask: task, controller: editTaskViewController)
        }
    }
}
