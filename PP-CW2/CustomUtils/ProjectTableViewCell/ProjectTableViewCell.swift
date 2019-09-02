//
//  ProjectTableViewCell.swift
//  PP-CW2
//
//  Created by student on 5/21/19.
//  Copyright © 2019 studentasd. All rights reserved.
//

import UIKit

class ProjectTableViewCell: UITableViewCell {
    
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var projectNotes: UILabel!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var timeLeft: UILabel!
    @IBOutlet weak var progressBar: CircularProgressBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
