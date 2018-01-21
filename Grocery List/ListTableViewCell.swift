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
    @IBOutlet var delButton : UIButton!
    let button = UIButton(type: UIButtonType.custom)
   

    override func awakeFromNib()
    {
        super.awakeFromNib()
        stepper.wraps = true
        stepper.autorepeat = true
        listText.delegate = self
        self.addDoneButtonOnKeyboard()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
    {
        textField.resignFirstResponder()
        return true
    }
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x:0, y:0, width:320, height:50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(ListTableViewCell.doneButtonAction))
        
        let items = NSMutableArray()
        items.add(flexSpace)
        items.add(done)
        
        doneToolbar.items = items as? [UIBarButtonItem]
        doneToolbar.sizeToFit()
        
       
        self.count.inputAccessoryView = doneToolbar
        
    }
    
    @objc func doneButtonAction()
    {
        self.count.resignFirstResponder()
    }
 
}
