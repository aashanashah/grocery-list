//
//  ViewController.swift
//  Grocery List
//
//  Created by Aashana on 11/6/17.
//  Copyright © 2017 Aashana. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet var addList : UIButton!

    override func viewDidLoad() {
        addList.layer.cornerRadius = 10
        addList.layer.borderWidth = 1
        addList.layer.borderColor = UIColor.black.cgColor
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func addList(sender : UIButton!)
    {
        let listItemsViewController = self.storyboard?.instantiateViewController(withIdentifier: "ListItemsViewController") as! ListItemsViewController
       
        self.navigationController?.pushViewController(listItemsViewController, animated: true)
    }

}

