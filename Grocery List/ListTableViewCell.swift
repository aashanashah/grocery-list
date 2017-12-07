//
//  ListTableViewCell.swift
//  Grocery List
//
//  Created by Aashana on 11/7/17.
//  Copyright © 2017 Aashana. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet var listText : UITextField!
    @IBOutlet var addButton : UIButton!
    @IBOutlet var stepper : UIStepper!
    @IBOutlet var count : UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        stepper.wraps = true
        stepper.autorepeat = true
        listText.delegate = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func stepperValueChanged(sender: UIStepper) {
        count.text = Int(sender.value).description
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
    {
        textField.resignFirstResponder()
        return true
    }

}
