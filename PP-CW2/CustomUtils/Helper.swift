//
//  Helper.swift
//  PP-CW2
//
//  Created by student on 5/27/19.
//  Copyright © 2019 studentasd. All rights reserved.
//

import UIKit

class Helper {
    
    public static func showAlert(for controller: UIViewController, title: String, message: String) {
        let alert = UIAlertController (title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(OKAction)
        controller.present(alert, animated: true, completion: nil)
    }
    
    public static func getDateFromString(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        return dateFormatter.date(from: date)!
    }
    
    public static func getStringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        return dateFormatter.string(from: date)
    }
    
    
}
